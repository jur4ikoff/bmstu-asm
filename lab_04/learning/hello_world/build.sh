#!/bin/bash

OUT="./out"
nasm -f elf64 hello.asm -o "$OUT"/*.o
ld "$OUT"/*.o -o app.exe