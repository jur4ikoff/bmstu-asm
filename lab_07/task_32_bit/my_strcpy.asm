section .note.GNU-stack noalloc noexec nowrite progbits

section .text
    global my_strcpy

my_strcpy:
    ; Пролог функции
    push ebp
    mov ebp, esp
    pusha               ; Сохраняем все регистры

    ; Загрузка аргументов из стека
    mov edi, [ebp + 8]   ; char* dest (1-й аргумент)
    mov esi, [ebp + 12]  ; const char* src (2-й аргумент)
    mov ecx, [ebp + 16]  ; size_t len (3-й аргумент)

    ; Проверка на нулевые указатели
    test esi, esi
    jz .exit ; jump if zero, ZF=1
    test edi, edi
    jz .exit ; jump if zero, ZF=1

    ; Проверка нулевой длины
    test ecx, ecx
    jz .exit

    ; Проверка на перекрытие областей (если dest > src)
    cmp edi, esi
    je .exit             ; Если dest == src, ничего не делаем
    ja .overlap_check    ; Если dest > src, проверяем перекрытие

    ; Обычное копирование (вперед)
    cld                 ; DF = 0 (движение вперед)
    rep movsb           ; Копируем ECX байт из ESI в EDI
    jmp .exit

.overlap_check:
    ; Проверяем, перекрываются ли области
    mov eax, edi
    sub eax, esi        ; Разница между указателями
    cmp eax, ecx
    jae .normal_copy    ; Если расстояние >= len, перекрытия нет

    ; Копирование с конца (при перекрытии)
    lea esi, [esi + edx - 1]  ; Конец src
    lea edi, [edi + edx - 1]  ; Конец dest
    std                 ; DF = 1 (движение назад)
    rep movsb           ; Копируем
    cld                 ; Восстанавливаем DF = 0
    jmp .exit

.normal_copy:
    cld ; DF = 0
    rep movsb

.exit:
    ; Эпилог функции
    popa                ; Восстанавливаем все регистры
    pop ebp
    ret