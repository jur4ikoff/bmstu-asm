section .note.GNU-stack noalloc noexec nowrite progbits

section .rodata
    err_input_msg db "Ошибка во время ввода числа", 10, 0
    err_operation_msg db "Ошибка, неверено выбрана операция. Можно выбрать операцию из диапазона [0, 4]", 10, 0

    ERR_INPUT_NUMBER: equ 1

section .text
    global err_input, err_operation
    extern printf, exit

err_operation:
    lea rdi, [rel err_operation_msg]
    mov rax, 0
    call printf wrt ..plt

    mov rdi, 0
    call exit

; Метка вызывается при ошибки ввода числа
err_input:
    lea rdi, [rel err_input_msg]
    mov rax, 0
    call printf wrt ..plt

    mov rdi, ERR_INPUT_NUMBER
    call exit
