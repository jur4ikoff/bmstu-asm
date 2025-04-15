#!/bin/bash

# sudo apt-get install gcc-multilib g++-multilib

OUT="./out"

mkdir $OUT 2> /dev/null

# for file in *.asm; do
#     base=$(basename -s .asm "$file")
#     gcc --std=c99 -O0 -masm=intel -m32 main.c -o main
#     # nasm -f elf64 "$file" -o "$OUT"/"$base".o
# done


for file in *.cpp; do
    base=$(basename -s .cpp "$file")
    g++ -masm=intel -std=c++11 -Wall -O0 "$file" -o "$OUT"/"$base".o

done 

# gcc "$OUT"/*.o -o app.exe



# nasm -f elf64 my_strcpy.asm -o my_strcpy.o
# g++ -masm=intel -std=c++11 -Wall -O0 main.cpp my_strcpy.o -o app.exe

exit 0
