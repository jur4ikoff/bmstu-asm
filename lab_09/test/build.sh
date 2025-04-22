#!/bin/bash

# OUT="./out"

# mkdir $OUT 2> /dev/null

# for file in *.asm; do
#     base=$(basename -s .asm "$file")
#     gcc --std=c99 -O0 -masm=intel -m32 main.c -o main
#     # nasm -f elf64 "$file" -o "$OUT"/"$base".o
# done

# # nasm -f elf64 *.asm -o "$OUT"/*.o
# gcc "$OUT"/*.o -o app.exe

# sudo apt-get install gcc-multilib g++-multilib

nasm -f elf64 my_strcpy.asm -o my_strcpy.o
g++ -masm=intel -std=c++11 -Wall -O0 main.cpp my_strcpy.o -o app.exe

