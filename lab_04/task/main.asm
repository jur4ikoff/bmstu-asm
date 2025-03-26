;  прямоугольная цифровая удалить строку с наибольшим количеством нечётных элементов
section .rodata
    input_rows_msg db ">Введите количество строк и стобцов в матрице через пробел: ", 0
    input_matrix_msg db "> Введите элементы матрицы через пробел:", 10, 0
    print_matrix_message db "Вывод матрицы без строки с наибольшим количеством нечетных элементов", 10, 0
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
    
    call find_max_odd_row
    ; Удаляем эту строку
    ; call remove_max_odd_row

    call print_matrix

    mov rsp, rbp
    pop rbp
    ret 
    mov rdi, 0
    call exit
    
input_matrix:
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
    ret



print_matrix:
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

    ; Увеличивае счетчик введенных чисел
    mov eax, [rel cur_elements]
    inc eax
    mov [rel cur_elements], eax

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

    ; Сюда доходит
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
    


find_max_odd_row:
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

    call add_odd_count

    
    ; Увеличивае счетчик введенных чисел
    mov eax, [rel cur_elements]
    inc eax
    mov [rel cur_elements], eax

    ; Переход к следующему столбцу
    inc r12
    cmp r12d, [rel cols_count]
    jl find_col_loop

        ; Вывод элемента
    lea rdi, [rel debug_pos]
    mov rsi, [rel cur_odd_count]
    mov eax, 0
    call printf wrt ..plt

    ; Переход к следующей строчке
    inc ebx
    cmp ebx, [rel rows_count]
    jl find_row_loop

    lea rdi, [rel pass]
    mov rax, 0
    call printf wrt ..plt

    lea rdi, [rel print_d_number]
    mov rsi, [rel max_odd_count]
    mov rax, 0
    call printf wrt ..plt

    lea rdi, [rel print_d_number]
    mov rsi, [rel max_odd_row]
    mov rax, 0
    call printf wrt ..plt

    ret


add_odd_count:
    mov eax, [rel cur_odd_count]
    inc eax
    mov [rel cur_odd_count], eax 
    ret

exit:
    ; Метка выходит из программы. В регистре RDI должен лежать нужный код возврата
    mov rax, 60
    syscall
