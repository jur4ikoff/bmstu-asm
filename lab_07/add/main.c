#include <stdio.h>

int main(void)
{
    int a = 5, b = 10, result;

    __asm volatile(
        "add %1, %2\n"   // %1 + %2 → %2
        "mov %2, %0"     // %2 → %0
        : "=r"(result)   // %0
        : "r"(a), "r"(b) // %1 и %2
        : "cc");

    printf("%d\n", result);
    return 0;
}
