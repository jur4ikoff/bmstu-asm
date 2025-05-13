#ifndef MATRIX_H
#define MATRIX_H

#include <cstring>
#include <iostream>

class Matrix
{
public:
    Matrix()
    {
        rows = 0;
        cols = 0;
        matrix_data = nullptr;
    }

    Matrix(int n, int m);

    void read_matrix();
    void print_matrix();

    Matrix &operator=(const Matrix &other);

    double **get_matrix_data();
    void set_matrix_data(double **matrixData);

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
