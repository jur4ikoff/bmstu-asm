#include "matrix.hpp"

Matrix::Matrix(int n, int m)
{
    matrix_data = nullptr;
    if (n <= 0 || m <= 0)
    {
        throw std::runtime_error("Wrong size error");
    }

    this->rows = n;
    this->cols = m;
    this->allocate_matrix();
}

void Matrix::read_matrix()
{
    double elem = 0;
    for (int i = 0; i < rows; i++)
    {
        for (int j = 0; j < cols; j++)
        {
            std::cin >> elem;
            if (std::cin.fail())
            {
                throw std::runtime_error("Ошибка, ввода");
            }
            matrix_data[i][j] = elem;
        }
    }
}

void Matrix::print_matrix()
{
    for (int i = 0; i < rows; i++)
    {
        for (int j = 0; j < cols; j++)
        {
            std::cout << matrix_data[i][j] << "\t";
        }
        std::cout << '\n';
    }
}

Matrix &Matrix::operator=(const Matrix &other)
{
    if (this != &other)
    {
        free_matrix();
        rows = other.rows;
        cols = other.cols;
        if (rows > 0 && cols > 0)
        {
            matrix_data = (double **)malloc(rows * sizeof(double *));
            if (!matrix_data)
            {
                throw std::runtime_error("Memory allocation failed!");
            }
            for (int i = 0; i < rows; i++)
            {
                matrix_data[i] = (double *)malloc(cols * sizeof(double));
                if (!matrix_data[i])
                {
                    throw std::runtime_error("Memory allocation failed!");
                }
                std::memcpy(matrix_data[i], other.matrix_data[i], cols * sizeof(double));
            }
        }
        else
        {
            matrix_data = nullptr;
        }
    }
    return *this;
}

Matrix Matrix::operator*(Matrix &other)
{

    if (this->cols != other.rows)
    {
        throw std::invalid_argument("Sizes not mathed!\n");
    }

    Matrix res_matrix(this->rows, other.cols);
    double **res_matrix_data = res_matrix.get_matrix_data();

    double **matrix1 = this->get_matrix_data();
    double **matrix2 = other.get_matrix_data();

    size_t L = this->rows;
    size_t M = this->cols;
    size_t N = other.cols;

    __asm__ volatile(
        "xor %%r8, %%r8\n\t" // i = 0
        "iLoop:\n\t"
        "cmp %[L], %%r8\n\t" // сравниваем i и L
        "jge exitIloop\n\t"  // jump great equal

        "xor %%r9, %%r9\n\t" // j = 0
        "jLoop:\n\t"
        "cmp %[N], %%r9\n\t"
        "jge exitJloop\n\t" // jump if (j >= N)

        "pxor %%xmm2, %%xmm2\n\t" // xmm2 = 0, Аккумулятор для суммы в результирующей матрице ‰
        "xor %%r10, %%r10\n\t"    // k = 0
        "kLoop:\n\t"
        "mov %[M], %%rcx\n\t"
        "sub %%r10, %%rcx\n\t" // rcx = M - k
        "cmp $2, %%rcx\n\t"
        "jl remainder\n\t" // if less than 2 elements remain

        // Загружаем matrix[i][k:k+1]
        "mov %[matrix1], %%r11\n\t"
        "mov (%%r11, %%r8, 8), %%r11\n\t" // r11 = matrix1[i]
        // Загружаем два double из памяти в регистр %%xmm0
        // movupd: копирование невыровненных 8-байтных чисел
        "movupd (%%r11, %%r10, 8), %%xmm0\n\t" // xmm0 = matrix1[i][k:k+1]

        // Загружаем matrix2[k:k+1][j]
        "mov %[matrix2], %%r12\n\t"
        "mov (%%r12, %%r10, 8), %%rax\n\t" // rax = matrix2[k]
        // MOVSD — Переслать двойное слово из строки в строку
        "movsd (%%rax, %%r9, 8), %%xmm1\n\t" // xmm1[0] = matrix2[k][j]
        "mov 8(%%r12, %%r10, 8), %%rax\n\t"  // rax = matrix2[k+1]
        "movsd (%%rax, %%r9, 8), %%xmm3\n\t" // xmm3[0] = matrix2[k+1][j]
        "unpcklpd %%xmm3, %%xmm1\n\t"        // xmm1 = {matrix2[k][j], matrix2[k+1][j]}

        // Умножение и добавление к результату
        "mulpd %%xmm1, %%xmm0\n\t"
        "addpd %%xmm0, %%xmm2\n\t"

        "add $2, %%r10\n\t" // k += 2
        "jmp kLoop\n\t"

        "remainder:\n\t"
        "cmp %[M], %%r10\n\t"
        "jge exitKloop\n\t" // if (k >= M) {exitKloop}

        // Обработка случая, когда остался 1 элемент
        "mov %[matrix1], %%r11\n\t"           // r11 = matrix
        "mov (%%r11, %%r8, 8), %%r11\n\t"     // r11 = matrix1[i]
        "movsd (%%r11, %%r10, 8), %%xmm0\n\t" // xmm0[0] = matrix1[i][k]

        "mov %[matrix2], %%r12\n\t"
        "mov (%%r12, %%r10, 8), %%rax\n\t"   // rax = matrix2[k]
        "movsd (%%rax, %%r9, 8), %%xmm1\n\t" // xmm1[0] = matrix2[k][j]

        // Умножаем и добавляем к результату
        "mulsd %%xmm1, %%xmm0\n\t"
        "addsd %%xmm0, %%xmm2\n\t"

        "inc %%r10\n\t" // k++
        "jmp remainder\n\t"

        "exitKloop:\n\t"

        // movapd (Move Aligned Packed Double)
        "movapd %%xmm2, %%xmm0\n\t"   // xmm0 = xmm2
        "unpckhpd %%xmm2, %%xmm0\n\t" // xmm0 = {high(xmm2), ?}
        //  (Add Scalar Double) — складывает только нижние 64 бита
        "addsd %%xmm0, %%xmm2\n\t" // xmm2[0] += xmm0[0]

        // Помещаем результат в результирующую матрицу
        "mov %[res_matrix_data], %%r11\n\t"
        "mov (%%r11, %%r8, 8), %%r11\n\t"    // r11 = res_matrix_data[i]
        "movsd %%xmm2, (%%r11, %%r9, 8)\n\t" // res_matrix_data[i][j] = xmm2[0]

        "inc %%r9\n\t" // j++
        "jmp jLoop\n\t"

        "exitJloop:\n\t"
        "inc %%r8\n\t" // i++
        "jmp iLoop\n\t"

        "exitIloop:\n\t"
        :
        : [L] "r"(L), [N] "r"(N), [M] "r"(M),
          [matrix1] "r"(matrix1), [matrix2] "r"(matrix2),
          [res_matrix_data] "r"(res_matrix_data)
        : "cc", "r8", "r9", "r10", "r11", "r12", "rax", "rcx",
          "xmm0", "xmm1", "xmm2", "xmm3", "memory");

    return res_matrix;
}

double **Matrix::get_matrix_data()
{
    return matrix_data;
}

void Matrix::set_matrix_data(double **matrixData)
{
    matrix_data = matrixData;
}

void Matrix::free_matrix()
{
    for (int i = 0; i < rows; i++)
    {
        if (matrix_data[i])
            free(matrix_data[i]);
    }
    if (matrix_data)
        free(matrix_data);

    matrix_data = nullptr;
}

void Matrix::allocate_matrix()
{
    if (rows <= 0 || cols <= 0)
    {
        throw std::runtime_error("No initialize size");
    }
    if (matrix_data)
    {
        free_matrix();
    }

    matrix_data = (double **)malloc(rows * sizeof(double *));
    if (matrix_data == nullptr)
    {
        throw std::runtime_error("Memory allocation error");
    }
    for (int i = 0; i < rows; i++)
    {
        double *tmp = (double *)malloc(cols * sizeof(double));
        if (tmp == nullptr)
        {
            throw std::runtime_error("Memory allocation error");
        }
        (matrix_data)[i] = tmp;
    }
}
