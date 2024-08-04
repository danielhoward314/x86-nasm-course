section .text
global _start

_start:
    MOV eax, 0b1010
    MOV ebx, 0b0010
    AND eax, ebx

    XOR eax, eax
    XOR ebx, ebx

    MOV eax, 0b1010
    MOV ebx, 0b0110
    OR eax, ebx

    XOR eax, eax
    XOR ebx, ebx

    MOV eax, 0b1010
    NOT eax
    AND eax, 0xF

    XOR eax, eax
    XOR ebx, ebx

    MOV eax, 0b1010
    MOV ebx, 0b0110
    XOR eax, ebx

    INT 80h