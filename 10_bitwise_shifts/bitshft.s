section .text
global _start

_start:
    MOV eax, 2
    SHR eax, 1

    XOR eax, eax

    MOV eax, 2
    SHL eax, 1
    INT 80h