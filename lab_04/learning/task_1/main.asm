section .rodata
    input_prompt db "Введите 2 числа: ", 0
    input_prompt_len equ $ - input_prompt

    input_fmt db "%d %d", 0
    output_fmt db "Sum: %d", 10, 0

section .bss
    num_1 resd 1
    num_2 resd 1

section .text
    global main
    extern scanf, printf

main:
    push rbp
    mov rbp, rsp
    sub rsp, 16   
    
    ; Приглашение к вводу
    lea rdi, [rel input_prompt]
    mov eax, 0
    call printf wrt ..plt

    ; Ввод
    lea rdi, [rel input_fmt]
    lea rsi, [rel num_1]
    lea rdx, [rel num_2]
    mov eax, 0
    call scanf wrt ..plt

    ; Проверка успешность ввода
    cmp eax, 2 
    jne input_error ; Перейти если ZF = 0

    ; Сложение
    mov rax, [rel num_1]
    add rax, [rel num_2]
    
    lea rdi, [rel output_fmt]
    mov rsi, rax
    mov eax, 0
    call printf wrt ..plt
    ; Успешное завершение


    mov rax, 0
    leave
    ret

input_error:
    mov rax, 1
    leave
    ret