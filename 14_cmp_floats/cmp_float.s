section .data
    x DD 3.1
    y DD 3.1

section .text
global _start

_start:
    MOVSS xmm0, [x]
    MOVSS xmm1, [y]
    UCOMISS xmm0, xmm1
    JA greater
    JB lesser
    MOV ebx, 0
    JE end

greater:
    MOV ebx, 1
    JMP end

lesser:
    MOV ebx, 2
    JMP end

end:
    MOV eax, 1
    INT 80h