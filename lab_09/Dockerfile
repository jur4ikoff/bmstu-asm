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