section .rodata
    input_rows_msg db ">Введите количество строк и стобцов в матрице через пробел: ", 0
    input_err_msg db "Ошибка ввода числа", 10, 0
    input_matrix_msg db "> Введите элементы матрицы через пробел:", 10, 0
    
    input_number_fmt db "%d %d", 0
    input_el_fmt db "%d", 0
    output_number_fmt db "%d", 10, 0

    MAX_CAPACITY db 9;

    ERR_INPUT_NUMBER db 1


section .bss
    rows_count resd 1 ; Резервируем место (4 байта) перед переменную
    cols_count resd 1 ; REServes Dword (4 байта), 1 - Количество

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

    mov rax, 0
    lea rdi, [rel  input_matrix_msg] 
    call printf wrt ..plt

    mov ebx, 0
.row_loop:
    mov ecx, 0
.col_loop:
    lea rdi, [rel input_el_fmt]
    mov eax, ebx  


 

    mov rax, 0 ; exit-code
    mov rsp, rbp  ; Восстанавливаем указатель стека
    pop rbp  ; Восстанавливаем предыдущее значение rbp
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

    mov rdi, [rel ERR_INPUT_NUMBER]
    jmp exit;
    

exit:
    ; Метка выходит из программы. В регистре RDI должен лежать нужный код возврата
    mov rax, 60
    syscall
    