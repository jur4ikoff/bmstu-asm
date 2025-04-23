; gtk_button.asm - Программа с кнопкой на GTK и ассемблере
; Компиляция: nasm -f elf64 gtk_button.asm && gcc -no-pie gtk_button.o -o gtk_button `pkg-config --cflags --libs gtk+-3.0`

global main
extern gtk_init
extern gtk_window_new
extern gtk_window_set_title
extern gtk_widget_show
extern gtk_button_new_with_label
extern gtk_container_add
extern g_signal_connect_data
extern gtk_main
extern gtk_main_quit
extern g_print
extern exit

section .data
    window_title db "ЛР8 Попов Ю.А.", 0
    button_label db "Решить задачу!", 0
    signal_destroy db "destroy", 0
    signal_clicked db "clicked", 0
    click_message db "test!", 10, 0

section .text

; Функция-обработчик нажатия кнопки
button_clicked:
    mov   rdi, click_message
    xor   rsi, rsi
    xor   rax, rax
    call  g_print
    ret

main:
    ; Инициализация GTK
    xor   rdi, rdi        ; argc = 0
    xor   rsi, rsi        ; argv = NULL
    call  gtk_init
    
    ; Создание главного окна
    mov   rdi, 0          ; GTK_WINDOW_TOPLEVEL
    call  gtk_window_new
    mov   r12, rax        ; сохраняем указатель на окно
    
    ; Установка заголовка окна
    mov   rdi, r12        ; указатель на окно
    mov   rsi, window_title
    call  gtk_window_set_title
    
    ; Создание input_label
    ; mov rdi, 
    
    ; Создание кнопки
    mov   rdi, button_label
    call  gtk_button_new_with_label
    mov   r13, rax        ; сохраняем указатель на кнопку
    
    ; Добавление кнопки в окно
    mov   rdi, r12        ; окно
    mov   rsi, r13        ; кнопка
    call  gtk_container_add
    
    ; Подключение сигнала "destroy" для закрытия окна
    mov   rdi, r12        ; указатель на окно
    mov   rsi, signal_destroy ; имя сигнала "destroy"
    mov   rdx, gtk_main_quit ; обработчик
    xor   rcx, rcx        ; данные для обработчика
    xor   r8, r8          ; уведомитель
    xor   r9, r9          ; флаги
    call  g_signal_connect_data
    
    ; Подключение сигнала "clicked" для кнопки
    mov   rdi, r13        ; указатель на кнопку
    mov   rsi, signal_clicked ; имя сигнала "clicked"
    mov   rdx, button_clicked ; наш обработчик
    mov   rcx, 0       ; данные для обработчика
    mov   r8, 0          ; уведомитель
    mov   r9, 0          ; флаги
    call  g_signal_connect_data
    
    ; Показать все виджеты
    mov   rdi, r12
    call  gtk_widget_show
    mov   rdi, r13
    call  gtk_widget_show
    
    ; Главный цикл GTK
    call  gtk_main
    
    ; Выход
    xor   rdi, rdi
    call  exit