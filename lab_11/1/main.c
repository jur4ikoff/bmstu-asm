#include <stdio.h>
#include <stdlib.h>
#include <immintrin.h>
#include <stdint.h>
#include <string.h>

void print_m128(__m128 var)
{
    float *values = (float *)&var;
    printf("[ %f, %f, %f, %f ]\n", values[0], values[1], values[2], values[3]);
}

static inline __m128 create_value()
{
    __m128 c;
    __asm__ __volatile__(
        "xorps %%xmm0, %%xmm0\n\t"
        : "=x"(c));

    return c;
}

// Функция загрузки переменной
static inline __m128 load_value(float val)
{
    __m128 res;
    __asm__ __volatile__(
        "movss %[number], %[a]\n\t"
        : [a] "=x"(res)
        : [number] "m"(val)
        : "memory");

    return res;
}

// static inline __m128 add_m128(__m128 a, __m128 b)
// {
//     __asm__ __volatile__(
//         "addps %[b] %[a]\n\t"
//         : [a] "+x"(a)
//         : [b] "x"(b)
// : "memory");

//     return a;
// }

static inline __m128 mul_m128(__m128 a, __m128 b)
{
    __asm__ __volatile(
        "\n\t"
        : [a] "+x"(a)
        : [b] "x"(b)
        : "memory");

    return a;
}

// SSE реализация умножения матриц
void matrix_multiply_sse(float *A, float *B, float *C, int L, int M, int N)
{
    for (int i = 0; i < L; i++)
    {
        for (int j = 0; j < N; j += 4)
        {
            __m128 c = create_value();

            for (int k = 0; k < M; k++)
            {
                // Значения матриц
                float fa = A[i * M + k];
                float fb = B[k * N + j];

                // Временное значение
                __m128 res = create_value();

                // __m128 a = load_value(A[i * M + k]);
                // __m128 b = load_value(B[k * N + j]);
                __asm__ volatile(
                    "movss %[a], %%xmm1\n\t"
                    "movss %[b], %%xmm2\n\t"
                    "movss %[c], %%xmm0\n\t"
                    "mulss %%xmm2, %%xmm1\n\t" // a  * b
                    "addss %%xmm1, %%xmm0\n\t" // (a * b) + c
                    "movss %%xmm0, %[c]\n\t"
                    : [c] "+x"(c)
                    : [a] "x"(fa), [b] "x"(fb)
                    : "memory", "xmm0", "xmm1", "xmm2");

                print_m128(res);
                c = _mm_add_ps(c, res);
                // c = _mm_add_ps(c, _mm_mul_ps(a, b));
            }
            _mm_storeu_ps(&C[i * N + j], c);
        }
    }
}

// void matrix_multipy_asm(float *A, float *B, float *C, int L, int M, int N)
// {}

void matrix_multipy_default(float *A, float *B, float *C, int L, int M, int N)
{
    for (int i = 0; i < L; i++)
    {
        for (int j = 0; j < N; j++)
        {
            float c = 0;
            for (int k = 0; k < M; k++)
            {
                float a = A[i * M + k];
                float b = B[k * N + j];
                c += a * b;
            }
            C[i * N + j] = c;
        }
    }
}

void print_matrix(float *matrix, int rows, int cols)
{
    for (int i = 0; i < rows; i++)
    {
        for (int j = 0; j < cols; j++)
        {
            printf("%.2f ", matrix[i * cols + j]);
        }
        printf("\n");
    }
}

int main()
{
    int L, M, N;

    printf("Enter dimensions L M N: ");
    if (scanf("%d %d %d", &L, &M, &N) != 3)
    {
        printf("Invalid input\n");
        return 1;
    }

    if (L <= 0 || M <= 0 || N <= 0)
    {
        printf("Invalid dimensions\n");
        return 1;
    }

    // Выделяем память с выравниванием для SSE (16 байт)
    float *A, *B, *C;
    if (posix_memalign((void **)&A, 8, L * M * sizeof(float)) != 0 ||
        posix_memalign((void **)&B, 8, M * N * sizeof(float)) != 0 ||
        posix_memalign((void **)&C, 8, L * N * sizeof(float)) != 0) // Было выравнивкние 16
    {
        printf("Memory allocation failed\n");
        return 1;
    }

    printf("Enter matrix A (%dx%d):\n", L, M);
    for (int i = 0; i < L; i++)
    {
        for (int j = 0; j < M; j++)
        {
            if (scanf("%f", &A[i * M + j]) != 1)
            {
                printf("Invalid input\n");
                free(A);
                free(B);
                free(C);
                return 1;
            }
        }
    }

    printf("Enter matrix B (%dx%d):\n", M, N);
    for (int i = 0; i < M; i++)
    {
        for (int j = 0; j < N; j++)
        {
            if (scanf("%f", &B[i * N + j]) != 1)
            {
                printf("Invalid input\n");
                free(A);
                free(B);
                free(C);
                return 1;
            }
        }
    }

    // Проверяем поддержку SSE (все современные x86-64 процессоры поддерживают SSE2)
    printf("Using SSE implementation\n");
    matrix_multiply_sse(A, B, C, L, M, N);

    printf("Result matrix C (%dx%d):\n", L, N);
    print_matrix(C, L, N);

    free(A);
    free(B);
    free(C);

    return 0;
}