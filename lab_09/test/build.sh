#!/bin/bash

OUT="./out"
mkdir $OUT 2> /dev/null

for file in *.cpp; do
    base=$(basename -s .cpp "$file")
    g++ --std=c++20 -O0 "$file" -c -o "$OUT"/"$base".o
    # nasm -f elf64 "$file" -o "$OUT"/"$base".o
done

# sudo apt-get install gcc-multilib g++-multilib
g++ -std=c++20 -Wall "$OUT"/*.o -o app.exe

