section .note.GNU-stack noalloc noexec nowrite progbits

section .text
    global my_strcpy
section .text
global my_strcpy

my_strcpy:
    ; Пролог функции (64-битный вариант)
    push rbp
    mov rbp, rsp
    push rbx        ; Сохраняем rbx (требуется соглашение о вызовах)

    ; Аргументы в регистрах:
    ; rdi = dest, rsi = src, rdx = len

    ; Проверка на NULL
    test rsi, rsi
    jz .exit
    test rdi, rdi
    jz .exit

    ; Проверка длины
    test rdx, rdx
    jz .exit

    ; Проверка на перекрытие областей
    cmp rdi, rsi
    je .exit
    ja .overlap_check

    ; Обычное копирование
    mov rcx, rdx    ; Длина для rep movsb
    cld
    rep movsb
    jmp .exit

.overlap_check:
    ; Проверяем расстояние между указателями
    mov rax, rdi
    sub rax, rsi
    cmp rax, rdx
    jae .normal_copy

    ; Копирование с конца
    lea rsi, [rsi + rdx - 1]  ; Конец src
    lea rdi, [rdi + rdx - 1]  ; Конец dest
    std
    mov rcx, rdx
    rep movsb
    cld
    jmp .exit

.normal_copy:
    mov rcx, rdx
    cld
    rep movsb

.exit:
    ; Эпилог функции
    pop rbx
    pop rbp
    ret