section .rodata
    input_err_msg db "Ошибка ввода числа", 10, 0
    range_err_msg db "Ошибка, размер матрицы должен лежать в диапазоне [1, 9]", 10, 0
    err_no_odd_msg db "Нет ни одного нечетного числа", 10, 0
    err_empty_output_msg db "Пустой вывод", 10, 0

    ERR_INPUT_NUMBER: equ 1
    ERR_RANGE: equ 2
    ERR_NO_ODD: equ 3
    ERR_EMPTY_INPUT: equ 4

section .text
    global err_input, err_range, err_empty_output, err_no_odd_number
    extern printf, exit


; Метка вызывается при ошибки ввода числа
err_input:
    lea rdi, [rel input_err_msg]
    mov rax, 0
    call printf wrt ..plt

    mov rdi, ERR_INPUT_NUMBER
    jmp exit

err_range:
    lea rdi, [rel range_err_msg]
    mov rax, 0
    call printf wrt ..plt

    mov rdi, ERR_RANGE
    jmp exit
    

; err_empty_output:
;     lea rdi, [rel err_empty_output_msg]
;     mov rax, 0
;     call printf wrt ..plt

;     mov rdi, ERR_EMPTY_INPUT
;     lea rax, [rel exit]
;     jmp rax
    

; err_no_odd_number:
;     lea rdi, [rel err_no_odd_msg]
;     mov rax, 0
;     call printf wrt ..plt

;     mov rdi, ERR_NO_ODD
;     lea rax, [rel exit]
;     jmp rax