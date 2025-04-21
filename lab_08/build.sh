#!/bin/bash

# sudo apt-get install gcc-multilib g++-multilib

OUT="./out"

mkdir $OUT 2>/dev/null

for file in *.asm; do
    base=$(basename -s .asm "$file")
    # gcc --std=c99 -O0 -masm=intel -m32 main.c -o main
    nasm -g -f elf64 -o "$OUT/$base".o "$base".asm
done

# for file in *.cpp; do
#     base=$(basename -s .cpp "$file")
#     # g++ -masm=intel -std=c++11 -Wall -O0 "$file" -c -o "$OUT"/"$base".o
#     # g++ -Wall -O0 "$file" -c -o "$OUT"/"$base".o

# done
# gcc -S main.c $(pkg-config --cflags --libs gtk+-3.0)

# gcc main.o -o main.c $(pkg-config --cflags --libs gtk+-3.0)

gcc "$OUT"/*.o -o app.exe $(pkg-config --libs gtk+-3.0) -no-pie -fPIC

# gcc "$OUT"/*.o -o app.exe
