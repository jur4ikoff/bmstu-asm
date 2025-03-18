# Методичка как запускать линукс x86 ассемблер на Mac под arm процессором


```Dockerfile
FROM --platform=linux/amd64 ubuntu:latest
RUN apt-get update && apt-get install -y \
    nasm \
    qemu-user \
    gcc \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY . .
```

docker build -t lab_asm .  
// docker run -it --rm -v $(pwd):/app lab_asm 
docker run -it --name asm --rm -v $(pwd):/app lab_asm