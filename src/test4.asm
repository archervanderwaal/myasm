;@author stormma  <a href="https://blog.stormma.me">关于我</a>
;@date 2017/11/03
;@description 2017年<em>上机题目第四道</em><br/>
;                       <em>题目内容
;                               略</em>


;

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
                        push ax
                        push dx
                        lea dx, addr
                        mov ah, 09H
                        int 21H
                        pop dx
                        pop ax
endm


;=======>数据段
data segment 
		menu  	      db 			0AH, 0DH, 0AH, 0DH, '           menu          '
      		  	      db 			0AH, 0DH
      		  	      db 			0AH, 0DH, '           1. convert string case'
      		  	      db 			0AH, 0DH, '           2. search the maximum of string'
      		  	      db 			0AH, 0DH, '           3. sort array.'
      		  	      db 			0AH, 0DH, '           4. reset time'
      		  	      db 			0AH, 0DH, '           5. exit'
      		  	      db 			0AH, 0DH
      		  	      db 			0AH, 0DH, '   please choose one of 1~5:','$'

            clrf              db          0AH, 0DH, '$'

            string_info       db         'please enter a string: $'
            number_info       db         'please enter an array, use speace spil(eg:1 2 3): $'
            function1_res     db         'convert result: $'
            function2_res     db         'the maximum is : $'
            time_info         db         'input a string(HH:mm:ss): $'
            promt             db         'enter esc to return to main menu, any key to do it again!$'
            err_in            db         'input error! please try agmin...$'

            inbuf             db      100
                              db      0
                              db      100 dup('$')
              
            array             dw      100 dup(0)
            len               dw      0
            char              db      ?
            time              db      '00:00:00', '$' 
            speace            db       20H, '$'
data ends


;=======> 栈段
stack segment stack
        db          256       dup(0)
sp_pointer      label   word
stack ends

;=======> 代码段
code segment
    start:  
    					mov ax, stack
                        mov ss, ax
                        lea sp, sp_pointer

                        call init_reg
                        call clear                        
                        call main
    init_reg:
                        mov ax, data
                        mov ds, ax
                        mov es, ax
                        ret
;========>程序主入口
main proc near
						reg_save
                        ; call clear
                        print menu
                        call read_number
                        call clear
                        mov ax, bx
                        xor bx, bx
				cmp ax, 1
				je _function1
				cmp ax, 2
				je _function2
				cmp ax, 3
				je _function3
				cmp ax, 4
				je _function4
                        cmp ax, 5
                        je _function5
                        call clear
                        print err_in
                        call main
                _function1:
                        call function1
                _function2:
                        call function2
                _function3:
                        call function3
                _function4:
                        call function4
                _function5:
                        call exit
				main_finsh:
				reg_rec
				ret
main endp

; 清屏
clear       proc near

                        reg_save
                        mov ax, 0003H
                        int 10H
                        reg_rec
                        ret

clear  endp

; 往缓冲区读入一个数组
read_an_array proc near
                        reg_save
                        pushf
                        lea di, array
                        mov word ptr ds:[len], 0
                        mov byte ptr ds:[char], 0
                read_start:
                        call read_number
                        mov word ptr ds:[di], bx
                        inc word ptr ds:[len]
                        inc di
                        inc di
                        cmp byte ptr ds:[char], 0DH
                        jne read_start
                read_done:
                        popf
                        reg_rec
                        ret
read_an_array endp

; 读入用户输入
read_number proc near
                        push ax
                        push cx
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
                        mov ds:[char], al
                        pop cx
                        pop ax
                        ret
read_number endp

;========>冒泡排序算法，从第一个元素开始挨个比较，每一次循环得到最后一个最大的数，cx--, 时间复杂度O(n^2)，空间复杂度O(1)for i 0 -> n-1 * for j 0 -> n-i-1
bubble_sort proc near
                        reg_save
                        mov cx, ds:[len]
                        dec cx
            sort_loop1:
                        mov si, OFFSET array
                        push cx
            sort_loop2:
                        mov bx, ds:[si]
                        cmp bx, ds:[si + 2]
                        jbe sort_next
                        xchg bx, ds:[si + 2]
                        mov ds:[si], bx
            sort_next:
                        add si, 2
                        loop sort_loop2
                        pop cx
                        loop sort_loop1
            sort_finsh:
                        reg_rec
                        ret
bubble_sort endp

; 打印数组内容(十六进制)
print_array proc near
                        reg_save
                        mov cx, ds:[len]
                        mov si, OFFSET array
            print_loop:
                        mov bx, ds:[si]
                        call bin_to_hex
                        inc si 
                        inc si 
                        print speace
                        loop print_loop
            print_finsh:
                        reg_rec
                        ret

print_array endp

; ======> bx输出以十六进制
bin_to_hex proc near
                        reg_save
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

;=========>功能点1
function1 proc near
						reg_save
                        ; 清屏
                        call clear
                begin_1:
                        print string_info
                        mov di, OFFSET inbuf
                        mov ah, 0AH
                        mov dx, di
                        int 21H

                        xor cx, cx
                        mov cl, ds:[di + 1]
                        lea si, ds:[di + 2]
                convert_up:
                        cmp byte ptr ds:[si], 'a'
                        jb skip
                        cmp byte ptr ds:[si], 'z'
                        ja skip
                        xor byte ptr ds:[si], 00100000B
                skip:
                        inc si
                        loop convert_up
                        ; 输出转换后的字符串
                        print clrf
                        print clrf
                        print function1_res
                        lea dx, ds:[di + 2]
                        mov ah, 09H
                        int 21H
                        print clrf
                        print promt
                        mov ah, 01H
                        int 21H
                        cmp al, 27
                        jne begin_1
                        call clear
				function1_finsh:
						reg_rec
                        call main
						ret
function1 endp

;=========>功能点2
function2 proc near
						reg_save
                        
                        ; 清屏
                        call clear
                begin_2:
                        print string_info

                        ; 读入缓冲区, 封装成函数
                        mov di, OFFSET inbuf
                        mov ah, 0AH
                        mov dx, di
                        int 21H

                        ; 初始化缓冲区地址
                        xor cx, cx
                        mov cl, ds:[di + 1]
                        lea si, ds:[di + 2]
                        xor dx, dx
                find_begin:
                        cmp dl, ds:[si]
                        jae greater
                        mov dl, ds:[si]
                greater:
                        inc si
                        loop find_begin
                        print clrf
                        print function2_res
                        ; 输入dl的内容
                        mov ah, 02H
                        int 21H
                        print clrf
                        print promt
                        mov ah, 01H
                        int 21H
                        cmp al, 27
                        jne begin_2
                        call clear
				function2_finsh:
						reg_rec
                        call main
						ret
function2 endp

;=========>功能点3
function3 proc near
				reg_save
                        call clear
                begin_3:
                        print number_info
                        call read_an_array
                        print clrf
                        call print_array
                        call bubble_sort
                        print clrf
                        call print_array
                        print clrf
                        print promt
                        mov ah, 01H
                        int 21H
                        cmp al, 27
                        jne begin_3
                        call clear
				function3_finsh:
                        call main
				reg_rec
				ret
function3 endp

;=========>功能点4
function4 proc near
						
				reg_save
                        call clear
                begin_4:
                        print time_info
                        lea dx, inbuf
                        mov ah, 0aH
                        int 21H
                        call time_input_check
                        cmp bl, 0
                        je err_input
                        call read_system_time
                        print clrf
                        print promt
                        mov ah, 01H
                        int 21H
                        cmp al, 27
                        jne begin_4
                err_input:
                        call clear
                        print err_in
				function4_finsh:
                        call main
                        reg_rec
				ret
function4 endp

; ========>读取系统时间
read_system_time proc 
                        mov ah,2ch
                        int 21h
                        mov bx, 10
                        mov al, ch

                        xor ah,ah
                        div bl
                        add ax, 3030h
                        lea di, time 
                        mov ds:[di], ax
                        mov al, cl
                        xor ah,ah
                        div bl
                        add ax, 3030h
                        lea di, time + 3
                        mov ds:[di], ax
                        mov al, dh
                        xor ah, ah
                        div bl
                        add ax, 3030h
                        lea di, time + 6
                        mov ds:[di], ax
                        print clrf
                        print time
                read_system_finsh:
                        ret
read_system_time endp

;=======> 检查输入的HH:MM:SS数据
time_input_check proc near
                        push si
                        xor ax, ax
                        mov bh, 10
                        mov bl, 1
                        mov al, ds:[inbuf + 2]   
                        sub al, 30h
                        mul bh 
                        mov ah, ds:[inbuf + 3]
                        sub ah, 30h
                        add al, ah
                        mov ch, al
    
                        xor ax,ax
                        mov al, ds:[inbuf + 5]   
                        sub al, 30h
                        mul bh 
                        mov ah, ds:[inbuf + 6]
                        sub ah, 30h
                        add al, ah
                        mov cl, al
    
                        xor ax,ax
                        mov al, ds:[inbuf + 8]   
                        sub al, 30h
                        mul bh 
                        mov ah, ds:[inbuf + 9]
                        sub ah, 30h
                        add al, ah
                        mov dh, al
                        mov dl, 0
                        mov ah, 2dh
                        int 21h
                        cmp al, 00h
                        je check_finished
                        mov bl, 0 
            check_finished:
                        pop si    
                        ret
time_input_check endp

;========>return to dos system退出
exit proc near
                        mov ah, 4cH
                        int 21H
                        ret
exit endp

code ends
end start
end            