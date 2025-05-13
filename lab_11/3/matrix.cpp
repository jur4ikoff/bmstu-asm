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
        "xor %%r8, %%r8\n\t" // r8 = i
        "iLoop:\n\t"
        "cmp %[L], %%r8\n\t"
        "jge exitIloop\n\t"

        "xor %%r9, %%r9\n\t" // r9 = j
        "jLoop:\n\t"
        "cmp %[N], %%r9\n\t"
        "jge exitJloop\n\t"

        "pxor %%xmm2, %%xmm2\n\t" // sum accumulator

        "xor %%r10, %%r10\n\t"
        "kLoop:\n\t"
        "cmp %[M], %%r10\n\t"
        "jge exitKloop\n\t"
        "mov %[M], %%rcx\n\t"
        "sub %%r10, %%rcx\n\t"
        "cmp $2, %%rcx\n\t"
        "jl remainderHandler\n\t"

        // Section 2 doubles evaluation
        // matrix1[i][k]
        "mov %[matrix1], %%r11\n\t"
        "mov %%r8, %%rax\n\t"
        "shl $3, %%rax\n\t" // i * sizeof(double*)
        "add %%r11, %%rax\n\t"
        "mov (%%rax), %%rax\n\t" // rax = matrix1[i]
        "mov %%r10, %%rcx\n\t"
        "shl $3, %%rcx\n\t"    // k * sizeof(double)
        "add %%rcx, %%rax\n\t" // rax = &matrix1[i][k]

        // matrix2[k][j]
        "mov %[matrix2], %%r12\n\t"
        "mov %%r10, %%rbx\n\t"
        "shl $3, %%rbx\n\t" // k * sizeof(double*)
        "add %%r12, %%rbx\n\t"
        "mov (%%rbx), %%rbx\n\t" // rbx = matrix2[k]
        "mov %%r9, %%rcx\n\t"
        "shl $3, %%rcx\n\t"    // j * sizeof(double)
        "add %%rcx, %%rbx\n\t" // rbx = &matrix2[k][j]

        // SSE processing
        "movupd (%%rax), %%xmm0\n\t" // load matrix1[i][k:k+1]
        "movupd (%%rbx), %%xmm1\n\t" // load matrix2[k:k+1][j]
        "mulpd %%xmm1, %%xmm0\n\t"   // xmm0 = product
        "addpd %%xmm0, %%xmm2\n\t"   // accumulate

        "add $2, %%r10\n\t"
        "jmp kLoop\n\t"

        "remainderHandler:\n\t"
        "cmp %[M], %%r10\n\t"
        "jge exitKloop\n\t"

        // matrix1[i][k]
        "mov %[matrix1], %%r11\n\t"
        "mov %%r8, %%rax\n\t"
        "shl $3, %%rax\n\t"
        "add %%r11, %%rax\n\t"
        "mov (%%rax), %%rax\n\t"
        "mov %%r10, %%rcx\n\t"
        "shl $3, %%rcx\n\t"
        "add %%rcx, %%rax\n\t"

        // matrix2[k][j]
        "mov %[matrix2], %%r12\n\t"
        "mov %%r10, %%rbx\n\t"
        "shl $3, %%rbx\n\t"
        "add %%r12, %%rbx\n\t"
        "mov (%%rbx), %%rbx\n\t"
        "mov %%r9, %%rcx\n\t"
        "shl $3, %%rcx\n\t"
        "add %%rcx, %%rbx\n\t"

        "movsd (%%rax), %%xmm0\n\t"
        "movsd (%%rbx), %%xmm1\n\t"
        "mulsd %%xmm1, %%xmm0\n\t"
        "addsd %%xmm0, %%xmm2\n\t"

        "inc %%r10\n\t"
        "jmp remainderHandler\n\t"

        "exitKloop:\n\t"
        "writeData:\n\t"
        // resMatrixData[i][j]
        "mov %[resMatrixData], %%r11\n\t"
        "mov %%r8, %%rax\n\t"
        "shl $3, %%rax\n\t" // i * sizeof(double*)
        "add %%r11, %%rax\n\t"
        "mov (%%rax), %%rax\n\t" // rax = resMatrixData[i]
        "mov %%r9, %%rcx\n\t"
        "shl $3, %%rcx\n\t"    // j * sizeof(double)
        "add %%rcx, %%rax\n\t" // rax = &resMatrixData[i][j]

        "movapd %%xmm2, %%xmm0\n\t"
        "shufpd $1, %%xmm2, %%xmm2\n\t"
        "addpd %%xmm0, %%xmm2\n\t"
        "movsd %%xmm2, (%%rax)\n\t"

        "inc %%r9\n\t"
        "jmp jLoop\n\t"

        "exitJloop:\n\t"
        "inc %%r8\n\t"
        "jmp iLoop\n\t"

        "exitIloop:\n\t"
        :
        : [L] "r"(L), [N] "r"(N), [M] "r"(M),
          [matrix1] "r"(matrix1), [matrix2] "r"(matrix2), [resMatrixData] "r"(res_matrix_data)
        : "r8", "r9", "r10", "r11", "r12", "rax", "rbx", "rcx", "xmm0", "xmm1", "xmm2", "memory");

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
