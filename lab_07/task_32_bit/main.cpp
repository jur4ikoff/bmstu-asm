#include <iostream>

extern "C" void my_strcpy(char *dst, const char *src, int len);

size_t my_strlen(const char *string)
{
    size_t res = 0;
    __asm__ volatile(
        "push edi\n"                // Сохраняем edi
        "mov al, 0\n"               // Ищем нулевой байт
        "mov ecx, -1\n"             // Максимальное количество итераций
        "mov edi, %1\n"             // Загружаем указатель на строку
        "cld\n"                     // Направление - вперед
        "repne scasb\n"             // Ищем нулевой байт
        "sub edi, %1\n"             // Вычисляем длину
        "mov eax, edi\n"            // Переносим результат в eax
        "dec eax\n"                 // Корректируем длину
        "mov %0, eax\n"             // Сохраняем результат
        "pop edi\n"                 // Восстанавливаем edi
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
    return 0;
}