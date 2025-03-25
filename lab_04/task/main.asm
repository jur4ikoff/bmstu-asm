section .rodata
    input_rows_msg db ">Введите количество строк и стобцов в матрице через пробел: ", 0
    input_err_msg db "Ошибка ввода числа", 10, 0
    input_matrix_msg db "> Введите элементы матрицы через пробел:", 10, 0
    ok_msg db "Успешный ввод", 10, 0
    input_overflow_msg db "> Введено достаточно чисел. Остальные данные игнорируются.", 10, 0

    
    input_number_fmt db "%d %d", 0
    input_el_fmt db "%d", 0
    output_number_fmt db "%d", 10, 0

    MAX_CAPACITY db 9;

    ERR_INPUT_NUMBER db 1


section .bss
    rows_count resd 1 ; Резервируем место (4 байта) перед переменную
    cols_count resd 1 ; REServes Dword (4 байта), 1 - Количество
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
  ; Проверка, что размеры матрицы <= 9
    mov eax, [rel rows_count]
    cmp eax, MAX_CAPACITY
    ja input_err
    mov eax, [rel cols_count]
    cmp eax, MAX_CAPACITY
    ja input_err

    ; Вычисляем общее количество элементов (rows * cols)
    mov eax, [rel rows_count]
    imul eax, [rel cols_count]
    mov [rel elements_entered], eax  ; Запоминаем, сколько чисел нужно ввести

    ; Вывод приглашения для ввода матрицы
    lea rdi, [rel input_matrix_msg]
    xor eax, eax
    call printf wrt ..plt

    ; Обнуляем счётчик введённых чисел
    mov dword [rel elements_entered], 0

    ; Ввод матрицы
    xor ebx, ebx                  ; i = 0 (индекс строки)
row_loop:
    xor ecx, ecx                  ; j = 0 (индекс столбца)
col_loop:
    ; Проверяем, не введено ли уже rows_count * cols_count чисел
    mov eax, [rel elements_entered]
    cmp eax, [rel rows_count]
    imul eax, [rel cols_count]
    jge input_finished           ; Если введено достаточно чисел, завершаем ввод

    ; Вычисляем адрес matrix[i][j] = matrix + (i * cols_count + j) * 4
    mov eax, ebx                 ; eax = i
    lea edx, [rel cols_count]  ; edx = cols_count (теперь без RIP-relative в imul)
    imul eax, [edx]   ; eax = i * cols_count
    add eax, ecx       
    mov rsi, [rel matrix]         ; eax = i * cols_count + j
    lea rsi, [rsi + rax*4] ; rsi = &matrix[i][j]

    ; Ввод элемента
    lea rdi, [rel input_el_fmt]
    xor eax, eax
    call scanf wrt ..plt

    ; Проверка успешности scanf (eax == 1)
    cmp eax, 1
    jne input_err

    ; Увеличиваем счётчик введённых чисел
    mov eax, [rel elements_entered]
    inc eax
    mov [rel elements_entered], eax

    ; Увеличиваем j и проверяем условие выхода из цикла
    inc ecx
    cmp ecx, [rel cols_count]    ; j < cols_count?
    jl col_loop

    ; Увеличиваем i и проверяем условие выхода из цикла
    inc ebx
    cmp ebx, [rel rows_count]    ; i < rows_count?
    jl row_loop

input_finished:
    ; Выводим сообщение, если введено достаточно чисел
    lea rdi, [rel input_overflow_msg]
    xor eax, eax
    call printf wrt ..plt

    ; Вывод матрицы (можно добавить позже)

    ; Выход с кодом 0
    xor eax, eax
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
    lea rdi, [rel ok_msg]
    mov rax, 0
    call printf wrt ..plt

    mov rdi, [rel ERR_INPUT_NUMBER]
    jmp exit;
    

exit:
    ; Метка выходит из программы. В регистре RDI должен лежать нужный код возврата
    mov rax, 60
    syscall
    