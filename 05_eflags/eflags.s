section .data

section .text
global _start

_start:
    MOV eax, 1
    MOV ebx, 2
    ADD eax, ebx
    XOR eax, eax
    XOR ebx, ebx
    MOV al, 0b11111111
    MOV bl, 0b0001
    ADD al, bl
    ADC ah, 0
    INT 80h