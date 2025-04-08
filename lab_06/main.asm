.model tiny  ; Программа будет компактной (COM-файл)
.386         ; Разрешение инструкций 80386
    

.CODE     
    ORG 100H   
main:
    jmp init
    
    current_time DB 0
    delay DB 01Fh
    saved_int dd ? ; 4 байта
    MSG DB "Hello, World!", 0Dh, 0Ah, '$' 

slow_echo_input:
    pusha ; Сохраняем все регистры общего назначения
    push es  ; Сохраняем регистр ES
    push ds ; Сохраняем регистр DS

    ; Получаем текущее время (CH = часы, CL = минуты, DH = секунды)
    mov ah, 02h   ; Функция чтения времени
    int 1ah       ; Вызов BIOS (возвращает время в BCD)

    ; Проверяем, изменилась ли секунда
    cmp dh, current_time
    je slow_echo_input_end  ; Если секунда не изменилась — выходим
    mov current_time, dh    ; Обновляем current
    
    ; Изменяем скорость автоповтора клавиатуры
    mov al, 0F3h     ; Команда "установить скорость автоповтора"
    out 60h, al      ; Отправка в контроллер клавиатуры
    mov al, delay    ; Новое значение задержки
    out 60H, al      ; Отправка задержки

    dec delay

    ; Проверяем, не достигли ли нуля (1Fh → 0 → сброс)
    test delay, 01Fh
    jnz slow_echo_input_end      ; ZF = 0, Если не ноль — выходим

    reset_speed:
        mov delay, 01Fh


    ; Выход из обработчика
slow_echo_input_end:
    pop ds       ; Восстанавливаем DS
    pop es       ; Восстанавливаем ES
    popa         ; Восстанавливаем регистры
    jmp cs:saved_int  ; Переход к старому обработчику

init:
    mov ax, 3508h  ; AH=35h (получить вектор прерывания), AL=08h (таймер)
    int 21h ; Возвращает адрес в ES:BX

    mov word ptr saved_int, bx ; Младшее слово
    mov word ptr saved_int + 2, es 

    ; Устанавливаем наш обработчик
    mov ax, 2508h       ; AH=25h (установить вектор прерывания), AL=08h
    mov dx, offset slow_echo_input  ; Адрес нашего обработчика
    int 21h
   
   ; Оставляем программу резидентно в памяти
    mov dx, offset init  ; Размер резидентной части (до INIT)
    int 27h              ; Завершить и оставить резидентно

end main
