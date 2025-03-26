;  прямоугольная цифровая удалить строку с наибольшим количеством нечётных элементов
section .rodata
    input_rows_msg db ">Введите количество строк и стобцов в матрице через пробел: ", 0
    input_matrix_msg db "> Введите элементы матрицы через пробел:", 10, 0
    print_matrix_message db "Вывод матрицы без строки с наибольшим количеством нечетных элементов", 10, 0
    print_err_no_odd db "Нет ни одного нечетного числа", 10, 0
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
    ERR_NO_ODD: equ 3


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

    ; Ищем строку с максимальным количеством нечетных цифр
    call find_max_odd_row

    mov eax, [rel max_odd_count]
    cmp eax, 0
    je no_odd_number

    ; Удаляем эту строку
    call delete_row

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

    call check_odd
    
    ; Увеличивае счетчик введенных чисел
    mov eax, [rel cur_elements]
    inc eax
    mov [rel cur_elements], eax

    ; Переход к следующему столбцу
    inc r12
    cmp r12d, [rel cols_count]
    jl find_col_loop

    ; Замена 
    mov eax, [rel cur_odd_count]
    cmp eax, [rel max_odd_count]
    jle .no_update        ; CHECK  ; если cur_odd_count <= max_odd_count, не обновляем
    
    ; Обновляем max_odd_count и max_odd_row
    mov eax, [rel cur_odd_count]
    mov [rel max_odd_count], eax
    ; mov ebx, [current_row]
    mov [rel max_odd_row], ebx

.no_update:
    ; Переход к следующей строчке
    inc ebx
    cmp ebx, [rel rows_count]
    jl find_row_loop

    ; Выход
    ret

check_odd:
    ; Вход: RSI содержит число (младший байт - SIL)
    ; Выход: CF=1 если нечётное, CF=0 если чётное
    
    test sil, 1
    jnz .odd
    ret
.odd:
    mov eax, [rel cur_odd_count]
    inc eax
    mov [rel cur_odd_count], eax 

    ret
    
no_odd_number:
    lea rdi, [rel print_err_no_odd]
    mov rax, 0
    call printf wrt ..plt

    mov rdi, ERR_NO_ODD
    call exit


; Процедура удаляет строку с индексом max_odd_row из матрицы
; Не использует стек, работает только с регистрами
; Разрушаемые регистры: rax, rcx, rdx, rsi, rdi, r8, r9, r10, r11
delete_row: 
    call exit

    ; Проверяем max_odd_row на валидность
    mov ecx, [rel max_odd_row]
    cmp ecx, eax
    jae .end_proc           ; если max_odd_row >= rows_count, выходим

    ; Загружаем cols_count и вычисляем размер строки в байтах
    mov edx, [rel cols_count]
    shl rdx, 3              ; rdx = cols_count * 8 (размер строки в байтах)

    ; Вычисляем адреса для копирования
    mov rsi, [rel matrix]  ; rsi = начало матрицы
    mov rdi, rcx            ; rdi = max_odd_row
    imul rdi, rdx           ; rdi = смещение удаляемой строки
    add rsi, rdi            ; rsi = адрес удаляемой строки
    lea rdi, [rsi + rdx]    ; rdi = адрес следующей строки

    ; Вычисляем количество строк для перемещения
    mov r8d, [rel rows_count]
    sub r8d, ecx            ; r8d = rows_count - max_odd_row
    dec r8d                 ; r8d = количество строк для перемещения
    jle .update_counts      ; если нечего перемещать, переходим к обновлению счетчиков

    ; Вычисляем размер блока для копирования
    mov r9, r8
    imul r9, rdx            ; r9 = размер блока в байтах

    ; Копируем данные
    mov rcx, r9             ; rcx = количество байт для копирования
    rep movsb               ; копируем байты

.update_counts:
    ; Уменьшаем rows_count
    mov r10, [rel rows_count ]
    dec dword [r10]

    ; Обновляем elements_count
    mov eax, [r10]          ; eax = новый rows_count
    mov r11, [rel cols_count ]
    imul eax, [r11]
    mov [rel elements_count], eax

.end_proc:
    ret
exit:
    ; Метка выходит из программы. В регистре RDI должен лежать нужный код возврата
    mov rax, 60
    syscall
