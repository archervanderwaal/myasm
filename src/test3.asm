;@author stormma  <a href="https://blog.stormma.me">关于我</a>
;@date 2017/11/1
;@description 2017年<em>上机题目第三道</em><br/>
;                       <em>题目内容</em>
;                       <p>按照同余法产生一组随机数N (1 < N<= 50)，并按N+50赋值给45名同学的5门课程的成绩，要求编程实现计算每个
;						同学的平均成绩，并根据平均成绩统计全班的各等级的人数: A=>90~100, B=>80~89, C=>70~79, D=>66~69, E=>60~65, F=>0~59</p>
;@answer 除法取平均值采用四舍五入，因为是除以5，所以余数肯定小于5，那么直接舍掉就是我们想要的答案

title test4

assume cs:code, ds:data, ss:stack

;========>宏定义
reg_save        macro
                push ax
                push bx
                push cx
                push dx
                push si 
                push di
                push bp
                endm

reg_rec         macro
                pop bp
                pop di
                pop si
                pop dx
                pop cx
                pop bx
                pop ax
                endm

print           macro       addr
                lea dx, addr
                mov ah, 09H
                int 21H
                endm


;=======>数据段
data segment 
		; 语文科目
		chinese		db 		45
							x = 1
							rept 45
							x = (x + 15) mod 50
							db x + 50
							endm
		; 数学科目
		math		db 		45
							x = 1
							rept 45
							x = (x + 13) mod 50
							db x + 50
							endm
		; 英语科目
		english		db 		45
							x = 1
							rept 45
							x = (x + 17) mod 50
							db x + 50
							endm
		; java
		java		db 		45
							x = 1
							rept 45
							x = (x + 12) mod 50
							db x + 50
							endm
		; 人生苦短，我用py
		python		db 		45
							x = 1
							rept 45
							x = (x + 18) mod 50
							db x + 50
							endm
		number		equ		chinese
		byte_num	equ 	math - chinese
		subject_num	db		5
        clrf        db       0DH, 0AH, '$'
        space       db       20H, '$'

        total		db		0DH, 0AH, 'Total    45', '$'
data ends

;========>结果段
result segment
		; 成绩平均值
		average		db		45
					db		45	dup(0)
		count_a		db 		'A', 0
		count_b		db		'B', 0
		count_c		db		'C', 0
		count_d		db		'D', 0
		count_e		db		'E', 0
		count_f		db		'F', 0

result ends

;=======> 栈段
stack segment stack
        db          128       dup(0)
sp_pointer      label   word
stack ends

;=======> 代码段
code segment
    start:  
    					mov bp, byte_num
    					mov ax, stack
                        mov ss, ax
                        lea sp, sp_pointer

                        call init_reg
                        ; 计算成绩平均值
                        call calculate_average
                        call count_rank
                        call print_result
    					call exit
    init_reg:
                        mov ax, data
                        mov ds, ax
                        mov ax, result
                        mov es, ax
                        ret
;=======>打印最终结果
print_result proc near
						reg_save
						print total
						print clrf
						mov cx, 6
						mov bp, 46
						mov si, 0
			print_result_lp:
						xor bh, bh
						mov dl, es:[bp + si]
						mov ah, 02H
						int 21H
						mov bl, es:[bp + si + 1]
						print space 
						print space
						print space
						print space
						print space
						print space
						print space
						print space
						call bin_to_dec
						print clrf
						inc si 
						inc si
						loop print_result_lp
			print_result_finsh:
						; reg_save 无fuck说，这么一个小错误导致我找了很久，汇编调试不容易啊，怀念高级语言的日子...
						reg_rec
						ret
print_result endp

;=======>统计排名, 数据来源es:[1-->45]
count_rank proc near
						reg_save
						mov dl, number
						xor dh, dh
						mov cx, dx
						; cx = 45
						mov di, 0
						mov bp, 47
						mov si, 0
				count_lp:
						inc di
						; 平均分
						mov dl, es:[di]
						cmp dl, 90
						jb less_than_a
						inc byte ptr es:[bp + si]
						loop count_lp
						jmp count_finsh
				less_than_a:
						cmp dl, 80
						jb less_than_b
						inc byte ptr es:[bp + si + 2]
						loop count_lp
						jmp count_finsh
				less_than_b:
						cmp dl, 70
						jb less_than_c
						inc byte ptr es:[bp + si + 4]
						loop count_lp
						jmp count_finsh
				less_than_c:
						cmp dl, 66
						jb less_than_d
						inc byte ptr es:[bp + si + 6]
						loop count_lp
						jmp count_finsh
				less_than_d:
						cmp dl, 60
						jb less_than_e
						inc byte ptr es:[bp + si  + 8]
						loop count_lp
						jmp count_finsh
				less_than_e:
						inc byte ptr es:[bp + si + 10]
						loop count_lp
				count_finsh:
						reg_rec
						ret
count_rank endp

;=======>计算每个学生的五门课程平均值: ①计算五门成绩总和存入bx, bx==>ax, 除以5进行四舍五入之后存入es:[si]
calculate_average proc near
						reg_save

						; mov cx, number
						mov dl, number
						xor dh, dh
						mov cx, dx
						mov si, 1
						mov di, 1
			calculate_lp1:	
						xor bp, bp
						xor bx, bx
						xor dx, dx
						push cx
						mov cx, 5
			calculate_lp2:	
						mov dl, ds:[bp + si]
						add bx, dx
						add bp, byte_num
						loop calculate_lp2
			calculate_lp3:
						; 此时bx中的值是五门成绩的总和
						mov ax, bx
						div subject_num
						mov es:[di], al
						pop cx
						inc si
						inc di
						loop calculate_lp1
			calculate_finsh:
						reg_rec
						ret
calculate_average endp

;========>二进制转换成十进制输出 ==> 除10取余  reverse()输出结果
bin_to_dec proc near
						reg_save
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

code ends
end start
end            