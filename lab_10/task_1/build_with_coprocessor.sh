#!/bin/bash

gcc -mfpmath=387 -O0 -o app_with_coprocessor_test.exe main.c
# -mfpmath=387 — заставляет GCC использовать x87 для float/double. 