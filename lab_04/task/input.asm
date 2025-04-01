
section .rodata
    input_number_fmt db "%d %d", 0
    input_rows_msg db ">Введите количество строк и стобцов в матрице через пробел: ", 0



section .text
    global input_count
    extern printf, scanf ; "Импортируем функии из glibc"
    extern rows_count, cols_count  ; "Импортируем глобальные переменные"

; Процедура принимает из stdin 2 целых числа, количество строк и столбцов матрицы
input_count:
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
    
    ; Возврат из метки
    mov rsp, rbp
    pop rbp
    ret
