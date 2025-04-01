section .note.GNU-stack noalloc noexec nowrite progbits

section .rodata
    format_result db "Степень двойки: %d", 10, 0
    format_not_divisible db "Число не кратно 2", 10, 0

section .text
    global check_power_of_two
    extern printf
    extern number


; Найти степень двойки, которой кратно введённое число
check_power_of_two:
    push rbp
    mov rbp, rsp

    ; Загружаем число в ax (16 бит)
    movzx eax, word [rel number]

    ; Проверяем, делится ли число на 2 (младший бит = 0)
    test eax, 1
    jnz .not_divisible_by_2

    ; Если делится, находим степень двойки
    mov edx, eax
    neg edx
    and edx, eax  ; Теперь в edx только младший установленный бит (наибольшая степень 2, делящая число)

    ; Находим позицию бита (логарифм по основанию 2)
    xor ecx, ecx  ; Счётчик степени
    
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
    jmp .exit

.not_divisible_by_2:
    ; Выводим предупреждение, если число не делится на 2
    lea rdi, [rel format_not_divisible]
    xor eax, eax
    call printf wrt ..plt

.exit:
    mov rsp, rbp
    pop rbp
    ret