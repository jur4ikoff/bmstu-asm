#include <iostream>

extern "C" void test_asm();

int main()
{
    int i;

    __asm volatile(
        "mov eax, 5\n"
        "mov %0, eax"
        : "=r"(i)
        :
        : "eax");

    std::cout << i;

    test_asm();

    __asm volatile
    (   
        "mov %0, eax"
        : "=r" (i)
        :
        : "eax"
    );

    std::cout << i << std::endl;
    return 0;
    
}
