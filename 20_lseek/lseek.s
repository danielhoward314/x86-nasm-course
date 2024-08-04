section .data
    pathname DD "/home/daniel/Documents/repos/olivestem_asm_yt_playlist/20_lseek/test.txt"

section .bss
    buffer resb 10

section .text
global _start

_start:
    MOV eax, 5; `open` syscall number
    MOV ebx, pathname
    XOR ecx, ecx ; 0 is read-only mode argument for `open`
    INT 80h

    MOV ebx, eax ; file descriptor return into fd arg for lseek
    MOV eax, 19 ; `lseek` syscall
    MOV ecx, 10 ; offset arg, behavior depends on whence arg
    XOR edx, edx ; 0 is whence value for SEEK_SET
    INT 80h

    MOV eax, 3 ; read syscall
    ; ebx still has file descriptor stored in it
    MOV ecx, buffer
    MOV edx, 10
    INT 80h
    TEST eax, eax
    JZ .error

    MOV eax, 1
    MOV ebx, 0
    INT 80h

.error:
    MOV ebx, eax
    MOV eax, 1
    INT 80h