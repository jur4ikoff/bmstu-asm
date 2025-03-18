FROM --platform=linux/amd64 ubuntu:latest
RUN apt-get update && apt-get install -y \
    nasm \
    qemu-user \
    gcc \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY . .