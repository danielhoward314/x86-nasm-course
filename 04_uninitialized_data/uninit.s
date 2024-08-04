section .bss
    num RESB 4

section .data
    list DB "ABA", 0

section .text
global _start

_start:
    MOV bl, 1
    MOV [num], bl
    XOR bl, bl
    MOV bl, 2
    MOV [num+1], bl
    XOR bl, bl
    MOV bl, 3
    MOV [num+2], bl
    XOR bl, bl
    MOV bl, 4
    MOV [num+3], bl
    XOR bl, bl
    MOV ebx, [num]
    MOV ecx, [list]
    MOV eax, 1
    INT 80h