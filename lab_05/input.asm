section .note.GNU-stack noalloc noexec nowrite progbits

section .rodata
    input_number_msg db "> Введите беззнаковое 16-ти разрядное число в 2 с.с: ", 0
    test_out db "test", 10, 0
    
    input_fmt db "%16s", 0

section .text
    global input_number, print_decimal, print_truncated_hex, check_power_of_two
    extern printf, scanf
    extern err_input

; Функция принимает число у пользователя
input_number:
    ; Выравнивание стека
    push rbp
    mov rbp, rsp
    sub rsp, 16

    ; Вывод приглашения к вводу
    lea rdi, [rel test_out]
    mov rax, 0 
    call printf wrt ..plt

    ; Принимаем у пользователя 16-ти разрядное число в 2 с.с.

    mov rsp, rbp
    pop rbp
    ret
    
print_decimal:
    ret 
print_truncated_hex:
    ret

check_power_of_two:
    ret