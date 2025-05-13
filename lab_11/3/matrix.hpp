#ifndef MATRIX_H
#define MATRIX_H

#include <cstring>
#include <iostream>

class Matrix
{
public:
    Matrix(int n, int m);

    // Matrix &operator=(const Matrix &other);
    // void readMatrix() override;
    // void printMatrix() override;
    // double **getMatrixData();
    // void setMatrixData(double **matrixData);

    ~Matrix()
    {
        free_matrix();
    };

    // friend Matrix sseMatrixMul(Matrix &m1, Matrix &m2);

protected:
    void allocate_matrix();
    void free_matrix();

private:
    double **matrix_data;
    int rows = 0, cols = 0;
};

#endif
