#include <stdio.h>

// Программа из методички №1
// int main()
// {
// int i;
// __asm {
// mov eax, 5;
// mov i, eax;
// }
// std::cout << i;
// return 0;
// }

int main(void)
{
    int i;
    __asm volatile(
        "mov eax, 5\n"
        "mov %0, eax"
        
        : "=r"(i)
        :
        : "eax");
    printf("%d\n", i);
    return 0;
}
