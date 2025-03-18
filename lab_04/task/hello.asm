section .data
    hello db 'Hello, World!', 0xA  ; Строка для вывода, заканчивается символом новой строки
    hello_len equ $ - hello        ; Длина строки

section .text
    global _start

_start:
    ; Используем 64-битные регистры
    mov rax, 1          ; Системный вызов write (1)
    mov rdi, 1          ; Файловый дескриптор (stdout)
    mov rsi, hello      ; Указатель на строку
    mov rdx, hello_len  ; Длина строки
    syscall             ; Вызов системного вызова

    ; Завершаем программу
    mov rax, 60         ; Системный вызов exit (60)
    xor rdi, rdi        ; Код возврата 0
    syscall             ; Вызов системного вызова
