#include <stdio.h>
#include <time.h>

#define MAX_ITTERATIONS 10000000

// Загружаем первое число в стек FPU (ST(0))
// Прибавляем второе число к ST(0)
// Сохраняем результат из ST(0) в res и выталкиваем из стека
#define ASM_ADD(result, a, b) \
    asm volatile(             \
        "fld %1\n"            \
        "fadd %2\n"           \
        "fstp %0\n"           \
        : "=m"(result)        \
        : "m"(a), "m"(b)      \
        : "st");

#define ASM_MUL(result, a, b) \
    asm volatile(             \
        "fld %1\n"            \
        "fmul %2\n"           \
        "fstp %0\n"           \
        : "=m"(result)        \
        : "m"(a), "m"(b)      \
        : "st");

void test_float_operations(void)
{
    float a = 1.234567f, b = 7.890123f, res;

    clock_t start = clock();

    for (int i = 0; i < MAX_ITTERATIONS; i++)
    {
        ASM_ADD(res, a, b)
        ASM_MUL(res, a, b)
    }
    clock_t end = clock();
    double time_used = ((double)(end - start)) / CLOCKS_PER_SEC;
    printf("Время float операций: %.6f секунд, Количество иттераций %d\n", time_used, MAX_ITTERATIONS);
}

void test_double_operations(void)
{
    double a = 1.23456342423432447, b = 7.8901234314315234, res;

    clock_t start = clock();

    for (int i = 0; i < MAX_ITTERATIONS; i++)
    {
        ASM_ADD(res, a, b)
        ASM_MUL(res, a, b)
    }

    clock_t end = clock();
    double time_used = ((double)(end - start)) / CLOCKS_PER_SEC;
    printf("Время double операций: %.6f секунд, Количество иттераций %d\n", time_used, MAX_ITTERATIONS);
}

int main(void)
{
    test_float_operations();
    test_double_operations();
    return 0;
}