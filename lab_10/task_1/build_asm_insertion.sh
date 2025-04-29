#!/bin/bash

gcc -mfpmath=387 -O0 -masm=intel -o app_asm_insertion.exe insert_asm.c
# -mfpmath=387 — заставляет GCC использовать x87 для float/double. 