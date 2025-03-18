#!/bin/bash

OUT="./out"

for file in *.asm; do
    base=$(basename -s .asm "$file")
    nasm -f elf64 "$file" -o "$OUT"/"$base".o
done

# nasm -f elf64 *.asm -o "$OUT"/*.o
gcc "$OUT"/*.o -o app.exe