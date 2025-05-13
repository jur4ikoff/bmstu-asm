#ifndef MATRIX_H
#define MATRIX_H

#include <iostream>
#include <cstring>

class BaseMatrix
{
public:
    BaseMatrix() = default;
    virtual ~BaseMatrix() = default;
    virtual void allocate_matrix() = 0;
    virtual void readMatrix() = 0;
    virtual void printMatrix() = 0;

protected:
    virtual void freeMatrix() = 0;
    double **matrix_data;
    int rows = 0, cols = 0;
};

class Matrix final : public BaseMatrix
{
public:
    Matrix()
    {
        matrix_data = nullptr;
    }
    Matrix(int n, int m);

    Matrix &operator=(const Matrix &other);
    void readMatrix() override;
    void printMatrix() override;
    double **getMatrixData();
    void setMatrixData(double **matrixData);

    ~Matrix()
    {
        freeMatrix();
    };

    friend Matrix sseMatrixMul(Matrix &m1, Matrix &m2);

protected:
    void freeMatrix() override;
    void allocate_matrix() override;
};

#endif