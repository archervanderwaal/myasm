;@author stormma  <a href="https://blog.stormma.me">关于我</a>
;@date 2017/10/31
;@description 2017年<em>上机题目第二道</em><br/>
;                       <em>题目内容</em>
;                       <p>buffer100个字递增排序，并按照格式打印 <数据1>  <原序号></p>
;@answer 把buffer100个字冒泡排序，同时交换index
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


;=======>数据段
data segment 
        ; 生成100->1的100个数，排序成1->100，所谓冒泡排序最坏情况下，交换比较次数O(n^2)
        buffer     dw       100
                            x = 101
                            rept   100
                            x = x - 1
                            dw x
                            endm
        index      dw      100     ; 原数组索引
                            x = -1
                            rept 100
                            x = x + 1
                            dw x
                            endm

        data_item   db      'data $'
        index_item  db      'index $'

        length      equ      buffer  ; length = 100
        before_sort db      'before bubble sort, the array is: $'
        after_sort  db      'after bubble sort, the array is: $'
        clrf        db       0DH, 0AH, '$'
        space       db       20H, '$'
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
                        
                        call bubble_sort
                        print data_item
                        print space
                        print space
                        print space
                        print index_item
                        call print_result
                        call exit

    init_reg:
                        mov ax, data
                        mov ds, ax
                        mov es, ax
                        ret
;========>冒泡排序算法，从第一个元素开始挨个比较，每一次循环得到最后一个最大的数，cx--, 时间复杂度O(n^2)，空间复杂度O(1)
bubble_sort proc near
                        reg_save
                        ; bp表示index索引位置的偏移地址
                        lea bp, index
                        mov cx, length
                        dec cx
            sort_loop1:
                        mov si, 2;
                        push cx
            sort_loop2:
                        mov bx, ds:[si]
                        cmp bx, ds:[si + 2]
                        jbe next
                        xchg bx, ds:[si + 2]
                        mov ds:[si], bx
                        ;change数组元素之后，接着change index对应位置的索引值, si <->si + 2
                        mov bx, ds:[bp + si]
                        xchg bx, ds:[bp + si + 2]
                        mov ds:[bp + si], bx
            next:
                        add si, 2
                        loop sort_loop2
                        pop cx
                        loop sort_loop1
            sort_finsh:
                        reg_rec
                        ret
bubble_sort endp

;========> 打印最终结果
print_result proc near
                        reg_save

                        lea bp, index
                        mov si, 2
                        mov cx, length
            print_lp:
                        mov bx, ds:[si]
                        call bx_bin_to_dec_print
                        print space
                        print space
                        print space
                        mov bx, ds:[bp + si]
                        call bx_bin_to_dec_print
                        print clrf
                        add si, 2
                        loop print_lp
            print_result_finsh:
                        reg_rec
                        ret
print_result endp

;========>把bx中的二进制转换成十进制输出
bx_bin_to_dec_print proc near
                        reg_save
                        mov ax, bx

                        cmp ax, 0
                        jz convert_zero

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
                        jz convert_print_finsh
                        pop dx
                        mov ah, 02H
                        int 21H
                        jmp convert_print
            convert_zero:
                        mov dx, ax
                        call dl_convert_ascii
                        mov ah, 02H
                        int 21H
            convert_print_finsh:
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