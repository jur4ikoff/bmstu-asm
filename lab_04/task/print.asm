section .rodata
    print_matrix_message db "Вывод матрицы без строки с наибольшим количеством нечетных элементов", 10, 0
    newline db 10, 0 

    output_el_fmt  db "%hhd ", 9, 0
    

section .text
    global print_matrix
    extern printf
    extern cols_count, rows_count, matrix


print_matrix:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    lea rdi, [rel print_matrix_message]
    mov rax, 0
    call printf wrt ..plt

    ; Вывод матрицы
    mov ebx, 0 ; i = 0
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
    movzx eax, byte [rel cols_count]
    cmp r12d, eax
    jl print_col_loop

    lea rdi, [rel newline]
    mov eax, 0
    call printf wrt ..plt

    ; Переход к следующей строчке
    inc ebx
    movzx eax, byte [rel rows_count]
    cmp ebx, eax
    jl print_row_loop

    mov rsp, rbp
    pop rbp
    ret

