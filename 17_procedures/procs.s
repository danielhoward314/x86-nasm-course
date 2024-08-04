section .text
global _start

_start:
    MOV eax, 4
    MOV ebx, 1
    CALL addTwo
    JMP end
    
addTwo:
    ADD eax, ebx
    RET

end:
    MOV ebx, eax ; preserve result of addTwo
    MOV eax, 1
    INT 80h