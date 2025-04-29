#!/bin/bash

# gcc -mfpmath=387 -O0 -masm=intel -o app.exe main.c -lm
# -mfpmath=387 — заставляет GCC использовать x87 для float/double. 
gcc -mfpmath=387 -O0 -masm=intel -o app.exe main.c -lm

# gcc -no-pie main.o -o app.exe -lm