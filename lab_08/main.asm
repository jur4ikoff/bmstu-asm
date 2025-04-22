; Программа находит ближайшее сверху число, степень двойки
section .note.GNU-stack noalloc noexec nowrite progbits

section .bss
    ; Глобальные переменные
    window resq 1 ; Переменная хранит окно
    grid resq 1
    button resq 1
    label resq 1
    entry resq 1

    number resq 1
    degree resq 1

section .rodata
    window_title db "Попов Ю.А. ЛР8 МЗЯП", 0

    ; Названия сигналов GTK
    signal_destroy  db "destroy", 0
    signal_clicked  db "clicked", 0
    signal_response db "response", 0 

    err_number_msg db "Ошибка, нужно ввести беззнаковое число", 10, 0
    
    label_text db "Введите число", 0
    button_text db "Найти ближайшую сверху степень 2", 0

    error_title db "Ошибка", 0
    res_window_title db "Результат", 0

    message_fmt db "Ближайшая степень двойки сверху %lld : 2^%lld = %lld", 0

    WINDOW_WIDTH equ 300
    WINDOW_HEIGHT equ 100

   ; Заголовки GTK
    GTK_PARENT        dq 0       ; Указатель на родительское окно (может быть NULL)
    GTK_DIALOG_MODAL  db 0        ; Флаги диалога (GTK_DIALOG_MODAL и т.д.)
    GTK_MESSAGE_INFO  db 0        ; Тип сообщения (GTK_MESSAGE_INFO, GTK_MESSAGE_WARNING и т.д.)
    GTK_MESSAGE_ERROR db 0        ; Тип сообщения (GTK_MESSAGE_INFO, GTK_MESSAGE_WARNING и т.д.)
    GTK_BUTTONS_OK    db 1        ; Кнопки (GTK_BUTTONS_OK, GTK_BUTTONS_YES_NO и т.д.)
    



section .text
    ; Объявления функций GTK
    extern gtk_init, gtk_window_new, gtk_window_set_title, gtk_window_set_default_size
    extern g_signal_connect_data, gtk_grid_new, gtk_container_add, gtk_label_new
    extern gtk_grid_attach, gtk_entry_new, gtk_button_new_with_label, gtk_widget_show_all, gtk_widget_show
    extern gtk_main, gtk_main_quit, gtk_entry_get_text, gtk_message_dialog_new, gtk_widget_destroy   
    extern gtk_window_get_type, g_type_check_instance_cast, gtk_widget_destroyed
    extern printf, strtoll

    global main

find_greater_degree_of_two:
    ; Поиск ближайшей сверху степени двойки
    ; Число в rdi
    ; ret в rax
    push rbp
    mov rbp, rsp

    mov rcx, 0
    mov rdx, 1

    cmp rdx, rdi  ; Если 1 >= number: -> find_exit
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

; Обработчик сигнала, закрытие диалога
dialog_destroy:
    push rbp
    mov rbp, rsp

    ; rdi - диалоговое окно (автоматически передается)
    call gtk_widget_destroy

    mov rsp, rbp
    pop rbp
    ret
    

create_result_dialog:
    ; Аргументы:
    ; rdi = degree (степень)
    ; rsi = 2^degree (результат)
    
    push rbp
    mov rbp, rsp
    sub rsp, 24 ; Выравниваем стек + сохраняем аргументы

    ; Сохраняем аргументы в стек
    mov [rbp - 8], rdi   ; degree
    mov [rbp - 16], rsi  ; 2^degree


    xor rdi, rdi                ; parent = NULL
    mov esi, 0 ; flags
    mov edx, 0 ; message_type
    mov ecx, 1  ; buttons_type
    lea r8, [message_fmt]            ; format string
    mov r9, [rbp - 8]             ; 1-й %lld (degree)
    push qword [rbp - 16]         ; 3-й %lld (2^degree)
    push qword [rbp - 8]          ; 2-й %lld (degree)
    call gtk_message_dialog_new
    ; gtk_message_dialog_new(NULL, GTK_DIALOG_MODAL, GTK_MESSAGE_INFO, GTK_BUTTONS_OK, format, degree, degree, 2^degree)


    add rsp, 16                 ; Чистим аргументы со стека
    ; Сохраняем указатель на диалог (msg_dialog)
    mov [rbp - 24], rax

    ; Устанавливаем заголовок: gtk_window_set_title(GTK_WINDOW(msg_dialog), "Результат")
    mov rdi, rax
    lea rsi, [res_window_title]
    call gtk_window_set_title

    ; Подключаем обработчик: g_signal_connect(msg_dialog, "response", G_CALLBACK(on_dialog_response), NULL)
    mov rdi, [rbp - 24]           ; msg_dialog
    lea rsi, [rel signal_response]     ; "response"
    lea rdx, [rel dialog_destroy] ; callback
    xor rcx, rcx                ; user_data = NULL
    xor r8, r8
    xor r9, r9
    call g_signal_connect_data

    ; Показываем диалог: gtk_widget_show_all(msg_dialog)
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
    mov rcx, [rel GTK_BUTTONS_OK]          ; Кнопки (GTK_BUTTONS_OK)
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
    lea rsi, [rel signal_response]        ; "response" (сигнал)
    lea rdx, [rel dialog_destroy] ; Обработчик
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
    ; Неверное число

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
    sub rsp, 16
    
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

    ; Ищем степень двойки
    mov rdi, [rel number]
    call find_greater_degree_of_two
    mov [rel degree], rax    

    ; Возводим 2 в эту степень
    mov rdi, [rel degree]
    call pow_2
    
    ; Выводим результат в окно диалога
    mov rdi, [rel degree]
    mov rsi, rax
    call create_result_dialog






on_button_clicked_end:
    mov rsp, rbp
    pop rbp
    ret

main:
    ; Пролог функции
    push rbp
    mov rbp, rsp
    sub rsp, 16
    
    ; Инициализация GTK
    xor rdi, rdi
    xor rsi, rsi
    call gtk_init
    
    ; Создание окна
    mov rdi, 0
    call gtk_window_new
    mov [window], rax
    
    ; Устанавливаем заголовок
    mov rdi, [window]
    lea rsi, [window_title] 
    call gtk_window_set_title

    ; Устанавливаем размеры окна
    mov rdi, [window]
    mov rsi, WINDOW_WIDTH
    mov rdx, WINDOW_HEIGHT
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
    
    ; Создание текста
    lea rdi, [label_text]
    call gtk_label_new
    mov [label], rax
    
    ; Добавление текста в сетку
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