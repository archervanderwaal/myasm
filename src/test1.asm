;@author stormma <a href="https://blog.stormma.me">关于我</a>
;@date 2017/10/25
;@description 2017年<em>上机题目第一道</em><br/>
;						<em>题目内容</em>
;						<p>从键盘读入一个正数N(16位),转换成16进制并且存入ax寄存器，并且显示出来</p>
;用户输入的值存到了BX寄存器，为了避免中断调用来回`push ax pop ax`
;要注意的问题: 过程中，push 和 pop要成对出现，不然ret只会pop cs会造成返回不到原来call 过程的位置
title test1
assume cs:code, ds:data, ss:stack

;========>宏定义
reg_save		macro
				push ax
				push bx
				push cx
				push dx
				push si 
				push di
				push bp
				endm

reg_rec			macro
				pop bp
				pop di
				pop si
				pop dx
				pop cx
				pop bx
				pop ax
				endm

print			macro		addr
				lea dx, addr
				mov ah, 09H
				int 21H
				endm

;========>data段
data segment
						prompt 	db			0DH, 0AH, 'please input a decimal number(0-65535): $'
						info1   db   		0DH, 0AH, 'the decimal of this number is: $'  
						info2   db   		0DH, 0AH, 'the hexadecimal of this number is: $'  
						info3   db   		0DH, 0AH, 'the octal of this number is: $'  
						info4   db   		0DH, 0AH, 'the binary of this number is: $' 
						crlf 	db 			0DH, 0AH, '$'
data ends

;========>栈段
stack segment
								db			128			dup(0)	
sp_pointer		label	word
stack ends

;========>代码段
code segment
start:

						mov ax, stack
						mov ss, ax
						lea sp, sp_pointer
						call init_reg
						; 读入用户输入的整数，读到寄存器bx
						call read_number
						; 寄存器bx的二进制数转换成十进制输出
						call bin_to_dec
						; 寄存器bx的二进制数转换成十六进制输出
						call bin_to_hex
						; 寄存器bx的二进制数转换成八进制输出
						call bin_to_oct
						; 寄存器bx的二进制数转换成二进制输出
						call bin_to_bin
						call exit
init_reg:
						mov ax, data
						mov ds, ax
						mov es, ax
						ret

;========>读入<=16位整数 ==> bx寄存器
read_number proc near
						print prompt
						xor bx, bx
			newchar:
						mov ah, 01H
						int 21H
						xor ah, ah
						cmp al, '0'
						jl read_finsh
						cmp al, '9'
						jg read_finsh
						sub al, 30H
						xchg ax, bx
						mov cx, 10
						mul cx
						xchg ax, bx
						add bx, ax
						jmp newchar
			read_finsh:
						ret
read_number endp

;========>二进制转换成十进制输出 ==> 除10取余  reverse()输出结果
bin_to_dec proc near
						reg_save
						print info1
						mov ax, bx
						cmp ax, 0
						jz dec_zero
						mov bx, 10
						mov di, 1
			dec1:
						cmp ax, 0
						jz dec2
						inc di
						xor dx, dx
						div bx
						call dl_convert_to_ascii
						push dx
						jmp dec1
			dec2:
						dec di
						cmp di, 0
						jz dec_convert_finsh
						pop dx
						mov ah, 02H
						int 21H
						jmp dec2
			dec_zero:
						mov dx, ax
						call dl_convert_to_ascii
						mov ah, 02H
						int 21H
			dec_convert_finsh:
						reg_rec
						ret
bin_to_dec endp

;========>二进制转换成十六进制输出，类比bin_to_dec function ==>
bin_to_hex proc near
						reg_save
						print info2

						mov ax, bx

						cmp ax, 0
						jz hex_zero
						mov bx, 16
						mov di, 1

			hex1:
						cmp ax, 0
						jz hex2
						inc di
						xor dx, dx
						div bx
						call dl_convert_to_ascii
						push dx
						jmp hex1
			hex2:
						dec di 
						cmp di, 0
						jz hex_convert_finsh
						pop dx
						mov ah, 02H
						int 21H
						jmp hex2
			hex_zero:
						mov dx, ax
						call dl_convert_to_ascii
						mov ah, 02H
						int 21H

			hex_convert_finsh:
						reg_rec
						ret

bin_to_hex endp

;========>二进制转换成八进制输出
bin_to_oct proc near
						reg_save
						print info3

						mov ax, bx

						cmp ax, 0
						jz oct_zero

						mov bx, 8
						mov di, 1
			oct1:
						cmp ax, 0
						jz oct2
						inc di 
						xor dx, dx
						div bx
						call dl_convert_to_ascii
						push dx
						jmp oct1
			oct2:		
						dec di 
						cmp di, 0
						jz oct_convert_finsh
						pop dx
						mov ah, 02H
						int 21H
						jmp oct2

			oct_zero:
						mov dx, ax
						call dl_convert_to_ascii
						mov ah, 02H
						int 21H
			oct_convert_finsh:
						reg_rec
						ret
bin_to_oct endp

;========>二进制转换成二进制输出
bin_to_bin proc near
						
						reg_save
						print info4

						mov ax, bx 

						cmp ax, 0
						jz bin_zero

						mov bx, 2
						mov di, 1

			bin1:
						cmp ax, 0
						jz bin2
						inc di
						xor dx, dx
						div bx
						call dl_convert_to_ascii
						push dx
						jmp bin1
			
			bin2:
						dec di 
						cmp di, 0
						jz bin_convert_finsh
						pop dx
						mov ah, 02H
						int 21H
						jmp bin2

			bin_zero:
						mov dx, ax
						call dl_convert_to_ascii
						mov ah, 02H
						int 21H

			bin_convert_finsh:
						reg_rec
						ret
bin_to_bin endp

;========>dl的内容转换成ascii码，<10 + 30H >=10 + 37H
dl_convert_to_ascii proc near
						cmp dl, 10
						jl less_than_ten
						add dl, 37H
						jmp convert_ascii_finsh
			less_than_ten:
						add dl, 30H
			convert_ascii_finsh:
						ret
dl_convert_to_ascii endp


;========>return to dos system退出
exit proc near
						mov ah, 4cH
						int 21H
						ret
exit endp

code ends
end start
end
