section .text
global _start

_start:
    MOV eax, 2
    MOV ebx, 3
    CMP eax, ebx
    JL lesser
    JMP end

lesser:
    ADD ecx, 1
    JMP end

end:
    INT 80h
