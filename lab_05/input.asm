section .note.GNU-stack noalloc noexec nowrite progbits

section .rodata
    MAX_BUFFER_LEN equ 17

section .data
    prompt  db "> Введите беззнаковое 16-ти разрядное число в 2 с.с: ", 0
    prompt_len equ $ - prompt 

    test_out db "test", 10, 0
    newline db 10, 0
    fmt db "%16s", 0

    input_buffer times 17 db 0  ; Явная инициализация нулями


section .text
    global input_number
    extern printf, scanf
    extern err_input
    extern number


input_number:
    ; Выравниваем стек
    push rbp
    mov rbp, rsp
    sub rsp, 32       ; Выделяем место в стеке для буфера (больше чем нужно)

    ; Читаем из stdin
    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    lea rsi, [rsp]      ; Буфер в стеке (используем lea)
    mov rdx, 17         ; Максимальная длина (16 символов + \n)
    syscall

    ; Преобразуем двоичную строку в число
    xor rax, rax        ; Очищаем rax для результата
    lea rsi, [rsp]      ; Адрес буфера (используем lea)
    mov rcx, 16         ; Максимальное количество бит

.convert_loop:
    movzx rdx, byte [rsi] ; Загружаем символ
    inc rsi              ; Переходим к следующему символу

    ; Проверяем на конец строки
    cmp dl, 0xA          ; \n
    je .done
    cmp dl, 0x0          ; \0
    je .done

    ; Проверяем что символ '0' или '1'
    cmp dl, '0'
    jb err_input
    cmp dl, '1'
    ja err_input

    ; Преобразуем символ в бит
    sub dl, '0'
    shl ax, 1           ; Сдвигаем текущий результат
    or al, dl           ; Добавляем новый бит
    loop .convert_loop

.done:
    ; Сохраняем результат в переменную number
    mov [rel number], ax
    movzx rsi, ax

    mov rsp, rbp
    pop rbp
    ret