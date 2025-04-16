# Методичка как запускать линукс x86 ассемблер на Mac под arm процессором

## Пишем докерфайл
```Dockerfile
FROM --platform=linux/amd64 ubuntu:latest
RUN apt-get update && apt-get install -y \
    nasm \
    qemu-user \
    gcc \
    g++ \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY . .
```

## Билдим image и запускаем container
```bash
docker build -t lab_asm .
# docker run -it --rm -v $(pwd):/app lab_asm 
docker run -it --name asm --rm -v $(pwd):/app lab_asm
# Мейби нужно будет docker -exec -it asm bash
```

## Для билда юзаем ./build, либо в ручную
```bash
nasm -f elf64 hello.asm -o hello.o
ld -o hello hello.o
qemu-x86_64 ./hello # хз почему, но работает без него
```