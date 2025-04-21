section .rodata
window_title: db "ЛР8 по МЗЯП. Попов Ю.А.", 0
label_text: db "Введите текст: ", 0
button_text: db "Найти ближайшую сверху степень двойки", 0
result_text: db "Результат", 0
err_number_text: db "Ошибка, нужно ввести безнаковое число", 0
error_title: db "Ошибка", 0
result_format: db "Ближайшая степень двойки %d : 2^%d = %lld", 0

; Константы GTK
GTK_WINDOW_TOPLEVEL equ 0
GTK_MESSAGE_ERROR equ 0
GTK_MESSAGE_INFO equ 1
GTK_BUTTONS_OK equ 0
GTK_DIALOG_MODAL equ 1

extern gtk_init
extern gtk_window_new
extern gtk_window_set_title
extern gtk_window_set_default_size
extern g_signal_connect_data
extern gtk_main_quit
extern gtk_grid_new
extern gtk_container_add
extern gtk_label_new
extern gtk_grid_attach
extern gtk_entry_new
extern gtk_button_new_with_label
extern gtk_widget_show_all
extern gtk_main
extern gtk_entry_get_text
extern gtk_message_dialog_new
extern gtk_window_set_title
extern gtk_widget_destroy
extern g_object_get_data
extern g_object_set_data
extern strtoll
extern g_snprintf

section .text
global main

; Функция find_upper_degree_of_two
find_upper_degree_of_two:
    push rbp
    mov rbp, rsp
    
    mov eax, 1     ; a = 1
    xor edx, edx   ; count = 0
    
.loop:
    cmp rax, rdi   ; сравниваем a и num
    jge .end_loop  ; если a >= num, выходим
    
    shl rax, 1     ; a <<= 1
    inc edx        ; count++
    jmp .loop
    
.end_loop:
    mov eax, edx   ; возвращаем count
    pop rbp
    ret

; Обработчик ответа диалога
on_dialog_response:
    push rbp
    mov rbp, rsp
    
    mov rdi, [rbp+16]  ; dialog
    mov rsi, [rbp+24]  ; response_id
    mov rdx, [rbp+32]  ; user_data
    
    call gtk_widget_destroy
    
    pop rbp
    ret

; Обработчик нажатия кнопки
on_button_clicked:
    push rbp
    mov rbp, rsp
    sub rsp, 64
    
    mov [rbp-8], rdi   ; widget
    mov [rbp-16], rsi  ; data (entry)
    
    ; Получаем текст из entry
    mov rdi, [rbp-16]
    call gtk_entry_get_text
    mov [rbp-24], rax  ; text
    
    ; Преобразуем строку в число
    mov rdi, [rbp-24]
    lea rsi, [rbp-32]  ; endptr
    mov rdx, 10        ; base 10
    call strtoll
    mov [rbp-40], rax  ; number
    
    ; Проверяем на ошибки преобразования
    mov rax, [rbp-32]  ; endptr
    cmp byte [rax], 0
    jne .error
    cmp qword [rbp-40], 0
    jl .error
    
    ; Все ок, находим степень двойки
    mov rdi, [rbp-40]
    call find_upper_degree_of_two
    mov [rbp-44], eax  ; degree
    
    ; Вычисляем 2^degree
    mov ecx, eax
    mov eax, 1
    shl eax, cl
    mov [rbp-48], rax  ; 2^degree
    
    ; Создаем диалог с результатом
    xor rdi, rdi       ; parent
    mov rsi, GTK_DIALOG_MODAL
    mov rdx, GTK_MESSAGE_INFO
    mov rcx, GTK_BUTTONS_OK
    lea r8, [result_format]
    mov r9d, [rbp-44]  ; degree
    push qword [rbp-48] ; 2^degree
    push r9            ; degree
    call gtk_message_dialog_new
    add rsp, 16
    mov [rbp-56], rax  ; dialog
    
    ; Устанавливаем заголовок
    mov rdi, rax
    lea rsi, [result_text]
    call gtk_window_set_title
    
    ; Подключаем обработчик ответа
    mov rdi, [rbp-56]
    lea rsi, [on_dialog_response]
    xor rdx, rdx       ; data
    xor rcx, rcx       ; destroy_data
    xor r8, r8         ; connect_flags
    call g_signal_connect_data
    
    ; Показываем диалог
    mov rdi, [rbp-56]
    call gtk_widget_show_all
    
    jmp .end
    
.error:
    ; Создаем диалог с ошибкой
    xor rdi, rdi       ; parent
    mov rsi, GTK_DIALOG_MODAL
    mov rdx, GTK_MESSAGE_ERROR
    mov rcx, GTK_BUTTONS_OK
    lea r8, [err_number_text]
    call gtk_message_dialog_new
    mov [rbp-56], rax  ; dialog
    
    ; Устанавливаем заголовок
    mov rdi, rax
    lea rsi, [error_title]
    call gtk_window_set_title
    
    ; Подключаем обработчик ответа
    mov rdi, [rbp-56]
    lea rsi, [on_dialog_response]
    xor rdx, rdx       ; data
    xor rcx, rcx       ; destroy_data
    xor r8, r8         ; connect_flags
    call g_signal_connect_data
    
    ; Показываем диалог
    mov rdi, [rbp-56]
    call gtk_widget_show_all
    
.end:
    add rsp, 64
    pop rbp
    ret

main:
    push rbp
    mov rbp, rsp
    sub rsp, 48
    
    ; Инициализация GTK
    xor rdi, rdi
    xor rsi, rsi
    call gtk_init
    
    ; Создаем главное окно
    mov rdi, GTK_WINDOW_TOPLEVEL
    call gtk_window_new
    mov [rbp-8], rax    ; window
    
    ; Устанавливаем заголовок окна
    mov rdi, [rbp-8]
    lea rsi, [window_title]
    call gtk_window_set_title
    
    ; Устанавливаем размер окна
    mov rdi, [rbp-8]
    mov rsi, 300
    mov rdx, 100
    call gtk_window_set_default_size
    
    ; Подключаем обработчик закрытия окна
    mov rdi, [rbp-8]
    lea rsi, [gtk_main_quit]
    xor rdx, rdx        ; data
    xor rcx, rcx        ; destroy_data
    xor r8, r8          ; connect_flags
    call g_signal_connect_data
    
    ; Создаем grid
    call gtk_grid_new
    mov [rbp-16], rax   ; grid
    
    ; Добавляем grid в окно
    mov rdi, [rbp-8]
    mov rsi, [rbp-16]
    call gtk_container_add
    
    ; Создаем label
    lea rdi, [label_text]
    call gtk_label_new
    mov [rbp-24], rax   ; label
    
    ; Добавляем label в grid
    mov rdi, [rbp-16]
    mov rsi, [rbp-24]
    xor rdx, rdx        ; column 0
    xor rcx, rcx        ; row 0
    mov r8, 1           ; width 1
    mov r9, 1           ; height 1
    call gtk_grid_attach
    
    ; Создаем entry
    call gtk_entry_new
    mov [rbp-32], rax   ; entry
    
    ; Добавляем entry в grid
    mov rdi, [rbp-16]
    mov rsi, [rbp-32]
    mov rdx, 1          ; column 1
    xor rcx, rcx        ; row 0
    mov r8, 1           ; width 1
    mov r9, 1           ; height 1
    call gtk_grid_attach
    
    ; Связываем label с entry
    mov rdi, [rbp-32]
    lea rsi, [label_text]
    mov rdx, [rbp-24]
    call g_object_set_data
    
    ; Создаем кнопку
    lea rdi, [button_text]
    call gtk_button_new_with_label
    mov [rbp-40], rax   ; button
    
    ; Добавляем кнопку в grid
    mov rdi, [rbp-16]
    mov rsi, [rbp-40]
    xor rdx, rdx        ; column 0
    mov rcx, 1          ; row 1
    mov r8, 2           ; width 2
    mov r9, 1           ; height 1
    call gtk_grid_attach
    
    ; Подключаем обработчик нажатия кнопки
    mov rdi, [rbp-40]
    lea rsi, [on_button_clicked]
    mov rdx, [rbp-32]   ; entry как user_data
    xor rcx, rcx        ; destroy_data
    xor r8, r8          ; connect_flags
    call g_signal_connect_data
    
    ; Показываем окно
    mov rdi, [rbp-8]
    call gtk_widget_show_all
    
    ; Запускаем главный цикл GTK
    call gtk_main
    
    add rsp, 48
    pop rbp
    xor eax, eax
    ret