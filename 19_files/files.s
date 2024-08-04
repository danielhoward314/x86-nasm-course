section .bss
    buffer resb 10

section .data
    pathname DD "./test.txt"

section .text
global _start

_start:
    MOV eax, 5 ; `open` syscall number
    MOV ebx, pathname
    MOV ecx, 0 ; read only flag for `open` syscall
    INT 80h

    MOV ebx, eax ; move file descriptor return from `open` into arg1 for `read`
    MOV eax, 3 ; read syscall number
    MOV ecx, buffer
    MOV edx, 1 ; read 1 byte
    INT 80h

    TEST eax, eax ; sets zero flag (ZF) to 1 if bitwise AND is 0
    JZ .error ; jump to label operand if ZF is set
 
    MOV eax, 1
    MOV ebx, 0
    INT 80h

.error:
    MOV ebx, eax
    MOV eax, 1
    INT 80h