section .note.GNU-stack noalloc noexec nowrite progbits

section .rodata
    MAX_BUFFER_LEN equ 17

    prompt  db "> Введите беззнаковое 16-ти разрядное число в 2 с.с: ",10, 0
    prompt_len equ $ - prompt 

    separator db "       |       |", 10, 0
    separator_len equ $ - separator

    newline db 10, 0
    fmt db "%16s", 0

section .data
    buffer times 17 db 0  ; Явная инициализация нулями


section .text
    global input_number
    extern printf, scanf
    extern err_input
    extern number


input_number:
    ; Выравниваем стек
    push rbp
    mov rbp, rsp
    sub rsp, 16

    mov rax, 1
    mov rdi, 1
    lea rsi, [rel prompt]
    mov rdx, prompt_len
    syscall

    mov rax, 1
    mov rdi, 1
    lea rsi, [rel separator]
    mov rdx, separator_len
    syscall

    ; Читаем из stdin в буфер
    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    lea rsi, [rel buffer]
    mov rdx, MAX_BUFFER_LEN      
    syscall

    ; Преобразуем двоичную строку в число
    mov rax, 0        ; Очищаем rax для результата
    lea rsi, [rel buffer]
    mov rcx, 16         ; Максимальное количество бит

.convert_loop:
    ; Пробегаемся по каждому символу
    mov rdx, [rsi] 
    inc rsi             

    ; Проверяем на конец строки
    cmp dl, 10
    je .done
    cmp dl, 0       
    je .done

    ; Проверяем что символ '0' или '1'
    cmp dl, '0'
    jb err_input
    cmp dl, '1'
    ja err_input

    ; Преобразуем символ в бит
    sub dl, '0' ; Преобзрауем ASCII символ в числовое значение
    shl ax, 1           ; Сдвигаем текущий результат
    or al, dl           ; Добавляем новый бит
    loop .convert_loop

.done:
    ; Сохраняем результат в переменную number
    mov [rel number], ax

    mov rsp, rbp
    pop rbp
    ret
