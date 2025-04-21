#!/bin/bash

# sudo apt-get install gcc-multilib g++-multilib

OUT="./out"

mkdir $OUT 2> /dev/null

# for file in *.asm; do
#     base=$(basename -s .asm "$file")
#     gcc --std=c99 -O0 -masm=intel -m32 main.c -o main
#     # nasm -f elf64 "$file" -o "$OUT"/"$base".o
# done


# for file in *.cpp; do
#     base=$(basename -s .cpp "$file")
#     # g++ -masm=intel -std=c++11 -Wall -O0 "$file" -c -o "$OUT"/"$base".o
#     # g++ -Wall -O0 "$file" -c -o "$OUT"/"$base".o

# done 
nasm -f elf64 -o main.o main.asm
# gcc main.c -c -o main.o `pkg-config --cflags --libs gtk+-3.0`
# gcc main.o -L/usr/lib/x86_64-linux-gnu $(pkg-config --libsgtk+-3.0) -o main -no-pie
gcc main.o -o app.exe $(pkg-config --libs gtk+-3.0) -no-pie -fPIC


# gcc "$OUT"/*.o -o app.exe