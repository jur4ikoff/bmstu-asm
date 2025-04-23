# Методичка как запускать линукс x86 ассемблер на Mac под arm процессором

## Пишем докерфайл
```Dockerfile
FROM --platform=linux/amd64 ubuntu:latest
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    nasm \
    qemu-user \
    gcc \
    g++ \
    gcc-multilib g++-multilib \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY . .
```

## Билдим image и запускаем container
```bash
docker build -t lab_asm .
# docker run -it --rm -v $(pwd):/app lab_asm 
docker run -it --name asm --rm -v $(pwd):/app lab_asm
```

## Для билда юзаем ./build, либо в ручную
```bash
#!/bin/bash

OUT="./out"
mkdir $OUT 2> /dev/null

for file in *.asm; do
    base=$(basename -s .asm "$file")
    nasm -f elf64 "$file" -o "$OUT"/"$base".o
done

gcc "$OUT"/*.o -o app.exe
``