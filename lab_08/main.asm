section .data
    ; Константы
    window_title db "GTK Assembly App", 0
    message_fmt db "Ближайшая степень двойки %lld : 2^%lld = %lld", 0
    res_window_title db "Результат", 0
    width equ 400
    height equ 200
    label_text db "Enter text:", 0
    button_text db "Print Text", 0
    error_title db "Ошибка", 0
    
    ; Формат для printf
    printf_format db "number: %llu", 10, 0
    ; test db "%"
    
    ; Имена сигналов GTK
    signal_destroy db "destroy", 0
    signal_clicked db "clicked", 0

        ; Заголовки GTK
    parent_window dq 0       ; Указатель на родительское окно (может быть NULL)
    flags        dd 0        ; Флаги диалога (GTK_DIALOG_MODAL и т.д.)
    type         dd 0        ; Тип сообщения (GTK_MESSAGE_INFO, GTK_MESSAGE_WARNING и т.д.)
    buttons      dd 1        ; Кнопки (GTK_BUTTONS_OK, GTK_BUTTONS_YES_NO и т.д.)
    title        db "Пример диалога", 0
    
    signal_name     db "response", 0  ; Сигнал, который ловим (нажатие кнопки)
        ; Константы GTK
    GTK_WINDOW_TOPLEVEL dq 0
    GTK_MESSAGE_INFO dq 0
    GTK_BUTTONS_OK dq 0
    GTK_RESPONSE_OK dq 0


section .bss
    ; Глобальные переменные
    window resq 1
    grid resq 1
    button resq 1
    label resq 1
    entry resq 1

    number resq 1
    degree resq 1

section .rodata
    message      db "Привет, это GTK MessageBox!", 0
    err_number_msg db "Ошибка, нужно ввести беззнаковое число", 10, 0

section .text
    ; Объявления функций GTK
    extern gtk_init
    extern gtk_window_new
    extern gtk_window_set_title
    extern gtk_window_set_default_size
    extern g_signal_connect_data
    extern gtk_grid_new
    extern gtk_container_add
    extern gtk_label_new
    extern gtk_grid_attach
    extern gtk_entry_new
    extern gtk_button_new_with_label
    extern gtk_widget_show_all, gtk_widget_show
    extern gtk_main
    extern gtk_main_quit
    extern gtk_entry_get_text, gtk_message_dialog_new, gtk_widget_destroy   
    extern printf, strtoll
    extern gtk_window_get_type, g_type_check_instance_cast, gtk_widget_destroyed, pow

    global main

find_greater_degree_of_two:
    ; Число в rdi
    ; ret в rax
    push rbp
    mov rbp, rsp

    mov rcx, 0
    mov rdx, 1

    cmp rdx, rdi
    jge find_exit
find_loop:
    inc rcx
    shl rdx, 1
    cmp rdx, rdi
    jl find_loop

    mov rax, rcx
find_exit:
    mov rsp, rbp
    pop rbp
    ret

pow_2:
    ; rdi - degree (must be < 64)
    ; return in rax
    
    ; пролог
    push rbp
    mov rbp, rsp

    cmp rdi, 63
    ja .overflow

    mov rcx, rdi
    mov rax, 1
    jrcxz .done       ; если rcx == 0, пропустить цикл
.pow_loop:
    shl rax, 1

    dec rcx
    cmp rcx, 0
    jg .pow_loop

.done:
    ; эпилог
    mov rsp, rbp
    pop rbp    
    ret
.overflow:
    xor rax, rax
    mov rsp, rbp
    pop rbp
    ret

; Обработчик сигнала (вызывается при нажатии кнопки)
on_dialog_response:
    push rbp
    mov rbp, rsp

    ; rdi - диалоговое окно (автоматически передается)
    call gtk_widget_destroy

    mov rsp, rbp
    pop rbp
    ret

create_result_dialog:
    ; Функция создает диалоговое окно с результатом
    ; Входные параметры:
    ;   rdi - degree (степень)
    ;   rsi - 1LL << degree (результат)

    push rbp
    mov rbp, rsp
    sub rsp, 32      ; Выравнивание стека + место для аргументов

    ; Сохраняем входные параметры
    mov [rbp-8], edi   ; Сохраняем degree
    mov [rbp-16], rsi  ; Сохраняем (1LL << degree)

    ; Создаем диалоговое окно
    xor rdi, rdi                   ; parent = NULL
    mov esi, 1                     ; GTK_DIALOG_MODAL
    mov edx, 0                     ; GTK_MESSAGE_INFO
    mov ecx, 2                     ; GTK_BUTTONS_OK
    lea r8, [rel message_fmt]      ; Форматная строка
    mov r9d, [rbp-8]               ; degree (первый %d)
    mov eax, [rbp-8]                ; degree (второй %d)
    mov rdx, [rbp-16]               ; (1LL << degree) (%lld)

    ; Помещаем дополнительные аргументы в стек
    push rdx                       ; 6-й аргумент
    push rax                       ; 5-й аргумент
    push r9                        ; 4-й аргумент
    call gtk_message_dialog_new
    add rsp, 24                    ; Очищаем стек от аргументов
    mov [rbp-24], rax              ; Сохраняем указатель на диалог

    ; Устанавливаем заголовок окна
    mov rdi, [rbp-24]              ; Указатель на диалог
    lea rsi, [rel res_window_title]    ; Заголовок окна
    call gtk_window_set_title

    ; Подключаем обработчик сигнала
    mov rdi, [rbp-24]              ; Указатель на диалог
    lea rsi, [rel signal_name]    ; Имя сигнала "response"
    lea rdx, [rel on_dialog_response] ; Функция-обработчик
    xor rcx, rcx                   ; user_data = NULL
    xor r8, r8                     ; notify = NULL
    xor r9, r9                     ; GConnectFlags = 0
    call g_signal_connect_data

    ; Показываем диалог
    mov rdi, [rbp-24]
    call gtk_widget_show_all

    leave
    ret

create_err_dialog:
    ; rdi - text
    ; rsi - type

    push rbp
    mov rbp, rsp 
    sub rsp, 16

    
    ; Создаем диалог
    xor r9, r9
    mov r8, rdi ; text
    mov rcx, [rel buttons]          ; Кнопки (GTK_BUTTONS_OK)
    mov rdx, rsi ; Тип сообщения (GTK_MESSAGE_INFO)
    mov rsi, 3           ; Флаги (0)
    mov rdi, 0   ; Родительское окно (NULL)
    call gtk_message_dialog_new
    
    mov [rbp - 8], rax

    mov rdi, rax
    lea rsi, [rel error_title]
    call gtk_window_set_title

    ; Подключаем обработчик сигнала "response" (нажатие кнопки)
    mov rdi, [rbp - 8]                ; Диалог (GtkDialog*)
    lea rsi, [rel signal_name]        ; "response" (сигнал)
    lea rdx, [rel on_dialog_response] ; Обработчик
    xor rcx, rcx                ; user_data (NULL)
    xor r8, r8                  ; Уведомитель (NULL)
    xor r9, r9                  ; Флаги (0)
    call g_signal_connect_data

    mov rax, [rbp - 8]
    ; Показываем диалог
    mov rdi, rax
    call gtk_widget_show
    
    mov rsp, rbp
    pop rbp
    ret

err_number:
    lea rdi, [rel err_number_msg]
    xor rax, rax
    call printf wrt ..plt


    xor rax, rax
    lea rdi, [rel err_number_msg]        
    mov rsi, 3
    call create_err_dialog

    jmp on_button_clicked_end

; Функция обратного вызова для кнопки
on_button_clicked:
    push rbp
    mov rbp, rsp
    sub rsp, 32
    
    ; Первый аргумент (rdi) - это кнопка, второй (rsi) - user_data (наш entry)
    mov rdi, rsi          ; Получаем entry из user_data
    call gtk_entry_get_text
    
    mov qword [rbp-8], 0 ; end = NULL
    ; long long number = strtoll(text, &end, 10);
    mov rdi, rax
    lea rsi, [rbp - 8]
    mov rdx, 10
    call strtoll

    mov [number], rax

    ; Проверки
    ; Проверяем *end != 0 
    mov rcx, [rbp - 8]
    cmp byte [rcx], 0
    jne err_number
    ; Проверяем number < 0
    cmp qword [number], 0
    jl err_number

    mov rdi, [rel number]
    call find_greater_degree_of_two
    mov [rel degree], rax    

    mov rdi, [rel degree]
    call pow_2
    
    mov rdi, [rel degree]
    mov rsi, rax
    call create_result_dialog






on_button_clicked_end:
    mov rsp, rbp
    pop rbp
    ret

main:
    push rbp
    mov rbp, rsp
    and rsp, -16          ; Выравнивание стека
    
    ; Инициализация GTK
    xor rdi, rdi
    xor rsi, rsi
    call gtk_init
    
    ; Создание окна
    mov rdi, 0
    call gtk_window_new
    mov [window], rax
    
    ; Настройка окна
    mov rdi, [window]
    lea rsi, [window_title]
    call gtk_window_set_title
    
    mov rdi, [window]
    mov rsi, width
    mov rdx, height
    call gtk_window_set_default_size
    
        ; Подключение сигнала "destroy" для закрытия окна
    mov   rdi, [rel window]        ; указатель на окно
    lea   rsi, [rel signal_destroy] ; имя сигнала "destroy"
    mov   rdx, gtk_main_quit ; обработчик
    xor rcx, rcx
    xor   r8, r8          ; уведомитель
    xor   r9, r9          ; флаги
    call  g_signal_connect_data

    ; Создание сетки
    call gtk_grid_new
    mov [grid], rax
    
    ; Добавление сетки в окно
    mov rdi, [window]
    mov rsi, [grid]
    call gtk_container_add
    
    ; Создание метки
    lea rdi, [label_text]
    call gtk_label_new
    mov [label], rax
    
    ; Добавление метки
    mov rdi, [grid]
    mov rsi, [label]
    xor rdx, rdx
    xor rcx, rcx
    mov r8, 1
    mov r9, 1
    call gtk_grid_attach
    
    ; Создание поля ввода
    call gtk_entry_new
    mov [entry], rax
    
    ; Добавление поля ввода
    mov rdi, [grid]
    mov rsi, [entry]
    mov rdx, 1
    xor rcx, rcx
    mov r8, 1
    mov r9, 1
    call gtk_grid_attach
    
    ; Создание кнопки
    lea rdi, [button_text]
    call gtk_button_new_with_label
    mov [button], rax
    
    ; Добавление кнопки
    mov rdi, [grid]
    mov rsi, [button]
    xor rdx, rdx
    mov rcx, 1
    mov r8, 2
    mov r9, 1
    call gtk_grid_attach
    

    ; Подключение сигнала clicked с передачей entry как user_data
    mov rdi, [button]
    lea rsi, [signal_clicked]
    mov rdx, on_button_clicked
    mov rcx, [entry]      ; user_data
    xor r8, r8
    xor r9, r9
    call g_signal_connect_data
    
    ; Показать все виджеты
    mov rdi, [window]
    call gtk_widget_show_all
    
    ; Главный цикл
    call gtk_main
    
    ; Выход
    xor eax, eax


    mov rsp, rbp
    pop rbp
    mov rdi, 0

exit:
    ; rdi - exitcode
    mov rax, 60
    syscall