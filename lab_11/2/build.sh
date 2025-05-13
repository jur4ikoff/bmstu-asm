#!/bin/bash

# sudo apt-get install gcc-multilib g++-multilib

OUT="./out"

mkdir $OUT 2>/dev/null

for file in *.c; do
    base=$(basename -s .c "$file")
    # gcc -mavx -O0 -std=c11 -D_POSIX_C_SOURCE=200112L  -c $file -o $OUT/$base.o
    gcc -msse -msse2 -O0 -c $file -o $OUT/$base.o
    # -masm=intel
done


gcc -no-pie $OUT/*.o -o app.exe -lm

# for file in *.asm; do
#     base=$(basename -s .asm "$file")
#     nasm -f elf64 "$file" -o "$OUT"/"$base".o
# done

# # nasm -f elf64 *.asm -o "$OUT"/*.o
# gcc "$OUT"/*.o -o app.exe


#----------------------------
# #!/bin/bash

# # gcc -mfpmath=387 -O0 -masm=intel -o app.exe main.c -lm
# # -mfpmath=387 — заставляет GCC использовать x87 для float/double. 
# gcc -mfpmath=387 -O0 -masm=intel -o app.exe main.c -lm

# # gcc -no-pie main.o -o app.exe -lm