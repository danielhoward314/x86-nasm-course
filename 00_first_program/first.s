section .data

section .text

global _start

_start:
    MOV eax, 1 ; put a value to indicate what syscall to invoke
    MOV ebx, 217 ; the `exit` syscall expects an operand in `ebx` for exit code
    INT 80h
    ; `int` instruction causes a software interrupt
    ; CPU looks up the address at index 80 in interrupt vector table
    ; sets instruction pointer to this address
    ; and starts executing this software interrupt handler
    ; which is in the kernel and performs the switch to kernel mode
    ; expects the syscall number to be put into register eax
    ; and this particular syscall, exit, expects an argument
    ; for the exit code be put in ebx