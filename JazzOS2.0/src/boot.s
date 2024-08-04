BITS 32

section .text
    ALIGN 4
    DD 0x1BADB002
    DD 0x00000000
    DD -(0x1BADB002 + 0x00000000)

global start
extern kmain

start:
    CLI
    MOV esp, stack_space
    CALL kmain
    HLT
haltKernel:
    CLI
    HLT
    JMP haltKernel

section .bss
RESB 8192
stack_space: