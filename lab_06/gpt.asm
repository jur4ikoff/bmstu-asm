; Автоматически меняет скорость автоповтора клавиатуры каждую секунду
; Компиляция: tasm /m2 AUTOREP.ASM
;             tlink /t /x AUTOREP.OBJ
; Для резидентного размещения в памяти запустить полученный COM-файл

.model tiny
.code
.386
org 100h

start:
    jmp init

old_timer  dd ?       ; Для хранения старого обработчика 08h
old_kbd    dd ?       ; Для хранения старого обработчика 09h
counter    db 0       ; Счетчик тиков (18.2 тика в секунду)
speed      db 0       ; Текущая скорость (0-31)

; Таблица скоростей автоповтора (задержка/скорость)
speed_table db 00h, 01h, 02h, 03h, 04h, 05h, 06h, 07h
            db 08h, 09h, 0Ah, 0Bh, 0Ch, 0Dh, 0Eh, 0Fh
            db 10h, 11h, 12h, 13h, 14h, 15h, 16h, 17h
            db 18h, 19h, 1Ah, 1Bh, 1Ch, 1Dh, 1Eh, 1Fh

; Новый обработчик прерывания таймера (08h)
new_timer proc far
    pushf
    call cs:old_timer    ; Вызов старого обработчика
    
    push ds
    push ax
    push bx
    
    push cs
    pop ds
    
    inc counter          ; Увеличиваем счетчик тиков
    cmp counter, 18      ; Проверяем, прошла ли секунда (18 тиков)
    jb timer_exit
    
    mov counter, 0       ; Сброс счетчика
    
    ; Изменяем скорость автоповтора
    inc speed            ; Увеличиваем скорость
    cmp speed, 32        ; Проверяем, не вышли ли за пределы
    jb set_speed
    mov speed, 0         ; Циклически возвращаемся к началу
    
set_speed:
    mov al, 0F3h         ; Команда установки скорости автоповтора
    out 60h, al          ; Отправка команды в контроллер клавиатуры
    mov al, speed        ; Получаем текущую скорость из таблицы
    mov bl, al
    mov al, cs:speed_table[bx]
    out 60h, al          ; Отправляем значение скорости
    
timer_exit:
    pop bx
    pop ax
    pop ds
    iret
new_timer endp

; Новый обработчик прерывания клавиатуры (09h)
new_kbd proc far
    pushf
    call cs:old_kbd      ; Вызов старого обработчика
    iret
new_kbd endp

init:
    ; Получаем адреса старых обработчиков
    mov ax, 3508h        ; Функция получения вектора прерывания 08h
    int 21h
    mov word ptr old_timer, bx
    mov word ptr old_timer+2, es
    
    mov ax, 3509h        ; Функция получения вектора прерывания 09h
    int 21h
    mov word ptr old_kbd, bx
    mov word ptr old_kbd+2, es
    
    ; Устанавливаем новые обработчики
    mov ax, 2508h        ; Функция установки вектора прерывания 08h
    mov dx, offset new_timer
    int 21h
    
    mov ax, 2509h        ; Функция установки вектора прерывания 09h
    mov dx, offset new_kbd
    int 21h
    
    ; Выводим сообщение о резидентной установке
    mov dx, offset msg_installed
    mov ah, 09h
    int 21h
    
    ; Оставляем программу резидентной
    mov dx, offset init
    add dx, 15
    mov cl, 4
    shr dx, cl           ; Вычисляем размер в параграфах
    mov ax, 3100h        ; Функция завершения с оставлением резидентным
    int 21h

msg_installed db 'Auto-repeat speed changer installed',13,10,'$'

end start