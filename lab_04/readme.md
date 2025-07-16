# Изучаю x86-64 asm

## 0. Hello_world
## 1. Программа считывает из консоли 2 числа и складывает их
## 2. Задача по варианту
Прямоугольная матрица, удалить строку с наибольшим количеством нечётных элементов  
> Для меня это самая сложная лаба, потому что нас бросили во взрослую жизнь со словами "делайте что хотите, на чем хотите", все это после 16-битного ассемблера. На свою голову, я зачем-то полез в PIC-code и жестко позднал за `lea`.

```asm
section .data
    input_prompt db "Enter matrix element [%d][%d]: ", 0
    input_fmt    db "%d", 0
    output_fmt   db "%2d ", 0
    newline      db 10, 0

section .bss
    rows_count resd 1       ; Количество строк (4 байта)
    cols_count resd 1       ; Количество столбцов (4 байта)
    matrix     resd 9*9     ; Матрица 9x9 (81 элемент по 4 байта)

section .text
global main
extern printf, scanf

main:
    push rbp
    mov rbp, rsp

    ; Инициализация размеров (пример значений)
    mov dword [rel rows_count], 3   ; 3 строки
    mov dword [rel cols_count], 3   ; 3 столбца

    ; Ввод матрицы ---------------------------------------------------
    mov ebx, 0                      ; Счетчик строк (i)
.row_loop:
    mov ecx, 0                      ; Счетчик столбцов (j)
.col_loop:
    ; Вывод приглашения
    lea rdi, [rel input_prompt]
    mov esi, ebx
    mov edx, ecx
    xor eax, eax
    call printf wrt ..plt

    ; Ввод элемента
    lea rdi, [rel input_fmt]
    mov eax, ebx                    ; i
    imul eax, [rel cols_count]      ; i * cols_count
    add eax, ecx                    ; i * cols_count + j
    lea rsi, [rel matrix + eax*4]   ; Адрес matrix[i][j]
    xor eax, eax
    call scanf wrt ..plt

    inc ecx
    cmp ecx, [rel cols_count]
    jl .col_loop

    inc ebx
    cmp ebx, [rel rows_count]
    jl .row_loop

    ; Вывод матрицы --------------------------------------------------
    mov ebx, 0                      ; Счетчик строк (i)
.print_row_loop:
    mov ecx, 0                      ; Счетчик столбцов (j)
.print_col_loop:
    ; Вывод элемента
    lea rdi, [rel output_fmt]
    mov eax, ebx                    ; i
    imul eax, [rel cols_count]      ; i * cols_count
    add eax, ecx                    ; i * cols_count + j
    mov esi, [rel matrix + eax*4]   ; matrix[i][j]
    xor eax, eax
    call printf wrt ..plt

    inc ecx
    cmp ecx, [rel cols_count]
    jl .print_col_loop

    ; Переход на новую строку
    lea rdi, [rel newline]
    xor eax, eax
    call printf wrt ..plt

    inc ebx
    cmp ebx, [rel rows_count]
    jl .print_row_loop

    ; Завершение программы --------------------------------------------
    xor eax, eax
    pop rbp
    ret
```