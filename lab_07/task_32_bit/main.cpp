#include <iostream>

/*
makes a function-name in C++ have C linkage (compiler does not mangle the name) so that client C code can link to (use) your function using a C compatible header file that contains just the declaration of your function. Your function definition is contained in a binary format (that was compiled by your C++ compiler) that the client C linker will then link to using the C name.
Since C++ has overloading of function names and C does not, the C++ compiler cannot just use the function name as a unique id to link to, so it mangles the name by adding information about the arguments. A C compiler does not need to mangle the name since you can not overload function names in C. When you state that a function has extern "C" linkage in C++, the C++ compiler does not add argument/parameter type information to the name used for linkage.
*/
extern "C" void my_strcpy(char *dst, const char *src, int len);

// Функция измеряет длинну строки
size_t my_strlen(const char *string)
{
    size_t res = 0;
    __asm__ volatile(
        "mov al, 0\n"    // Scasb будет искать байт равный, байту в al
        "mov ecx, -1\n" // Максимальное количество итераций
        "mov edi, %1\n"  // Загружаем указатель на строку
        "cld\n"          // Направление - вперед DF = 0
        "repne scasb\n"  // Ищем al, repeat not equeal
        "sub edi, %1\n"  // Вычисляем длину
        "mov %0, edi\n"  // Переносим результат
        "dec %0\n"       // Корректируем длину, чтобы не учитывать терменирущий ноль
        
        : "=r"(res)                 // Выходной параметр
        : "r"(string)               // Входной параметр
        : "eax", "ecx", "edi", "cc" // Разрушаемые регистры
    );

    return res;
}

int main()
{
    const char *string = "abcdef";
    int len = static_cast<int>(my_strlen(string));
    std::cout << len << std::endl;

    char *dest = (char *)malloc(sizeof(char) * (len + 1));
    my_strcpy(dest, string, len + 1);
    std::cout << dest << std::endl;

    my_strcpy(dest, "test", len + 1);
    std::cout << dest << std::endl;

    free(dest);
    return 0;
}