#!/bin/bash

OUT="./out"

mkdir $OUT 2> /dev/null

for file in *.c; do
    base=$(basename -s .c "$file")
    gcc -O0 -c $file -o $OUT/$base.o
done

# nasm -f elf64 *.asm -o "$OUT"/*.o
gcc "$OUT"/*.o -o app.exe