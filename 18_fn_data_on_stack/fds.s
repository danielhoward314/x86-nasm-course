section .text
global _start

_start:
    PUSH 4 ; decrements esp by 4 then places operand value into esp
    PUSH 1 ; decrements esp by 4 then places operand value into esp
    CALL addTwo ; decrements esp by 4 then places address of next line into esp
    JMP end
    
addTwo:
    PUSH ebp ; decrements esp by 4 then places operand value, old ebp, into esp
    MOV ebp, esp
; [ebp] is old ebp, [ebp+4] is return address, [ebp+8] is 1, [ebp+12] is 4
    MOV eax, [ebp+8]
    MOV ebx, [ebp+12]
    ADD eax, ebx
    POP ebp ; places operand value into esp (old epb into esp) then incs esp by 4
; [ebp] is now the return address
    RET ; gets current esp as jump adderess, increments esp, and jumps to address

end:
    MOV ebx, eax ; preserve result of addTwo
    MOV eax, 1
    INT 80h