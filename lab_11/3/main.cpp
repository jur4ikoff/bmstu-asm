#include <iostream>
#include <exception>
#include "matrix.h"

#define ERR_WRONG_SIZE_TEXT "Неверно введен размер матрицы"
#define ERR_WRONG_SIZE 1
#define ERR_MATRIX 2

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

    // try
    // {
    //     matrix1.readMatrix();
    // }
    // catch (std::runtime_error &ex)
    // {
    //     std::cout << ex.what();
    //     return ERR_MATRIX;
    // }

    // try
    // {
    //     m2.readMatrix();
    // }
    // catch (std::runtime_error &ex)
    // {
    //     std::cout << ex.what();
    //     return 1;
    // }

    // std::cout << "Матрица 1: \n";
    // matrix1.printMatrix();
    // std::cout << "Матрица 2: \n";
    // m2.printMatrix();
    // Matrix resMatrix;
    // try
    // {
    //     resMatrix = sseMatrixMul(matrix1, m2);
    // }
    // catch (std::invalid_argument &ex)
    // {
    //     std::cout << ex.what();
    //     return 1;
    // }

    // std::cout << "Результат умножения\n";
    // resMatrix.printMatrix();
}