section .data
    prompt_rows db "Введите количество строк: ", 0
    prompt_cols db "Введите количество столбцов: ", 0
    prompt_matrix db "Введите элементы матрицы (по строкам): ", 0
    output_matrix db "Изменённая матрица:", 0
    newline db 10, 0
    format db "%hhd", 0  ; Формат для ввода/вывода одного байта (char)

section .bss
    rows resb 1          ; Количество строк (1 байт)
    cols resb 1          ; Количество столбцов (1 байт)
    matrix resb 81       ; Матрица 9x9 (максимум 81 байт)
    temp resb 1          ; Временная переменная для ввода

section .text
    global main
    extern scanf
    extern printf

main:
    ; Выравнивание стека
    push rbp
    mov rbp, rsp
    sub rsp, 16  ; Выравниваем стек до 16 байт

    ; Ввод количества строк
    lea rdi, [rel prompt_rows]
    call printf wrt ..plt
    lea rdi, [rel format]
    lea rsi, [rel rows]
    call scanf wrt ..plt

    ; Ввод количества столбцов
    lea rdi, [rel prompt_cols]
    call printf wrt ..plt
    lea rdi, [rel format]
    lea rsi, [rel cols]
    call scanf wrt ..plt

    ; Ввод элементов матрицы
    lea rdi, [rel prompt_matrix]
    call printf wrt ..plt
    movzx ecx, byte [rel rows]  ; Количество строк
    movzx ebx, byte [rel cols]  ; Количество столбцов
    lea rsi, [rel matrix]       ; Указатель на матрицу
input_loop:
    lea rdi, [rel format]
    lea rsi, [rel temp]
    call scanf wrt ..plt
    mov al, [rel temp]
    mov [rsi], al
    inc rsi
    loop input_loop

    ; Поиск строки с наибольшим количеством нечётных элементов
    movzx ecx, byte [rel rows]  ; Количество строк
    movzx ebx, byte [rel cols]  ; Количество столбцов
    lea rsi, [rel matrix]       ; Указатель на матрицу
    xor edi, edi                ; Индекс строки с максимальным количеством нечётных элементов
    xor edx, edx                ; Максимальное количество нечётных элементов
row_loop:
    xor eax, eax                ; Счётчик нечётных элементов в текущей строке
    movzx ebp, bl               ; Количество столбцов
col_loop:
    mov al, [rsi]
    test al, 1
    jz even
    inc eax
even:
    inc rsi
    loop col_loop
    cmp eax, edx
    jle next_row
    mov edx, eax
    mov edi, ecx
next_row:
    loop row_loop

    ; Удаление строки с наибольшим количеством нечётных элементов
    movzx ecx, byte [rel rows]  ; Количество строк
    movzx ebx, byte [rel cols]  ; Количество столбцов
    lea rsi, [rel matrix]       ; Указатель на матрицу
    movzx eax, bl               ; Количество столбцов
    imul eax, edi               ; Смещение до удаляемой строки
    add rsi, rax                ; Указатель на удаляемую строку
    lea rdi, [rsi + rbx]        ; Указатель на следующую строку
    movzx ecx, bl               ; Количество столбцов
    rep movsb                   ; Копируем оставшиеся строки

    ; Уменьшаем количество строк на 1
    dec byte [rel rows]

    ; Вывод изменённой матрицы
    lea rdi, [rel output_matrix]
    call printf wrt ..plt
    movzx ecx, byte [rel rows]  ; Количество строк
    movzx ebx, byte [rel cols]  ; Количество столбцов
    lea rsi, [rel matrix]       ; Указатель на матрицу
output_loop:
    movzx eax, byte [rsi]
    lea rdi, [rel format]
    movsx rsi, al
    call printf wrt ..plt
    inc rsi
    loop output_loop

    ; Завершение программы
    add rsp, 16  ; Восстанавливаем стек
    pop rbp
    mov rax, 60  ; syscall: exit
    xor rdi, rdi ; код возврата 0
    syscall

section .note.GNU-stack