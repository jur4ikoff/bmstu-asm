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
    test_fmt db "%hu", 0
    newline db 10, 0
    error_msg db "Неверно выбрана команда", 10, 0

section .data 
    align 8 ; Выравнивание
    
    global operations
    operations:
        dq input_number ; 1
        dq print_decimal ; 2
        dq print_truncated_hex ; 3
        dq check_power_of_two ; 4

section .bss
    global number
    operation: resw 1 ; Выделяем число размером 2 байта
    number: resw 1
    buffer   resb 16 

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
    mov eax, 0
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
    mov di, [rel number]
    call [rbx + rax*8]

    movzx rax, word [rel number]     ; Берём 16 бит из number
    lea rdi, [rel buffer]            ; Указатель на буфер (RIP-relative)
    mov rcx, 16                      ; 16 бит = 16 символов

    ; Преобразуем биты в ASCII '0'/'1'
.convert_loop:
    shl ax, 1                        ; Сдвигаем влево, старший бит -> CF
    mov byte [rdi], '0'              ; По умолчанию '0'
    adc byte [rdi], 0                ; Если CF=1, то '0' + 1 = '1'
    inc rdi                          ; Перемещаем указатель
    loop .convert_loop               ; Повторяем 16 раз

    ; Добавляем перевод строки
    mov byte [rdi], 10               ; '\n'

    ; Выводим на экран (sys_write)
    mov rax, 1                       ; sys_write
    mov rdi, 1                       ; stdout
    lea rsi, [rel buffer]            ; Адрес буфера (RIP-relative)
    mov rdx, 17                      ; 16 символов + '\n'
    syscall

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

