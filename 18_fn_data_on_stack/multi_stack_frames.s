section .text
global _start

_start:
    PUSH 4
    PUSH 1
    CALL addTwo

    ADD esp, 8

    PUSH 2
    PUSH 3
    PUSH 5
    CALL addThree
    ADD esp, 12
    JMP end
    
addTwo:
    PUSH ebp
    MOV ebp, esp
    MOV eax, [ebp+8]
    MOV ebx, [ebp+12]
    ADD eax, ebx
    POP ebp
    RET

addThree:
    PUSH ebp
    MOV ebp, esp
    MOV eax, [ebp+8]
    MOV ebx, [ebp+12]
    ADD eax, ebx
    MOV ebx, [ebp+16]
    POP ebp
    RET

end:
    MOV ebx, eax
    MOV eax, 1
    INT 80h