section .rodata
    input_rows_msg: db "> Введите количество строк и столбцов в матрице через пробел: ", 0
    input_err_msg: db "Ошибка ввода числа", 10, 0
    input_matrix_msg: db "> Введите элементы матрицы через пробел:", 10, 0
    input_overflow_msg: db "> Введено достаточно чисел. Остальные данные игнорируются.", 10, 0
    
    input_number_fmt: db "%d %d", 0
    input_el_fmt: db "%d", 0
    output_number_fmt: db "%d", 10, 0

    MAX_CAPACITY: equ 9  ; Максимальный размер матрицы

section .bss
    rows_count: resd 1    ; Количество строк (32 бита)
    cols_count: resd 1    ; Количество столбцов (32 бита)
    elements_entered: resd 1 ; Счётчик введённых элементов
    matrix: resd 9 * 9    ; Матрица 9x9 (32-битные числа)

section .text
    global main:function
    extern scanf, printf

main:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    ; Ввод rows_count и cols_count
    lea rdi, [rel input_number_fmt]
    lea rsi, [rel rows_count]
    lea rdx, [rel cols_count]
    xor eax, eax
    call scanf wrt ..plt

    ; Проверка, что введено 2 числа
    cmp eax, 2
    jne input_err

    ; Проверка, что размеры матрицы <= 9
    mov eax, [rel rows_count]
    cmp eax, MAX_CAPACITY
    ja input_err
    mov eax, [rel cols_count]
    cmp eax, MAX_CAPACITY
    ja input_err

    ; Вычисляем общее количество элементов (rows * cols)
   ; mov eax, [rel rows_count]
    ;mov edx, [rel cols_count]   ; Загружаем cols_count в регистр
    ;imul eax, edx               ; Умножаем
    ;mov [rel elements_entered], eax

    ; Вывод приглашения для ввода матрицы
    lea rdi, [rel input_matrix_msg]
    xor eax, eax
    call printf wrt ..plt

    ; Обнуляем счётчик введённых чисел
    mov dword [rel elements_entered], 0

    ; Ввод матрицы
    xor ebx, ebx                  ; i = 0
row_loop:
    xor ecx, ecx                  ; j = 0
col_loop:
    ; Проверяем, не введено ли уже rows*cols чисел
    mov eax, [rel elements_entered]
    mov edx, [rel rows_count]
    imul edx, [rel cols_count]
    cmp eax, edx
    jge input_finished

    ; Вычисляем адрес matrix[i][j]
    mov eax, ebx                 ; eax = i
    mov edx, [rel cols_count]    ; Загружаем cols_count в регистр
    imul eax, edx                ; eax = i * cols_count
    add eax, ecx                 ; eax = i * cols_count + j
    lea r8, [rel matrix]  
    lea rsi, [r8 + rax*4] ; rsi = &matrix[i][j]

    ; Ввод элемента
    lea rdi, [rel input_el_fmt]
    xor eax, eax
    call scanf wrt ..plt

    ; Проверка успешности scanf
    cmp eax, 1
    jne input_err

    ; Увеличиваем счётчик введённых чисел
    mov eax, [rel elements_entered]
    inc eax
    mov [rel elements_entered], eax

    ; Переход к следующему столбцу
    inc ecx
    cmp ecx, [rel cols_count]
    jl col_loop

    ; Переход к следующей строке
    inc ebx
    cmp ebx, [rel rows_count]
    jl row_loop

input_finished:
    ; Сообщение о завершении ввода
    lea rdi, [rel input_overflow_msg]
    xor eax, eax
    call printf wrt ..plt

    ; Выход
    xor eax, eax
    mov rsp, rbp
    pop rbp
    ret

input_err:
    lea rdi, [rel input_err_msg]
    xor eax, eax
    call printf wrt ..plt
    mov eax, 1
    mov rsp, rbp
    pop rbp
    ret