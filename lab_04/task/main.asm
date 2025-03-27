;  прямоугольная цифровая удалить строку с наибольшим количеством нечётных элементов
section .rodata
    input_rows_msg db ">Введите количество строк и стобцов в матрице через пробел: ", 0
    input_matrix_msg db "> Введите элементы матрицы через пробел:", 10, 0
    print_matrix_message db "Вывод матрицы без строки с наибольшим количеством нечетных элементов", 10, 0
    print_err_no_odd db "Нет ни одного нечетного числа", 10, 0
    print_err_empty_output db "Пустой вывод", 10, 0
    newline db 10, 0 
    pass db "PASS", 10, 0


    input_err_msg db "Ошибка ввода числа", 10, 0
    range_err_msg db "Ошибка, размер матрицы должен лежать в диапазоне [1, 9]", 10, 0
    ok_msg db "Успешный ввод", 10, 0
    finish_input_msg db "> Ввод матрицы законечен.", 10, "-------------------------------------------", 10, 0
    
    input_number_fmt db "%d %d", 0
    input_el_fmt db "%hhd", 0
    print_hdd_number db "%hhd", 10, 0
    print_d_number db "%d", 10, 0

    max_row_fmt db "Row %d has the most odd elements (%d)", 10, 0
    flags_msg db "Flags: CF=%d, ZF=%d, SF=%d", 10, 0
    output_el_fmt  db "%hhd ", 9, 0
    debug_pos db "%d", 10, 0

    MAX_CAPACITY equ 9

    ERR_INPUT_NUMBER: equ 1
    ERR_RANGE: equ 2
    ERR_NO_ODD: equ 3
    ERR_EMPTY_INPUT: equ 4


section .bss
    rows_count resd 1 ; Резервируем место (4 байта) перед переменную
    cols_count resd 1 ; REServes Dword (4 байта), 1 - Количество
    elements_count resd 1
    cur_elements resd 1

    matrix resq 9 * 9

        ; Временные переменные
    max_odd_count resd 1  ; максимальное количество нечётных
    cur_odd_count resd 1 ; Текущее количество нечетных чисел
    max_odd_row resd 1     ; строка с максимальным количеством нечётных


section .text
    global main
    extern scanf, printf
main:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    ; Принимаем количество строк и столбцов
    call input

    ; Проверка на корректный ввод
    cmp eax, 2
    jne input_err ; Перейти если ZF = 0

    ; Проверка, на то что размер <= 9
    mov eax, [rel rows_count]          
    cmp eax, MAX_CAPACITY
    jg err_range
   
    cmp eax,  MAX_CAPACITY
    jg err_range   

    ; Считаем общее количество элементов
    mov eax, [rel rows_count]
    imul eax, [rel cols_count]
    mov [rel elements_count], eax

    call input_matrix

    ; Ищем строку с максимальным количеством нечетных цифр
    call find_max_odd_row

    mov eax, [rel max_odd_count]
    cmp eax, 0
    je no_odd_number

    ; Удаляем эту строку
    call delete_row

    call print_matrix

    mov rsp, rbp
    pop rbp

    mov rdi, 0
    call exit
    
input_matrix:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    ; Приглашение к вводу
    lea rdi, [rel input_matrix_msg]
    mov rax,0 
    call printf wrt ..plt

    ; Инициализация нулем
    mov dword [rel cur_elements], 0
    mov ebx, 0 ; i = 0

input_row_loop:
    mov r12, 0 ; j = 0
input_col_loop:
    ; Вычисляем адрес matrix[i][j]
    mov eax, ebx ; eax = i
    mov edx, [rel cols_count]
    imul eax, edx ; eax = i * cols_count
    add eax, r12d ; eax = i * cols_count + j
    lea r8, [rel matrix]
    lea rsi, [r8 + rax] ; rsi = &matrix[i][j]


    ; Ввод элемента
    lea rdi, [rel input_el_fmt]
    mov eax, 0
    call scanf wrt ..plt

    ;call exit

    cmp eax, 1
    jne input_err
    
    ; Увеличивае счетчик введенных чисел
    mov eax, [rel cur_elements]
    inc eax
    mov [rel cur_elements], eax

    ; Переход к следующему столбцу
    inc r12
    cmp r12d, [rel cols_count]
    jl input_col_loop

    ; Переход к следующей строчке
    inc ebx
    cmp ebx, [rel rows_count]
    jl input_row_loop

    lea rdi, [rel finish_input_msg]
    mov rax,0 
    call printf wrt ..plt

    mov rsp, rbp
    pop rbp
    ret



print_matrix:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    lea rdi, [rel print_matrix_message]
    mov rax, 0
    call printf wrt ..plt

        ; Вывод матрицы
    mov ebx, 0 ; i = 0
    mov dword [rel cur_elements], 0

print_row_loop:
    mov r12, 0 ; j = 0
print_col_loop:
    ; Вычисляем адрес matrix[i][j]
    mov eax, ebx ; eax = i
    mov edx, [rel cols_count]
    imul eax, edx ; eax = i * cols_count
    add eax, r12d ; eax = i * cols_count + j
    lea r8, [rel matrix]
    mov rsi, [r8 + rax] ; rsi = &matrix[i][j]

    ; Вывод элемента
    lea rdi, [rel output_el_fmt]
    mov eax, 0
    call printf wrt ..plt

    ; Переход к следующему столбцу
    inc r12

    cmp r12d, [rel cols_count]
    jl print_col_loop

    lea rdi, [rel newline]
    mov eax, 0
    call printf wrt ..plt

    ; Переход к следующей строчке
    inc ebx
    cmp ebx, [rel rows_count]
    jl print_row_loop

    mov rsp, rbp
    pop rbp
    ret


input:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    ; Приглашение к вводу 
    lea rdi, [rel input_rows_msg]
    mov eax, 0
    call printf wrt ..plt

    ; Пользовательский ввод
    lea rdi, [rel input_number_fmt]
    lea rsi, [rel rows_count]
    lea rdx, [rel cols_count]
    mov eax, 0
    call scanf wrt ..plt
    
    mov rsp, rbp
    pop rbp
    ret


input_err:
    lea rdi, [rel input_err_msg]
    mov rax, 0
    call printf wrt ..plt

    mov rdi, ERR_INPUT_NUMBER
    jmp exit;

err_range:
    lea rdi, [rel range_err_msg]
    mov rax, 0
    call printf wrt ..plt

    mov rdi, ERR_RANGE
    call exit
    

err_empty_output:
    lea rdi, [rel print_err_empty_output]
    mov rax, 0
    call printf wrt ..plt

    mov rdi, ERR_EMPTY_INPUT
    call exit


find_max_odd_row:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    ; Поиск максимальной строки
    mov ebx, 0 ; i = 0
    mov dword [rel cur_elements], 0
    mov dword [rel max_odd_row], 0
    mov dword [rel max_odd_count], 0 ; Обнуляем счетчик нечетных чиселs
    

find_row_loop:
    mov dword [rel cur_odd_count], 0 ; Обнуляем счетчик нечетных чисел
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
    
    ; Увеличивае счетчик введенных чисел
    mov eax, [rel cur_elements]
    inc eax
    mov [rel cur_elements], eax

    ; Переход к следующему столбцу
    inc r12
    cmp r12d, [rel cols_count]
    jl find_col_loop

    ; Замена 
    mov eax, [rel cur_odd_count]
    cmp eax, [rel max_odd_count]
    jle .no_update        ; CHECK  ; если cur_odd_count <= max_odd_count, не обновляем
    
    ; Обновляем max_odd_count и max_odd_row
    mov eax, [rel cur_odd_count]
    mov [rel max_odd_count], eax
    ; mov ebx, [current_row]
    mov [rel max_odd_row], ebx

.no_update:
    ; Переход к следующей строчке
    inc ebx
    cmp ebx, [rel rows_count]
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
    mov eax, [rel cur_odd_count]
    inc eax
    mov [rel cur_odd_count], eax 

    ret
    
no_odd_number:
    lea rdi, [rel print_err_no_odd]
    mov rax, 0
    call printf wrt ..plt

    mov rdi, ERR_NO_ODD
    call exit


delete_row: 
    mov eax, [rel rows_count]
    cmp eax, 1
    je err_empty_output

    mov eax, [rel max_odd_row]
    cmp eax, [rel rows_count]
    jge end_program  ; если max_odd_row >= rows_count, ничего не делаем

    ; Вычисляем количество строк после удаления
    mov ecx, [rel rows_count]
    dec ecx
    mov [rel rows_count], ecx

    ; Вычисляем адрес строки для удаления (max_odd_row * cols_count * 8)
    mov eax, [rel max_odd_row]
    mov ebx, [rel cols_count]
    imul eax, ebx
    ; shl eax, 3  ; умножение на 8 (размер qword)
    lea r8, [rel matrix]
    lea rsi, [r8 + rax]  ; адрес начала строки для удаления

    ; Вычисляем адрес следующей строки
    mov eax, [rel cols_count]
    ; shl eax, 3  ; умножение на 8 (размер qword)
    add rax, rsi  ; rax теперь указывает на следующую строку

    ; Вычисляем количество байт для перемещения (все строки после удаляемой)
    mov ecx, [rel rows_count]
    sub ecx, [rel max_odd_row]  ; rows_count уже уменьшено на 1
    imul ecx, [rel cols_count]
    ; shl ecx, 3  ; умножение на 8 (размер qword)

    ; Копируем данные (перемещаем строки вверх)
    mov rdi, rsi  ; куда копируем
    mov rsi, rax   ; откуда копируем
    rep movsq

end_program:
    ; Завершение программы
    ret
    ;mov eax, 60    ; syscall номер для exit
    ;xor edi, edi   ; код возврата 0
    ;syscall
    
exit:
    ; Метка выходит из программы. В регистре RDI должен лежать нужный код возврата
    mov rax, 60
    syscall
