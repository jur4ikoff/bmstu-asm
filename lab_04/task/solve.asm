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
    mov edx, [rel cols_count]
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
    mov ah, byte [rel rows_count]
    dec ah
    mov [rel rows_count], ah

;     ; Вычисляем адрес строки для удаления (max_odd_row * cols_count)
;     mov eax, [rel max_odd_row]
;     mov ebx, [rel cols_count]
;     imul eax, ebx
;     lea r8, [rel matrix]
;     lea rsi, [r8 + rax]  ; адрес начала строки для удаления

;     ; Вычисляем адрес следующей строки
;     mov eax, [rel cols_count]
;     add rax, rsi  ; rax теперь указывает на следующую строку

;     ; Вычисляем количество байт для перемещения (все строки после удаляемой)
;     mov ecx, [rel rows_count]
;     sub ecx, [rel max_odd_row]  ; rows_count уже уменьшено на 1
;     imul ecx, [rel cols_count]

;     ; Копируем данные (перемещаем строки вверх)
;     mov rdi, rsi  ; куда копируем
;     mov rsi, rax   ; откуда копируем
;     rep movsq

; Завершение удаления
end_delete:
    ret
