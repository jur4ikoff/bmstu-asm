section .rodata
    input_rows_msg db ">Введите количество строк и стобцов в матрице через пробел: ", 0
    input_matrix_msg db "> Введите элементы матрицы через пробел:", 10, 0

    input_err_msg db "Ошибка ввода числа", 10, 0
    range_err_msg db "Ошибка, размер матрицы должен лежать в диапазоне [1, 9]", 10, 0
    ok_msg db "Успешный ввод", 10, 0
    input_overflow_msg db "> Введено достаточно чисел. Остальные данные игнорируются.", 10, 0
    


    
    input_number_fmt db "%d %d", 0
    input_el_fmt db "%d", 0
    output_number_fmt db "%d", 10, 0
    flags_msg db "Flags: CF=%d, ZF=%d, SF=%d", 10, 0

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

    mov dword [rel elements_entered], 0

    lea rdi, [rel output_number_fmt]
    mov rsi, [rel elements_count]
    mov rax,0 
    call printf wrt ..plt

    
    mov rsp, rbp
    pop rbp
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
    