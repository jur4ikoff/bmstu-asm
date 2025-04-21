section .data
    ; Константы
    window_title db "GTK Assembly App", 0
    width equ 400
    height equ 200
    label_text db "Enter text:", 0
    button_text db "Print Text", 0
    
    ; Формат для printf
    printf_format db "Text entered: %s", 10, 0
    
    ; Имена сигналов GTK
    signal_destroy db "destroy", 0
    signal_clicked db "clicked", 0

        ; Заголовки GTK
    parent_window dq 0       ; Указатель на родительское окно (может быть NULL)
    flags        dd 0        ; Флаги диалога (GTK_DIALOG_MODAL и т.д.)
    type         dd 0        ; Тип сообщения (GTK_MESSAGE_INFO, GTK_MESSAGE_WARNING и т.д.)
    buttons      dd 1        ; Кнопки (GTK_BUTTONS_OK, GTK_BUTTONS_YES_NO и т.д.)
    title        db "Пример диалога", 0
    message      db "Привет, это GTK MessageBox!", 0
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

section .rodata
    response_signal db "response",0

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
    extern printf
    extern gtk_window_get_type, g_type_check_instance_cast

    global main

; Обработчик сигнала (вызывается при нажатии кнопки)
on_response:
    push rbp
    mov rbp, rsp

    ; rdi - диалоговое окно (автоматически передается)
    
    ; Просто закрываем диалог
    call gtk_widget_destroy

    leave
    ret
; Функция обратного вызова для кнопки
on_button_clicked:
    push rbp
    mov rbp, rsp
    
    ; Первый аргумент (rdi) - это кнопка, второй (rsi) - user_data (наш entry)
    mov rdi, rsi          ; Получаем entry из user_data
    call gtk_entry_get_text
    
    ; Выводим текст в консоль
    mov rdi, printf_format
    mov rsi, rax
    xor eax, eax
    call printf

    ; Создаем диалог
    mov rdi, [parent_window]    ; Родительское окно (NULL)
    mov esi, [flags]            ; Флаги (0)
    mov edx, [type]             ; Тип сообщения (GTK_MESSAGE_INFO)
    mov ecx, [buttons]          ; Кнопки (GTK_BUTTONS_OK)
    mov r8, title               ; Заголовок
    mov r9, message             ; Текст сообщения
    call gtk_message_dialog_new
    

    ; Подключаем обработчик сигнала "response" (нажатие кнопки)
    mov rdi, rax                ; Диалог (GtkDialog*)
    mov rsi, signal_name        ; "response" (сигнал)
    lea rdx, [rel on_response] ; Обработчик
    xor rcx, rcx                ; user_data (NULL)
    xor r8, r8                  ; Уведомитель (NULL)
    xor r9, r9                  ; Флаги (0)
    call g_signal_connect_data

    ; Показываем диалог
    mov rdi, rax
    call gtk_widget_show

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
    
    ; Сигнал destroy
    mov rdi, [window]
    lea rsi, [signal_destroy]
    mov rdx, gtk_main_quit
    xor rcx, rcx
    xor r8, r8
    xor r9, r9
    call g_signal_connect_data
    
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
    leave
    ret