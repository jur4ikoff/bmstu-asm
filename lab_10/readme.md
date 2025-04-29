# ЛР 10 Математический сопроцессор

## Задание 1 Встроенный си
Значения с одиночной точностью и типом float имеют 4 байта, состоят из бита знака, 8-разрядной двоичной экспоненты excess-127 и 23-битной мантиссы. Мантисса представляет число от 1,0 до 2,0. Поскольку бит высокого порядка мантиссы всегда равен 1, он не сохраняется в числе.


### Дизассемблированный код без сопроцессора
Код сложения и умножения float без сопроцессора
```asm
movss   xmm0, [rbp+var_24]
addss   xmm0, [rbp+var_20] ; c = a + b
movss   [rbp+var_1C], xmm0
movss   xmm0, [rbp+var_24]
mulss   xmm0, [rbp+var_20] ; c = a * b
movss   [rbp+var_1C], xmm0
add     [rbp+var_28], 1 ; i++
```
Код сложения и умножения double без сопроцессора
```asm
movsd   xmm0, [rbp+var_30] ; 30h - 28h = 8h
addsd   xmm0, [rbp+var_28]  ; c = a + b
movsd   [rbp+var_8], xmm0
movsd   xmm0, [rbp+var_30]
mulsd   xmm0, [rbp+var_28] ; c = a * b
movsd   [rbp+var_8], xmm0 ; 
add     [rbp+var_34], 1
```

### Дизассемблированный с сопроцессором
Float operations  
```asm
.text:00000000000011A1                 movss   xmm0, [rbp+var_24]
.text:00000000000011A6                 addss   xmm0, [rbp+var_20]
.text:00000000000011AB                 movss   [rbp+var_1C], xmm0
.text:00000000000011B0                 movss   xmm0, [rbp+var_24]
.text:00000000000011B5                 mulss   xmm0, [rbp+var_20]
.text:00000000000011BA                 movss   [rbp+var_1C], xmm0
```
Double operations  
```asm
.text:0000000000001254                 movsd   xmm0, [rbp+var_30]
.text:0000000000001259                 addsd   xmm0, [rbp+var_28]
.text:000000000000125E                 movsd   [rbp+var_8], xmm0
.text:0000000000001263                 movsd   xmm0, [rbp+var_30]
.text:0000000000001268                 mulsd   xmm0, [rbp+var_28]
.text:000000000000126D                 movsd   [rbp+var_8], xmm0
```

### Вывод 

С сопроцессором х87 получается в 6-7 раз медленнее потому что, существующие расширения `SSE` и `AVX/AVX2` работают быстрее
```bash
root@61e0530cd5cf:/app/task_1# ./app_no_coprocessor_test.exe 
Время Double операций с сопроцессором 80387: 0.014321 секунд, Количество иттераций 10000000
Время Double операций с сопроцессором 80387: 0.010399 секунд, Количество иттераций 10000000
root@61e0530cd5cf:/app/task_1# ./app_with_coprocessor_test.exe
Время Double операций с сопроцессором 80387: 0.621283 секунд, Количество иттераций 10000000
Время Double операций с сопроцессором 80387: 0.705794 секунд, Количество иттераций 10000000
```

## Задание 1.1 Ассемблерная вставка