section .rodata
    input_rows_msg db ">Введите количество строк и стобцов в матрице через пробел: ", 0
    input_err_msg db ">"
    
    input_number_fmt db "%d %d", 0;
    output_number_fmt db "%d", 10, 0;

    MAX_CAPACITY db 9;


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

    call input

    mov rax, 0 ; exit-code
    mov rsp, rbp  ; Восстанавливаем указатель стека
    pop rbp  ; Восстанавливаем предыдущее значение rbp
    ret
   
input:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    ; Первое приглашение к вводу 
    lea rdi, [rel input_rows_msg]
    mov eax, 0
    call printf wrt ..plt

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
    
    