section .note.GNU-stack noalloc noexec nowrite progbits

section .text
    global print_decimal, print_truncated_hex, check_power_of_two
    extern printf, scanf

print_decimal:
    ret 
print_truncated_hex:
    ret

check_power_of_two:
    ret