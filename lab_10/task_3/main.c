#include <math.h>
#include <stdio.h>

#define ERR_OK 0
#define ERR_INPUT 1
#define ERR_NO_ROOT 2

// static double seven asm("seven") = 7;

// Функция для которой ищем корень: cos(x^3 + 7)
double f(double x)
{
    return cos(x * x * x + 7.0);
}

// Ассемблерная реализация функции с использованием x87
double f_asm(double x)
{
    double result;

    float inc = 7.0;
    __asm__(
        "fld %1\n"  // push x в st(0)
        "fld %1\n"  // st(0) = x, st(1) = x
        "fmulp\n"   // st(0) = x*x  FMULP Умножение с извлечением из стека
        "fld %1\n"  // st(0) = x, st(1) = x*x
        "fmulp\n"   // st(0) = x^3
        "fadd %2\n" // st(0) = x^3 + 7.0
        "fcos\n"    // st(0) = cos(7.0 + x^3)
        "fstp %0\n" // Сохраняем результат и выталкиваем из стека
        : "=m"(result)
        : "m"(x), "m"(inc));
    return result;
}

// Метод хорд с ассемблерными вставками
double chord_method(double a, double b, int iterations)
{
    double fa, fb, c, fc;

    // Вычисляем начальные значения функции в точках a и b
    fa = f_asm(a);
    fb = f_asm(b);

    for (int i = 0; i < iterations; i++)
    {
        // Вычисляем новую точку по методу хорд
        __asm__(
            "fld %[fb]\n" // st(0) = fb
            "fld %[a]\n"  // st(0) = a, st(1) = fb
            "fmulp\n"     // st(0) = a*fb
            "fld %[fa]\n" // st(0) = fa, st(1) = a*fb
            "fld %[b]\n"  // st(0) = b, st(1) = fa, st(2) = a*fb
            "fmulp\n"     // st(0) = b*fa, st(1) = a*fb
            "fsubp\n"     // st(0) = a*fb - b*fa
            "fld %[fb]\n" // st(0) = fb, st(1) = (a*fb - b*fa)
            "fld %[fa]\n" // st(0) = fa, st(1) = fb, st(2) = (a*fb - b*fa)
            "fsubp\n"     // st(0) = fb - fa, st(1) = (a*fb - b*fa)
            "fdivp\n"     // st(0) = (a*fb - b*fa)/(fb - fa)
            "fstp %[c]\n" // Сохраняем результат в c и выталкиваем из стека
            : [c] "=m"(c)
            : [a] "m"(a),
              [b] "m"(b),
              [fa] "m"(fa),
              [fb] "m"(fb));

        // Вычисляем значение функции в новой точке
        fc = f_asm(c);

        // Обновляем границы интервала
        if (fa * fc < 0.0)
        {
            b = c;
            fb = fc;
        }
        else
        {
            a = c;
            fa = fc;
        }
    }

    return c;
}

void error_handler(int rc)
{
    switch (rc)
    {
        case ERR_INPUT:
            printf("Ошибка ввода\n");
        case ERR_NO_ROOT:
            printf("На данном интервале либо нет корней, либо их четное количество.\n");
    }
}

int main()
{
    double a, b, root;
    int iterations;

    printf("Программа ищет корен функции f(x) = cos(x ^ 3 + 7)\n");

    // Ввод границ
    printf("Введите левую и правую границу интервала через пробел: ");
    if (scanf("%lf %lf", &a, &b) != 2)
    {
        error_handler(ERR_INPUT);
        return ERR_INPUT;
    }

    printf("Введите количество итераций: ");
    if (scanf("%d", &iterations) != 1)
    {
        error_handler(ERR_INPUT);
        return ERR_INPUT;
    }

    // Проверка наличия корня на интервале
    if (f(a) * f(b) >= 0.0)
    {
        error_handler(ERR_NO_ROOT);
        return ERR_NO_ROOT;
    }

    root = chord_method(a, b, iterations);

    printf("Приближенное значение корня: %.15lf\n", root);
    printf("Значение функции в корне: %.15lf\n", f(root));

    return 0;
}
