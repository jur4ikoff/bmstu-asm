;  прямоугольная цифровая удалить строку с наибольшим количеством нечётных элементов
section .rodata    
    ok_msg db "Успешный ввод", 10, 0
    
    
    print_hdd_number db "%hhd", 10, 0
    print_d_number db "%d", 10, 0

    max_row_fmt db "Row %d has the most odd elements (%d)", 10, 0
    flags_msg db "Flags: CF=%d, ZF=%d, SF=%d", 10, 0
    debug_pos db "%d", 10, 0

    MAX_CAPACITY equ 9


section .bss
    global rows_count, cols_count, matrix  ; Делаем переменные глобальные
    rows_count resb 1 ; Резервируем место (4 байта) перед переменную
    cols_count resb 1 ; REServes Dword (4 байта), 1 - Количество
    matrix resb 9 * 9

    ; Временные переменные
    max_odd_count resd 1  ; максимальное количество нечётных
    cur_odd_count resd 1 ; Текущее количество нечетных чисел
    max_odd_row resd 1     ; строка с максимальным количеством нечётных


section .text
    global main, exit
    extern scanf, printf
    extern input_count, input_matrix
    extern err_input, err_range, err_empty_output, err_no_odd_number
    extern print_matrix

main:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    ; Принимаем количество строк и столбцов
    call input_count

    ; Проверка на корректный ввод
    cmp eax, 2    ; CMP устанавливает ZF = 0, Если два операнда равны
    jne err_input ; Перейти если ZF = 0

    
    ; Проверка, на то что количество строк <= 9
    movzx eax, byte [rel rows_count]       
    cmp eax, MAX_CAPACITY ; Сравнение операнда с максимальной вместимостью
    jg err_range          ; (ZF = 0 && SF = OF) перейти, если больше eax > MAX_CAPACITY

    ; Проверка, на то что количество строк <= 9
    movzx eax, byte [rel cols_count]       
    cmp eax, MAX_CAPACITY ; Сравнение операнда с максимальной вместимостью
    jg err_range          ; (ZF = 0 && SF = OF) перейти, если больше eax > MAX_CAPACITY

    ; Принимаем элементы матрицы
    call input_matrix
    call print_matrix

    mov rsp, rbp
    pop rbp
    mov rdi, 0
    call exit

;   

;     ; Ищем строку с максимальным количеством нечетных цифр
;     call find_max_odd_row

;     mov eax, [rel max_odd_count]
;     cmp eax, 0

;     lea rax, [rel err_no_odd_number]
;     je rax
;     ; je err_no_odd_number

;     ; Удаляем эту строку
;     call delete_row

;     call print_matrix

;     mov rsp, rbp
;     pop rbp

;     mov rdi, 0
;     call exit
    

; find_max_odd_row:
;     push rbp
;     mov rbp, rsp
;     sub rsp, 16

;     ; Поиск максимальной строки
;     mov ebx, 0 ; i = 0
;     mov dword [rel cur_elements], 0
;     mov dword [rel max_odd_row], 0
;     mov dword [rel max_odd_count], 0 ; Обнуляем счетчик нечетных чиселs
    

; find_row_loop:
;     mov dword [rel cur_odd_count], 0 ; Обнуляем счетчик нечетных чисел
;     mov r12, 0 ; j = 0

; find_col_loop:
;     ; Вычисляем адрес matrix[i][j]
;     mov eax, ebx ; eax = i
;     mov edx, [rel cols_count]
;     imul eax, edx ; eax = i * cols_count
;     add eax, r12d ; eax = i * cols_count + j
;     lea r8, [rel matrix]
;     mov rsi, [r8 + rax] ; rsi = &matrix[i][j]

;     call check_odd
    
;     ; Увеличивае счетчик введенных чисел
;     mov eax, [rel cur_elements]
;     inc eax
;     mov [rel cur_elements], eax

;     ; Переход к следующему столбцу
;     inc r12
;     cmp r12d, [rel cols_count]
;     jl find_col_loop

;     ; Замена 
;     mov eax, [rel cur_odd_count]
;     cmp eax, [rel max_odd_count]
;     jle .no_update        ; CHECK  ; если cur_odd_count <= max_odd_count, не обновляем
    
;     ; Обновляем max_odd_count и max_odd_row
;     mov eax, [rel cur_odd_count]
;     mov [rel max_odd_count], eax
;     ; mov ebx, [current_row]
;     mov [rel max_odd_row], ebx

; .no_update:
;     ; Переход к следующей строчке
;     inc ebx
;     cmp ebx, [rel rows_count]
;     jl find_row_loop

;     ; Выход
;     mov rsp, rbp
;     pop rbp
;     ret

; check_odd:
;     ; Вход: RSI содержит число (младший байт - SIL)
;     ; Выход: CF=1 если нечётное, CF=0 если чётное
    
;     test sil, 1
;     jnz .odd
;     ret
; .odd:
;     mov eax, [rel cur_odd_count]
;     inc eax
;     mov [rel cur_odd_count], eax 

;     ret



; delete_row: 
;     mov eax, [rel rows_count]
;     cmp eax, 1
;     je err_empty_output

;     mov eax, [rel max_odd_row]
;     cmp eax, [rel rows_count]
;     jge end_program  ; если max_odd_row >= rows_count, ничего не делаем

;     ; Вычисляем количество строк после удаления
;     mov ecx, [rel rows_count]
;     dec ecx
;     mov [rel rows_count], ecx

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

; end_program:
;     ; Завершение программы
;     ret


; Метка для завершения программы
exit:
    ; Метка выходит из программы. В регистре RDI должен лежать нужный код возврата
    mov rax, 60
    syscall
