section .data
    num0 DB 1
    num1 DB 2

section .text
global _start

_start:
    MOV bl, [num0]
    MOV cl, [num1]
    MOV eax, 1
    INT 80h