section .bss
    argvBuffer resd 3
    envpBuffer resd 2

section .data
    path DD "./test.sh"
    program DB "test.sh",0
    arg DB "argOne",0
    argNull DB 0
    envData DB "key=value",0
    envNull DB 0

section .text
global _start

_start:
    MOV dword [argvBuffer], program
    MOV dword [argvBuffer + 4], arg
    MOV dword [argvBuffer + 8], argNull

    MOV dword [envpBuffer], envData
    MOV dword [envpBuffer + 4], envNull

    MOV eax, 11 ; `execve` syscall
    MOV ebx, path
    MOV ecx, argvBuffer
    MOV edx, envpBuffer
    INT 80h
