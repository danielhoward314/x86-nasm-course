extern printf
extern exit

section .data
    fmtVal DD "goes into percent s", 0
    fmtS DB "this is my msg: %s", 10, 0

section .text
global main
main:
    PUSH fmtVal
    PUSH fmtS
    CALL printf
    PUSH 1
    CALL exit