#!/bin/bash

gcc  -mfpmath=387 -m80387 -O0 -fno-stack-protector -o app_with_coprocessor_test.exe main.c
# -mfpmath=387 — заставляет GCC использовать x87 для float/double. 