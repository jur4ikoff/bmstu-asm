# ЛР3 Ответы на часто задаваемые вопросы
## сколько сегментов в программе
(3 сегмента, Данные, код, стек)
## Какой адрес у вот этого сегмента (показал на сегмент, который лежит на видеопамяти)
Сегментная часть адресса `0b800h`
## Какой у него физический адрес
Чтобы получить физический адресс, нужно умножить на 16, на велечину размера сегмента и прибивать смещение внутри сегмента -> `0b8000h`
## Что такое видеопамять
Видеопамять — это внутренняя оперативная память, отведённая для хранения данных, которые используются для формирования изображения на экране монитора.
## Какая DOS функция будет выполняться в третьем примере в подпрограмме output
```asm
mov ah, 2 ;; int 21h будет выводить один символ на экран
	int 21h ;; системное прерывание
	mov dl, 13 ;; Возврат каретки \r
	int 21h ;; системное прерывание
	mov dl, 10 ;; \n
	int 21h ;; системное прерывание
	ret
```
## Что такое системное прерывание 
Системные прерывания в DOS — это механизм, который позволяет программам взаимодействовать с функциями операционной системы. Прерывания представляют собой сигналы, которые приостанавливают выполнение текущей программы и передают управление специальным процедурам, называемым обработчиками прерываний. Эти обработчики выполняют необходимые действия, а затем возвращают управление прерванной программе.

## Что будет если убрать вызов функции завершения программы и объяснить действия
Весь мусор, находящийся в сегменте кода после кода программы будет исполняться
## Что будет если закомментить assume в третьем примере и спросил как запустить программу без assume
Ассемблер не будет знать, какие сегментные регистры используются:
```asm
; Можно обойти отсутствие assume
mov ax, SD1 ; Было, помещаем нужный сегмент в DS
mov ds, ax
mov dl, DS:S1 ; Обращаемся к метке через DS:
```
1) что за адрес b800h
2) какой физический адрес у b800h
3) что такое видеоадаптер 
4) что такое public, extern
5) сколько занимает метка near
6) сколько занимает метка far
7) почему far занимает 4 байта, что они означают 
8) как обращаться к сегменту без ASSUME xx:yy 
9) установить breakpoint в свое программе