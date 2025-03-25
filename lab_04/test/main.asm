section .data
    prompt_rows db "Enter number of rows (1-9): ", 0
    prompt_cols db "Enter number of columns (1-9): ", 0
    prompt_matrix db "Enter matrix elements (one byte each, separated by whitespace):", 10, 0
    newline db 10, 0
    space db " ", 0
    scan_fmt db "%d", 0
    scan_byte_fmt db "%hhu", 0

section .bss
    rows resd 1
    cols resd 1
    matrix resb 81  ; 9x9 = 81 байт

section .text
    global main
    extern printf, scanf, exit

main:
    ; Ввод количества строк
    mov rdi, prompt_rows
    xor eax, eax
    call printf
    mov rdi, scan_fmt
    mov rsi, rows
    xor eax, eax
    call scanf

    ; Ввод количества столбцов
    mov rdi, prompt_cols
    xor eax, eax
    call printf
    mov rdi, scan_fmt
    mov rsi, cols
    xor eax, eax
    call scanf

    ; Проверка на корректность размеров (1-9)
    mov eax, [rows]
    cmp eax, 1
    jl exit_error
    cmp eax, 9
    jg exit_error

    mov eax, [cols]
    cmp eax, 1
    jl exit_error
    cmp eax, 9
    jg exit_error

    ; Приглашение для ввода матрицы
    mov rdi, prompt_matrix
    xor eax, eax
    call printf

    ; Чтение матрицы
    xor ebx, ebx  ; индекс строки (i)
    mov r12d, [cols]  ; сохраняем cols в регистре

read_rows:
    cmp ebx, [rows]
    je print_matrix  ; если все строки прочитаны, переходим к выводу

    xor ecx, ecx  ; индекс столбца (j)

read_cols:
    cmp ecx, r12d
    je next_row

    ; Вычисление адреса элемента matrix[i][j]
    mov eax, ebx
    mul r12d        ; i * cols_per_row
    add eax, ecx    ; + j
    movsxd rax, eax ; расширяем до 64 бит
    mov rdi, scan_byte_fmt
    lea rsi, [matrix + rax]
    xor eax, eax
    call scanf

    inc ecx
    jmp read_cols

next_row:
    inc ebx
    jmp read_rows

print_matrix:
    mov rdi, newline
    xor eax, eax
    call printf  ; новая строка перед выводом матрицы

    xor ebx, ebx  ; индекс строки (i)

print_rows:
    cmp ebx, [rows]
    je exit_program

    xor ecx, ecx  ; индекс столбца (j)

print_cols:
    cmp ecx, [cols]
    je print_newline

    ; Вычисление адреса элемента matrix[i][j]
    mov eax, ebx
    mul dword [cols]  ; i * cols_per_row
    add eax, ecx      ; + j
    movsxd rax, eax   ; расширяем до 64 бит
    movzx edi, byte [matrix + rax]

    ; Вывод числа
    push rbx
    push rcx
    mov rsi, rdi
    mov rdi, scan_byte_fmt
    xor eax, eax
    call printf
    mov rdi, space
    xor eax, eax
    call printf
    pop rcx
    pop rbx

    inc ecx
    jmp print_cols

print_newline:
    mov rdi, newline
    xor eax, eax
    call printf
    inc ebx
    jmp print_rows

exit_error:
    mov rdi, 1
    call exit

exit_program:
    mov rdi, 0
    call exit