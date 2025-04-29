#!/bin/bash

gcc -mno-80387 -O0 -o app_no_coprocessor_test.exe main.c
# -mno-80387	Запрещает использование x87 FPUx