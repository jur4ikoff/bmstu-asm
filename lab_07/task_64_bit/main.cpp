#include <iostream>

extern "C" void my_strcpy(char *dst, const char *src, int len);

size_t my_strlen(const char *string)
{
    size_t res = 0;
    __asm__ volatile(
        "push rdi\n"                // Сохраняем edi
        "mov al, 0\n"               // Ищем нулевой байт
        "mov rcx, -1\n"             // Максимальное количество итераций
        "mov rdi, %1\n"             // Загружаем указатель на строку
        "cld\n"                     // Направление - вперед
        "repne scasb\n"             // Ищем нулевой байт
        "sub rdi, %1\n"             // Вычисляем длину
        "mov rax, rdi\n"            // Переносим результат в eax
        "dec rax\n"                 // Корректируем длину
        "mov %0, rax\n"             // Сохраняем результат
        "pop rdi\n"                 // Восстанавливаем edi
        : "=r"(res)                 // Выходной параметр
        : "r"(string)               // Входной параметр
        : "rax", "rcx", "rdi", "cc" // Разрушаемые регистры
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
    return 0;
}