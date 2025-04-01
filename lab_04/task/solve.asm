section .note.GNU-stack noalloc noexec nowrite progbits

section .rodata
    

section .text
    global find_max_odd_row, delete_row
    extern cols_count, rows_count, matrix, err_empty_output
    extern max_odd_count, cur_odd_count, max_odd_row


find_max_odd_row:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    ; Поиск максимальной строки
    mov byte [rel max_odd_row], 0
    mov byte [rel max_odd_count], 0 ; Обнуляем счетчик нечетных чисел
    mov ebx, 0 ; i = 0
find_row_loop:
    mov r12, 0 ; j = 0
find_col_loop:
    ; Вычисляем адрес matrix[i][j]
    mov eax, ebx ; eax = i
    movzx edx, byte [rel cols_count]
    imul eax, edx ; eax = i * cols_count
    add eax, r12d ; eax = i * cols_count + j
    lea r8, [rel matrix]
    mov rsi, [r8 + rax] ; rsi = &matrix[i][j]

    call check_odd

    ; Переход к следующему столбцу
    inc r12
    movzx eax, byte [rel cols_count]
    cmp r12d, eax
    jl find_col_loop

    ; Замена 
    movzx rax, byte [rel cur_odd_count]
    movzx r8, byte [rel max_odd_count]
    cmp rax, r8
    jle .no_update        ; CHECK  ; если cur_odd_count <= max_odd_count, не обновляем
    
    ; Обновляем max_odd_count и max_odd_row
    mov eax, [rel cur_odd_count]
    mov [rel max_odd_count], eax
    mov [rel max_odd_row], ebx

.no_update:
    ; Переход к следующей строчке
    inc ebx
    movzx eax, byte [rel rows_count]
    cmp ebx, eax
    jl find_row_loop

    ; Выход
    mov rsp, rbp
    pop rbp
    ret

check_odd:
    ; Вход: RSI содержит число (младший байт - SIL)
    ; Выход: CF=1 если нечётное, CF=0 если чётное
    
    test sil, 1
    jnz .odd
    ret
.odd:
    movzx eax, byte [rel cur_odd_count]
    inc eax
    mov [rel cur_odd_count], eax 

    ret



delete_row: 
    ; Проверка, если колиество строк до удаления = 1, то вывод пустой
    movzx eax, byte [rel rows_count]
    cmp eax, 1
    je err_empty_output

    ; Проверка, если max_odd_row >= rows_count, ничего не делаем
    movzx eax, byte [rel max_odd_row]
    movzx ebx, byte [rel rows_count]
    cmp eax, ebx
    jge end_delete

    ; Вычисляем количество строк после удаления
    mov al, [rel rows_count]
    dec al
    mov [rel rows_count], al

    ; Вычисляем адрес строки для удаления (max_odd_row * cols_count)
    movzx eax, byte [rel max_odd_row]
    movzx ebx, byte [rel cols_count]
    imul eax, ebx
    lea r8, [rel matrix]
    lea rsi, [r8 + rax]  ; адрес начала строки для удаления

    ; Вычисляем адрес следующей строки
    movzx eax, byte [rel cols_count]
    add rax, rsi  ; rax теперь указывает на следующую строку

    ; Вычисляем количество байт для перемещения (все строки после удаляемой)
    movzx rcx, byte [rel rows_count]
    movzx r8, byte [rel max_odd_row]
    sub rcx, r8 ; rows_count уже уменьшено на 1
    movzx r8, byte [rel cols_count]
    imul rcx, r8

    ; Копируем данные (перемещаем строки вверх)
    mov rdi, rsi  ; куда копируем
    mov rsi, rax   ; откуда копируем
    rep movsq

; Завершение удаления
end_delete:
    ret
