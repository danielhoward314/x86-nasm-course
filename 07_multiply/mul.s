section .text
global _start

_start:
    MOV al, 255
    MOV bl, 2
    MUL bl ; A register is accumulator, assumed destination for MUL

    XOR al, al
    XOR bl, bl

    MOV al, 255
    MOV bl, 2
    IMUL bl
    INT 80h