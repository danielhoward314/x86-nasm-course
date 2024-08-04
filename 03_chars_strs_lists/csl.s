section .data
    mychar DB 'A'
    list DB "ABA", 0

section .text
global _start

_start:
    MOV bl, [mychar]
    MOV eax, 1
    INT 80h