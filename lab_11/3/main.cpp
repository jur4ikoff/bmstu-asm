#include "matrix.hpp"
#include <exception>
#include <iostream>

#define ERR_WRONG_SIZE_TEXT "Неверно введен размер матрицы"
#define ERR_WRONG_SIZE 1
#define ERR_MATRIX 2
#define ERR_MULTIPY 3

int main()
{
    int L, M, N;
    std::cout << "Введите размеры матриц L, M, N: ";
    std::cin >> L >> M >> N;
    if (L <= 0 || M <= 0 || N <= 0)
    {
        std::cout << ERR_WRONG_SIZE_TEXT << std::endl;
        return ERR_WRONG_SIZE;
    }

    Matrix matrix1(L, M);
    Matrix matrix2(M, N);

    std::cout << "Введите элементы первой матрицы " << L << "x" << M << std::endl;
    try
    {
        matrix1.read_matrix();
    }
    catch (std::runtime_error &ex)
    {
        std::cout << ex.what();
        return ERR_MATRIX;
    }

    std::cout << "Введите элементы второй матрицы " << M << "x" << N << std::endl;
    try
    {
        matrix2.read_matrix();
    }
    catch (std::runtime_error &ex)
    {
        std::cout << ex.what();
        return ERR_MATRIX;
    }

    Matrix result;
    try
    {
        result = matrix1; //  sseMatrixMul(matrix1, matrix2);
    }
    catch (std::invalid_argument &ex)
    {
        std::cout << ex.what();
        return ERR_MULTIPY;
    }

    std::cout << "Результат умножения\n";
    result.print_matrix();
}
