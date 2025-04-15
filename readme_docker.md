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

```
docker run -it --rm \
    --name asm \
    -v $(pwd):/app \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=host.docker.internal:0 \
    -v ~/.Xauthority:/root/.Xauthority:ro \
    lab_asm \
    /bin/bash
```

На маке пишем
```xhost +localhost```
Из-под докера билдим и запускаем приложуху

## Для билда юзаем скрипт ./build
Пример билда ассемблерного кода из первых лаб
```bash
nasm -f elf64 hello.asm -o hello.o
ld -o hello hello.o
qemu-x86_64 ./hello # хз почему, но работает без него
```