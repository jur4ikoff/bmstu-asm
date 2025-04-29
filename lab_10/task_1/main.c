#include <stdio.h>
#include <time.h>

#define MAX_ITTERATIONS 10000000

void get_time(double *result)
{
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    *result = (double)ts.tv_sec + (double)ts.tv_nsec / 1e9;
}

void test_float_operations(void)
{
    float a = 1.234567f, b = 7.890123, c;

    clock_t start = clock();

    for (int i = 0; i < MAX_ITTERATIONS; i++)
    {
        c = a + b;
        c = a * b;
    }

    clock_t end = clock();
    double time_used = ((double)(end - start)) / CLOCKS_PER_SEC;
    printf("Время Double операций с сопроцессором 80387: %.6f секунд, Количество иттераций %d\n", time_used, MAX_ITTERATIONS);
}

void test_double_operations(void)
{
    double a = 1.23456742235454224423423, b = 7.890123245245244, c;

    clock_t start = clock();

    for (int i = 0; i < MAX_ITTERATIONS; i++)
    {
        c = a + b;
        c = a * b;
    }

    clock_t end = clock();
    double time_used = ((double)(end - start)) / CLOCKS_PER_SEC;
    printf("Время Double операций с сопроцессором 80387: %.6f секунд, Количество иттераций %d\n", time_used, MAX_ITTERATIONS);
}

void test_long_double_operations(void)
{
    // long double 80 byte
    long double a = 1.23456742235454224423423223424233, b = 7.89012325454252452445245244, c;

    clock_t start = clock();

    for (int i = 0; i < MAX_ITTERATIONS; i++)
    {
        c = a + b;
        c = a * b;
    }

    clock_t end = clock();
    double time_used = ((double)(end - start)) / CLOCKS_PER_SEC;
    printf("Время long double операций с сопроцессором 80387: %.6f секунд, Количество иттераций %d\n", time_used, MAX_ITTERATIONS);
}

int main(void)
{
    test_float_operations();
    test_double_operations();
    test_long_double_operations();
}