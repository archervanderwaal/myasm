;@author stormma
;@date 2017/10/31
;@description bubble sort

title bubble sort

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


;=======> 
data segment 
        buffer     dw       1, 65535, 65534, 65533, 2, 3
        length     EQU       ($ - buffer) / 2
        before_sort db      'before bubble sort, the array is: $'
        after_sort  db      'after bubble sort, the array is: $'
        clrf       db       0DH, 0AH, '$'
        speace     db       20H, '$'
data ends

;=======> 
stack segment stack
        db          128       dup(0)
sp_pointer      label   word
stack ends

;=======>
code segment
    start:              
                        mov ax, stack
                        mov ss, ax
                        lea sp, sp_pointer

                        call init_reg
                        
                        print before_sort
                        print clrf
                        call print_buffer
                        print clrf
                        call bubble_sort
                        print after_sort
                        print clrf
                        call print_buffer
                        print clrf
                        call exit

    init_reg:
                        mov ax, data
                        mov ds, ax
                        mov es, ax
                        ret
;========>冒泡排序算法，从第一个元素开始挨个比较，每一次循环得到最后一个最大的数，cx--, 时间复杂度O(n^2)，空间复杂度O(1)for i 0 -> n-1 * for j 0 -> n-i-1
bubble_sort proc near
                        reg_save
                        mov cx, length - 1
            sort_loop1:
                        xor si, si
                        push cx
            sort_loop2:
                        mov bx, ds:[si]
                        cmp bx, ds:[si + 2]
                        jbe next
                        xchg bx, ds:[si + 2]
                        mov ds:[si], bx
            next:
                        add si, 2
                        loop sort_loop2
                        pop cx
                        loop sort_loop1
            sort_finsh:
                        reg_rec
                        ret
bubble_sort endp

;========>打印buffer中的数组
print_buffer proc near
                        reg_save

                        mov cx, length
                        mov si, 0
            print_loop:
                        mov bx, ds:[si]
                        call bx_bin_to_dec_print
                        inc si 
                        inc si 
                        print speace
                        loop print_loop
            print_finsh:
                        reg_rec
                        ret

print_buffer endp

;========>把bx中的二进制转换成十进制输出
bx_bin_to_dec_print proc near
                        reg_save
                        mov ax, bx
                        mov bx, 10
                        mov di, 1
            convert_lp:
                        cmp ax, 0
                        jz convert_print
                        inc di
                        xor dx, dx
                        div bx 
                        ;dl ==>
                        call dl_convert_ascii
                        push dx
                        jmp convert_lp
            convert_print:
                        dec di
                        cmp di, 0
                        jz convet_print_finsh
                        pop dx
                        mov ah, 02H
                        int 21H
                        jmp convert_print
            convet_print_finsh:
                        reg_rec
                        ret
bx_bin_to_dec_print endp

;========>dl数转换ascii
dl_convert_ascii proc near
                        cmp dl, 10
                        jl less_than_ten
                        add dl, 37H
                        jmp convert_finsh
            less_than_ten:
                        add dl, 30H
            convert_finsh:
                        ret
dl_convert_ascii endp


;========>return to dos system退出
exit proc near
                        mov ah, 4cH
                        int 21H
                        ret
exit endp

code ends
end start
end