section .note.GNU-stack noalloc noexec nowrite progbits

section .text
    global test_asm

test_asm:
    mov eax, 7
    ret
