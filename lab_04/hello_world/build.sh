#!/bin/bash

OUT="./out/"
nasm -f elf64 hello.asm -o "$OUT"/hello.o
ld "$OUT"/hello.o -o hello.exe