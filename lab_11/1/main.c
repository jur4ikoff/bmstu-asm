#include <stdio.h>
#include <stdlib.h>
#include <immintrin.h>

// SSE реализация умножения матриц
void matrix_multiply_sse(float *A, float *B, float *C, int L, int M, int N)
{
    for (int i = 0; i < L; i++)
    {
        for (int j = 0; j < N; j += 4)
        {
            __m128 c;
            __asm__ __volatile__(
                "xorps xmm0, xmm0\n\t"
                : "=x"(c));

            for (int k = 0; k < M; k++)
            {
                __m128 a = _mm_set1_ps(A[i * M + k]);
                __m128 b = _mm_loadu_ps(&B[k * N + j]);
                c = _mm_add_ps(c, _mm_mul_ps(a, b));
            }
            _mm_storeu_ps(&C[i * N + j], c);
        }
    }
}

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

    matrix_multipy_default(A, B, C, L, M, N);

    printf("Result matrix C (%dx%d):\n", L, N);
    print_matrix(C, L, N);

    free(A);
    free(B);
    free(C);

    return 0;
}