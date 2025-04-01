;  прямоугольная цифровая удалить строку с наибольшим количеством нечётных элементов
section .note.GNU-stack noalloc noexec nowrite progbits

section .rodata    
    MAX_CAPACITY equ 9

section .bss
    ; Переменные для описания матрицы
    global rows_count, cols_count, matrix  ; Делаем переменные глобальные
    rows_count resb 1 ; Резервируем место (4 байта) перед переменную
    cols_count resb 1 ; REServes Dword (4 байта), 1 - Количество
    matrix resb 9 * 9

    ; Переменные для удаления строки с максимальным колвом нечетных чисел
    global max_odd_count, cur_odd_count, max_odd_row
    max_odd_count resb 1  ; максимальное количество нечётных
    cur_odd_count resb 1 ; Текущее количество нечетных чисел
    max_odd_row resb 1     ; строка с максимальным количеством нечётных


section .text
    global main, exit
    extern scanf, printf
    extern input_count, input_matrix, print_matrix, find_max_odd_row, delete_row
    extern err_input, err_range, err_empty_output, err_no_odd_number ; Экспортируем метки для вывода ошбок

main:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    ; Принимаем количество строк и столбцов
    call input_count

    ; Проверка на корректный ввод
    cmp eax, 2    ; CMP устанавливает ZF = 0, Если два операнда равны
    jne err_input ; Перейти если ZF = 0

    
    ; Проверка, на то что количество строк <= 9
    movzx eax, byte [rel rows_count]       
    cmp eax, MAX_CAPACITY ; Сравнение операнда с максимальной вместимостью
    jg err_range          ; (ZF = 0 && SF = OF) перейти, если больше eax > MAX_CAPACITY

    ; Проверка, на то что количество строк <= 9
    movzx eax, byte [rel cols_count]       
    cmp eax, MAX_CAPACITY ; Сравнение операнда с максимальной вместимостью
    jg err_range          ; (ZF = 0 && SF = OF) перейти, если больше eax > MAX_CAPACITY

    ; Принимаем элементы матрицы
    call input_matrix

    ; Ищем строку с максимальным количеством нечетных цифр
    call find_max_odd_row

    ; Проверка, если нет нечетных чисел
    movzx eax, byte [rel max_odd_count]
    cmp eax, 0
    je err_no_odd_number

    ; Удаляем эту строку
    call delete_row

    ; Печатаем получившуюся матрицу
    call print_matrix

    mov rsp, rbp
    pop rbp
    mov rdi, 0
    call exit




; Метка для завершения программы
exit:
    ; Метка выходит из программы. В регистре RDI должен лежать нужный код возврата
    mov rax, 60
    syscall
