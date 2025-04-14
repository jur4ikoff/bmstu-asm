#include <stdio.h>

size_t len(const char *str)
{
    __asm__(
        "mov al, 0\n"
        "mov ecx, -1\n"
        "push edi\n"
        "mov edi, dword ptr [ebp+8]\n"
        "cld\n"         // Сбрасывает флаг направления (DF = 0), чтобы scasb увеличивал edi (двигался вперёд по строке).
        "repne scasb\n" // scasb сравнивает байт в [edi] с al (ищем \0). Увеличивает edi на 1 (так как DF = 0). repne (Repeat While Not Equal): Повторяет scasb, пока: ecx не станет 0 или не найдётся байт, равный al (нулевой терминатор).
        "sub edi, dword ptr [ebp+8]\n" // Вычитает из текущего edi (указатель на конец строки) начальный адрес строки ([ebp+8]). Результат - количество пройденных байтов + 1 (так как scasb делает edi++ после сравнения).
        "mov eax, edi\n"
        "dec eax\n"
        "pop edi\n"
        "pop ebp\n"
        "ret\n");
}

int main(void)
{
    char *str = "test";
    printf("%s\n", str);

    printf("%zu\n", len(str));
    return 0;
}
