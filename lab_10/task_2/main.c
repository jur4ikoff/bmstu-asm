#include <stdio.h>
#include <math.h>

#define GET_FPU_PI(f_pi) \
    asm volatile(        \
        "fldpi\n"        \
        "fstp %0\n"      \
        : "=m"(f_pi));

void test_case(const char *label, float value)
{
    float sin_pi = sinf(value);
    float sin_half_pi = sinf(value / 2);
    float error_pi = fabsf(sin_pi - 0.0f);
    float error_half_pi = fabsf(sin_half_pi - 1.0f);
    printf("%-15s%-15.8f%-15.8f%-15.8f\n",
           label, sin_pi, sin_half_pi, error_pi + error_half_pi);
}

int main(void)
{
    const float pi_approx_1 = 3.14f;
    const float pi_approx_2 = 3.141596f;
    float pi_fpu;

    GET_FPU_PI(pi_fpu)

    printf("%-15s%-15s%-15s%-15s\n", "Pi value", "sin(Pi)", "sin(Pi/2)", "Error");
    printf("---------------------------------------------------\n");

    test_case("3.14 (float)", pi_approx_1);
    test_case("3.141596 (float)", pi_approx_2);
    test_case("FPU float", pi_fpu);
}
