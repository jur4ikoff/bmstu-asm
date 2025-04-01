; беззнаковое в 2 беззнаковое в 10 с/с знаковое в 16 с/с 1-й вариант
section .note.GNU-stack noalloc noexec nowrite progbits

extern err_operation, err_input
extern input_number, print_decimal, print_truncated_hex, check_power_of_two
section .rodata
    menu db 10, "Меню:", 10
        db "0. Выход", 10
        db "1. Ввести число в 2 с.с", 10
        db "2. Вывести число в 10 с.с", 10
        db "3. Вывести усечённое до 8 разрядов, в 16 с.с ", 10
        db "4. Найти степень двойки, которой кратно введённое число", 10
        db "> Выберите операцию: ", 0

    fmt db "%d", 0
    newline db 10, 0
    error_msg db "Неверно выбрана команда", 10, 0

section .data 
    align 8 ; Выравнивание
    number dw 0
    global operations
    operations:
        dq input_number ; 1
        dq print_decimal ; 2
        dq print_truncated_hex ; 3
        dq check_power_of_two ; 4

section .bss
    operation resd 1 ; Выделяем число размером 4 байта

section .text
    global main, exit
    extern printf, scanf
main:
    push rbp
    mov rbp, rsp
    sub rsp, 16
    
.menu_loop:
    ; Вывод меню на экран
    lea rdi, [rel menu]
    xor eax, eax
    call printf wrt ..plt

    ; Считываем команду с экрана
    lea rdi, [rel fmt]
    lea rsi, [rel operation]
    mov rax, 0
    call scanf wrt ..plt
    
    ; Проверяем успешность ввода
    cmp eax, 1
    jnz err_operation

    ; Если операция = выход
    mov eax, [rel operation]
    cmp eax, 0
    jz .exit_from_menu
    
    ; Если операция > чем колво операций
    cmp eax, 4
    jg err_operation

   
    ; Уменьшаем номер операции, чтобы использовать ее как индекс
    dec eax

    ; Вызываем соответствующую функцию
    lea rbx, [rel operations]
    mov rdi, [rel number]
    call [rbx + rax*8]

    ; Зацикливание
    jmp .menu_loop

.exit_from_menu:
    mov rsp, rbp
    pop rbp
    mov rdi, 0

; Метка выходит из программы. В регистре RDI должен лежать нужный код возврата
exit:
    mov rax, 60
    syscall

