section .data
    hello db 'Hello, World!', 0xA, 0  ; Строка для вывода, заканчивается символом новой строки и нулевым байтом

section .text
    global main
    extern printf, exit

main:
    push rbp
    mov rbp, rsp

    ; Вызов функции printf
    lea rdi, [rel hello]      ; Первый аргумент: указатель на строку
    call printf wrt ..plt         ; Вызов printf

    ; Завершаем программу
    mov rdi, 0          ; Код возврата 0
    call exit wrt ..plt          ; Вызов exit
    mov rsp, rbp
    pop rbp

section .note.GNU-stack