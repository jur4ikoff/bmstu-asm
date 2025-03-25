section .rodata
    input_rows_msg db ">Введите количество строк и стобцов в матрице через пробел: ", 0
    input_matrix_msg db "> Введите элементы матрицы через пробел:", 10, 0
    print_matrix_message db "Вывод матрицы на экран", 10, 0
    newline db 10, 0  
    pass db "PASS", 10, 0
    separator db "---------------", 10, 0
    new db "newline", 10, 0


    input_err_msg db "Ошибка ввода числа", 10, 0
    range_err_msg db "Ошибка, размер матрицы должен лежать в диапазоне [1, 9]", 10, 0
    ok_msg db "Успешный ввод", 10, 0
    finish_input_msg db "> Ввод матрицы законечен.", 10, "-------------------------------------------", 10, 0
    
    


    
    input_number_fmt db "%d %d", 0
    input_el_fmt db "%hhd", 0
    output_number_fmt db "%d", 10, 0
    flags_msg db "Flags: CF=%d, ZF=%d, SF=%d", 10, 0
    output_el_fmt  db "%hhd ", 10, 0
    debug_pos db "%d %d", 10, 0

    MAX_CAPACITY: equ 9;

    ERR_INPUT_NUMBER: equ 1
    ERR_RANGE: equ 2


section .bss
    rows_count: resd 1 ; Резервируем место (4 байта) перед переменную
    cols_count resd 1 ; REServes Dword (4 байта), 1 - Количество
    elements_count rest 1
    elements_entered rest 1

    matrix resq 9 * 9


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
    mov eax, [rel cols_count]           
    cmp eax, MAX_CAPACITY
    jg err_range   

    ; Считаем общее количество элементов
    mov eax, [rel rows_count]
    imul eax, [rel cols_count]
    mov [rel elements_count], eax

    ; Приглашение к вводу
    lea rdi, [rel input_matrix_msg]
    mov rax,0 
    call printf wrt ..plt

    ; Инициализация нулем
    mov dword [rel elements_entered], 0

    mov ebx, 0 ; i = 0
input_row_loop:
    mov ecx, 0 ; j = 0
input_col_loop:
    ; Проверяем, не введено ли уже rows*cols чисел
    mov eax, [rel elements_entered]
    mov edx, [rel elements_count]
    cmp eax, edx
    jge input_finished 

    ; Вычисляем адрес matrix[i][j]
    mov eax, ebx ; eax = i
    mov edx, [rel cols_count]
    imul eax, edx ; eax = i * cols_count
    add eax, ecx ; eax = i * cols_count + j
    lea r8, [rel matrix]
    lea rsi, [r8 + rax] ; rsi = &matrix[i][j]

    ; Ввод элемента
    lea rdi, [rel input_el_fmt]
    mov eax, 0
    call scanf wrt ..plt

    cmp eax, 1
    jne input_err

    ; Увеличивае счетчик введенных чисел
    mov eax, [rel elements_entered]
    inc eax
    mov [rel elements_entered], eax

    ; Переход к следующему столбцу
    inc ecx
    cmp ecx, [rel cols_count]
    jl input_col_loop

    ; Переход к следующей строчке
    inc ebx
    cmp ebx, [rel rows_count]
    jl input_row_loop


input_finished:
    lea rdi, [rel finish_input_msg]
    mov rax,0 
    call printf wrt ..plt

    call print_matrix
    mov rsp, rbp
    pop rbp

    mov rdi, 0
    call exit


print_matrix:
        ; Вывод матрицы
    mov ebx, 0 ; i = 0
    mov [rel elements_entered], ebx
print_row_loop:
    mov ecx, 0 ; j = 0
print_col_loop:
    ; Проверяем, не введено ли уже rows*cols чисел
    push rcx 
    lea rdi, [rel debug_pos]
    mov eax, 0
    mov esi, ebx
    mov edx, ecx 
    call printf wrt ..plt
    pop rcx

    mov eax, [rel elements_entered]
    mov edx, [rel elements_count]
    cmp eax, edx
    jge print_end 

    ; Вычисляем адрес matrix[i][j]
    mov eax, ebx ; eax = i
    mov edx, [rel cols_count]
    imul eax, edx ; eax = i * cols_count
    add eax, ecx ; eax = i * cols_count + j
    lea r8, [rel matrix]
    mov rsi, [r8 + rax] ; rsi = &matrix[i][j]

    push rcx
    ; Ввод элемента
    lea rdi, [rel output_el_fmt]
    mov eax, 0
    call printf wrt ..plt
    pop rcx

    ; Увеличивае счетчик введенных чисел
    mov eax, [rel elements_entered]
    inc eax
    mov [rel elements_entered], eax

    ; Переход к следующему столбцу
    inc ecx


    push rcx 
    lea rdi, [rel separator]
    mov eax, 0
    call printf wrt ..plt
    pop rcx


    cmp ecx, [rel cols_count]
    jl print_col_loop

    push rcx
    lea rdi, [rel newline]
    mov eax, 0
    call printf wrt ..plt
    pop rcx

    ; Переход к следующей строчке
    inc ebx
    cmp ebx, [rel rows_count]
    jl print_row_loop


print_end:
    lea rdi, [rel finish_input_msg]
    mov rax,0 
    call printf wrt ..plt

    mov rdi, 0;
    mov rax, 60
    syscall


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
    

exit:
    ; Метка выходит из программы. В регистре RDI должен лежать нужный код возврата
    mov rax, 60
    syscall
    