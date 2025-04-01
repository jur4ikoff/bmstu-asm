section .note.GNU-stack noalloc noexec nowrite progbits

section .rodata
        prompt_decimal  db "> Вывод безнакового числа в 10 с.с: ", 0
        promt_hex db "> Вывод знакового числа в 16 с.с: "
        fmt_decimal      db  "%hu", 10, 0      ; Формат: 16 бит с ведущими нулями + '\n'
        fmt_bites db "%016b", 10, 0

        fmt_positive db "0x%X", 10, 0      ; Формат для положительных чисел
        fmt_negative db "-0x%X",10,  0     ; Формат для отрицательных чисел

section .text
    global print_decimal, print_truncated_hex, check_power_of_two
    extern printf, scanf
    extern number

; Функция выводит число в 10сс, Безнаковое
print_decimal:
    push rbp
    mov rbp, rsp

    lea rdi, [rel prompt_decimal]
    mov rax, 0
    call printf wrt ..plt

    lea rdi, [rel fmt_decimal]
    movzx rsi, word [rel number]
    mov rax, 0
    call printf wrt ..plt
    
    mov rsp, rbp
    pop rbp
    ret


; Функция выводит младшие 8 бит числа в 16сс. Знаковое представлдение
print_truncated_hex:
    push rbp
    mov rbp, rsp

    lea rdi, [rel promt_hex]
    mov rax, 0
    call printf wrt ..plt

    movzx eax, word[rel number] ; безнаково читаем 16 бит в регистр EAX

    ; Усекаем до младшего байта (AL) и расширяем до 32 бит с учетом знака
    ;movzx esi, al 
    ;mov al, 0x85                   ; Пример 8-битного числа (можно изменить)
    
    ; Проверяем знак (старший бит)
    test al, 0x80 ; 0x80 в двоичном виде = 10000000 (это маска для проверки старшего бита)
    ; 0 - POS, 1 - NEG
    ; ZF (Zero Flag) — устанавливается в 1, если результат TEST равен нулю.
    jz .positive ; Переход, если ZF = 1

.negative:
    ; Обрабатываем отрицательное число
    movsx eax, al                  ; Знаковое расширение до 32 бит
    neg eax                        ; Получаем модуль числа
    
    lea rdi, [rel fmt_negative]    ; Адрес строки формата (относительный)
    mov esi, eax                   ; Аргумент для printf
    jmp .print

.positive:
    ; Обрабатываем положительное число
    movzx eax, al                  ; Беззнаковое расширение до 32 бит
    
    lea rdi, [rel fmt_positive]    ; Адрес строки формата (относительный)
    mov esi, eax                   ; Аргумент для printf

.print:
    xor eax, eax                   ; 0 FPU параметров
    call printf wrt ..plt
    
    ; Завершение программы
    mov edi, 0
    
    mov rsp, rbp
    pop rbp
    ret