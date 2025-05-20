#include <stdio.h>
#include <stdlib.h>

#define ERR_OK 0
#define ERR_INPUT 1
#define ERR_ALLOC 2
void print_err_msg(int rc)
{
    switch (rc)
    {
    case ERR_INPUT:
        printf("Ошибка ввода\n");
        break;
    case ERR_ALLOC:
        printf("Ошибка выделения памяти\n");
        break;
    default:
        break;
    }
}

void add_arrays_neon_asm(float *a, float *b, float *result, int size)
{
    for (int i = 0; i < size; i += 4)
    {
        __asm__ volatile(
            // Загружаем 4 элемента из массива a в q0
            "ld1 {v0.4s}, [%0]\n"
            // Загружаем 4 элемента из массива b в q1
            "ld1 {v1.4s}, [%1]\n"
            // Складываем векторы (q0 = q0 + q1)
            "fadd v2.4s, v0.4s, v1.4s\n"
            // Сохраняем результат
            "st1 {v2.4s}, [%2]\n"
            : // Нет выходных операндов
            : "r"(a + i), "r"(b + i), "r"(result + i)
            : "v0", "v1", "v2", "memory");
    }
}

static void print_arr(float *arr, int n)
{
    for (int i = 0; i < n; i++)
    {
        printf("%.3f  ", arr[i]);
    }
    printf("\n");
}

int main()
{
    int rc = ERR_OK, n;

    float *a = NULL;
    float *b = NULL;
    float *result = NULL;

    printf("Введите размер обоих векторов: ");
    if (scanf("%d", &n) != 1)
    {
        rc = ERR_INPUT;
        goto exit;
    }

    a = malloc(sizeof(float) * n);
    b = malloc(sizeof(float) * n);
    result = malloc(sizeof(float) * n);

    if (a == NULL || b == NULL || result == NULL)
    {
        rc = ERR_ALLOC;
        goto exit;
    }

    printf("Введите элементы первого вектора:\n");

    for (size_t i = 0; i < n; i++)
    {
        if (scanf("%f", &a[i]) != 1)
        {
            rc = ERR_INPUT;
            goto exit;
        }
    }

    printf("Введите элементы второго вектора:\n");
    for (size_t i = 0; i < n; i++)
    {
        if (scanf("%f", &b[i]) != 1)
        {
            rc = ERR_INPUT;
            goto exit;
        }
    }

    add_arrays_neon_asm(a, b, result, n);
    printf("Результат сравнения двух массивов\n");
    print_arr(result, n);

exit:
    if (a)
        free(a);
    if (b)
        free(b);
    if (result)
        free(result);

    print_err_msg(rc);
    return rc;
}

// #include <stdio.h>

// #define SIZE 8

// void add_arrays_neon_asm(float* a, float* b, float* result, int size) {
//     for (int i = 0; i < size; i += 4) {
//         __asm__ volatile (
//             // Загружаем 4 элемента из массива a в q0
//             "ld1 {v0.4s}, [%0]\n"
//             // Загружаем 4 элемента из массива b в q1
//             "ld1 {v1.4s}, [%1]\n"
//             // Складываем векторы (q0 = q0 + q1)
//             "fadd v2.4s, v0.4s, v1.4s\n"
//             // Сохраняем результат
//             "st1 {v2.4s}, [%2]\n"
//             : // Нет выходных операндов
//             : "r" (a + i), "r" (b + i), "r" (result + i)
//             : "v0", "v1", "v2", "memory"
//         );
//     }
// }

// int main() {
//     float a[SIZE] = {1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0};
//     float b[SIZE] = {0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8};
//     float result[SIZE] = {0};

//     add_arrays_neon_asm(a, b, result, SIZE);

//     printf("Result of array addition (ASM version):\n");
//     for (int i = 0; i < SIZE; i++) {
//         printf("%.1f + %.1f = %.1f\n", a[i], b[i], result[i]);
//     }

//     return 0;
// }