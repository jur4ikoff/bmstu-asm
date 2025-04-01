
section .rodata
    input_number_fmt db "%hhd %hhd", 0
    input_el_fmt db "%hhd", 0

    input_rows_msg db ">Введите количество строк и стобцов в матрице через пробел: ", 0
    input_matrix_msg db "> Введите элементы матрицы через пробел:", 10, 0

    finish_input_msg db "> Ввод матрицы законечен.", 10, "-------------------------------------------", 10, 0





section .text
    global input_count, input_matrix
    extern printf, scanf ; "Импортируем функии из glibc"
    extern rows_count, cols_count, matrix  ; "Импортируем глобальные переменные"
    extern err_input

; Процедура принимает из stdin 2 целых числа, количество строк и столбцов матрицы
input_count:
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
    
    ; Возврат из метки
    mov rsp, rbp
    pop rbp
    ret



; Функция принимает элементы матрицы
input_matrix:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    ; Приглашение к вводу
    lea rdi, [rel input_matrix_msg]
    mov rax,0 
    call printf wrt ..plt

    ; Инициализация нулем
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
    jne err_input

    ; Переход к следующему столбцу
    inc r12
    movzx eax, byte [rel cols_count]
    cmp r12d, eax
    jl input_col_loop

    ; Переход к следующей строчке
    inc ebx
    movzx eax, byte [rel rows_count]
    cmp ebx, eax
    jl input_row_loop

    lea rdi, [rel finish_input_msg]
    mov rax,0 
    call printf wrt ..plt

    mov rsp, rbp
    pop rbp
    ret