section .note.GNU-stack noalloc noexec nowrite progbits

section .rodata
    format_result db "Степень двойки: %d", 10, 0
    format_not_divisible db "Число не кратно 2", 10, 0
    print_null db "Введенное число ноль!", 10, 0

section .text
    global check_power_of_two
    extern printf
    extern number


; Найти степень двойки, которой кратно введённое число
check_power_of_two:
    ; Пролог функции
    push rbp
    mov rbp, rsp

    ; Загружаем число в ax (16 бит)
    movzx eax, word [rel number]

    ; Проверяем, делится ли число на 2 (младший бит = 0)
    test eax, 1
    jnz .not_divisible_by_2

    ; Проверяем, является ли число нулю
    cmp eax, 0
    je .number_is_null

    ; Иначе
    ; Если делится, находим степень двойки
    mov edx, eax
    neg edx ; Число инвертируется и прибавляется единица
    and edx, eax  ; Теперь в edx только младший установленный бит (наибольшая степень 2, делящая число)

    ; Находим позицию бита (логарифм по основанию 2)
    mov ecx, 0  ; Счётчик степени
    
.count_bits:
    shr edx, 1
    jz .print_result
    inc ecx
    jmp .count_bits

.print_result:
    ; Выводим степень двойки
    lea rdi, [rel format_result]
    mov esi, ecx
    xor eax, eax
    call printf wrt ..plt
    jmp .finish_check

.not_divisible_by_2:
    ; Выводим предупреждение, если число не делится на 2
    lea rdi, [rel format_not_divisible]
    xor eax, eax
    call printf wrt ..plt

.finish_check:
    mov rsp, rbp
    pop rbp
    ret

.number_is_null:
    ; Выводим предупреждение, если число не делится на 2
    lea rdi, [rel print_null]
    xor eax, eax
    call printf wrt ..plt
    mov rsp, rbp
    pop rbp
    ret