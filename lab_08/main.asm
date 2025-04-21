section .note.GNU-stack noalloc noexec nowrite progbits

section .rodata
    fmt db "%llu", 0
    fmt_out db "%llu", 10, 0
    newline db 10, 0
    

section .bss
    global number
    number resq 1

section .text
    global main
    extern printf, scanf

main:
    push rbp
    mov rbp, rsp
    sub rsp, 16

    call input_number

    mov rdi, [rel number]
    call find_greater_degree_of_two

    call print_number

    mov rsp, rbp
    pop rbp

    mov rdi, 0
    call exit


input_number:
    push rbp
    mov rbp, rsp

    lea rdi, [rel fmt]
    lea rsi, [rel number]
    mov rax, 0
    call scanf wrt ..plt 

    mov rsp, rbp
    pop rbp
    ret

print_number:
    push rbp
    mov rbp, rsp

    lea rdi, [rel fmt_out]
    mov rsi, [rel number]
    mov rax, 0
    call printf wrt ..plt

    mov rsp, rbp
    pop rbp
    ret


find_greater_degree_of_two:
    ; Число в rdi
    push rbp
    mov rbp, rsp

    mov rcx, 0
    mov rdx, 1
    


    mov rsp, rbp
    pop rbp
    ret
    
    

exit:
    ; rdi - exitcode
    mov rax, 60
    syscall