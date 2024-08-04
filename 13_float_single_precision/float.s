section .data
    x DD 3.14
    y DD 2.1

section .text
global _start

_start:
    MOVSS xmm0, [x]
    MOVSS xmm1, [y]
    ADDSS xmm0, xmm1
    MOV eax, 1
    MOV ebx, 1
    INT 80h