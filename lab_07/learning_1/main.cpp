#include <iostream>


int main(void)
{
    int i;
    __asm volatile(
        "mov eax, 5\n"
        "mov %0, eax"

        : "=r"(i)
        :
        : "eax");
    
    std::cout << i << std::endl;
    return 0;
}
