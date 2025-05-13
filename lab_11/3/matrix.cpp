#include "matrix.h"

Matrix::Matrix(int n, int m)
{
    // if (n <= 0 || m <= 0)
    // {
    //     throw std::runtime_error("Wrong size error");
    // }

    // this->rows = n;
    // this->cols = m;
    // this->allocate_matrix();
}

void Matrix::readMatrix()
{
    for (int i = 0; i < this->rows; i++)
    {
        for (int j = 0; j < this->cols; j++)
        {
            double elem = 0;
            std::cin >> elem;
            if (std::cin.fail())
            {
                throw std::runtime_error("Data error!");
            }
            matrix_data[i][j] = elem;
        }
    }
}

Matrix &Matrix::operator=(const Matrix &other)
{
    if (this != &other)
    {
        freeMatrix();
        rows = other.rows;
        cols = other.cols;
        if (rows > 0 && cols > 0)
        {
            matrix_data = (double **)malloc(rows * sizeof(double *));
            if (!matrix_data)
            {
                throw std::runtime_error("Memory allocation failed!");
            }
            for (size_t i = 0; i < rows; i++)
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

void Matrix::printMatrix()
{
    for (size_t i = 0; i < rows; i++)
    {
        for (size_t j = 0; j < cols; j++)
        {
            std::cout << matrix_data[i][j] << " ";
        }
        std::cout << '\n';
    }
}

void Matrix::freeMatrix()
{
    for (int i = 0; i < this->rows; i++)
    {
        if (this->matrix_data[i])
            free(this->matrix_data[i]);
    }
    if (this->matrix_data)
        free(this->matrix_data);
}

double **Matrix::getMatrixData()
{
    return matrix_data;
}

void Matrix::setMatrixData(double **matrixData)
{
    matrix_data = matrixData;
}

Matrix sseMatrixMul(Matrix &m1, Matrix &m2)
{

    if (m1.cols != m2.rows)
    {
        throw std::invalid_argument("Sizes not mathed!\n");
    }

    Matrix resMatrix(m1.rows, m2.cols);
    double **resMatrixData = resMatrix.getMatrixData();

    double **matrix1 = m1.getMatrixData();
    double **matrix2 = m2.getMatrixData();

    size_t m1Rows = m1.rows;
    size_t m2Cols = m2.cols;
    size_t m1Cols = m1.cols;

    __asm__ volatile(
        "xor %%r8, %%r8\n\t" // r8 = i
        "iLoop:\n\t"
        "cmp %[m1Rows], %%r8\n\t"
        "jge exitIloop\n\t"

        "xor %%r9, %%r9\n\t" // r9 = j
        "jLoop:\n\t"
        "cmp %[m2Cols], %%r9\n\t"
        "jge exitJloop\n\t"

        "pxor %%xmm2, %%xmm2\n\t" // sum accumulator

        "xor %%r10, %%r10\n\t"
        "kLoop:\n\t"
        "cmp %[m1Cols], %%r10\n\t"
        "jge exitKloop\n\t"
        "mov %[m1Cols], %%rcx\n\t"
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
        "cmp %[m1Cols], %%r10\n\t"
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
        : [m1Rows] "r"(m1Rows), [m2Cols] "r"(m2Cols), [m1Cols] "r"(m1Cols),
          [matrix1] "r"(matrix1), [matrix2] "r"(matrix2), [resMatrixData] "r"(resMatrixData)
        : "r8", "r9", "r10", "r11", "r12", "rax", "rbx", "rcx", "xmm0", "xmm1", "xmm2", "memory");

    return resMatrix;
}

void Matrix::allocate_matrix()
{
    if (this->matrix_data)
    {
        freeMatrix();
    }

    this->matrix_data = (double **)malloc(this->rows * sizeof(double *));
    if (!this->matrix_data)
    {
        throw std::runtime_error("Memory allocation error");
    }
    for (int i = 0; i < this->rows; i++)
    {
        double *tmp = (double *)malloc(this->cols * sizeof(double));
        if (tmp)
        {
            throw std::runtime_error("Memory allocation error");
        }
        (this->matrix_data)[i] = tmp;
    }
}
