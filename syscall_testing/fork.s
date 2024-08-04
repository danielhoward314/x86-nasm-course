section .data
    result dd 0
    output db "Result: ", 0
    newline db 10, 0

section .bss
    result_str resb 10

section .text
global _start

_start:
    ; Fork the process
    mov eax, 2 ; `fork` syscall
    int 80h

    ; Check return value of fork
    ; It tells us by pid if we are in child, parent, or fork failed
    cmp eax, 0
    jl fork_failed
    je child_process

parent_process:
    ; Use `waitpid` syscall to wait for child process to exit
    mov eax, 7
    xor ebx, ebx ; child process pid is 0
    xor ecx, ecx
    xor edx, edx
    int 80h

    ; Read result from shared memory
    mov eax, [result]

    ; Convert integer result to string
    mov edi, result_str + 9 ; point to end of buffer
    mov byte [edi], 0 ; store null terminator at end of buffer
    dec edi

convert_loop:
    mov ebx, 10
    xor edx, edx
    div ebx
    add dl, '0'
    mov [edi], dl
    dec edi
    test eax, eax
    jnz convert_loop

    inc edi

    ; Write `output` to stdout
    mov eax, 4
    mov ebx, 1 ; file descriptor for stdout
    mov ecx, output
    mov edx, 8 ; length of `output`
    int 80h

    ; Write `result_str` to stdout
    mov eax, 4
    mov ebx, 1 ; file descriptor for stdout
    mov ecx, edi
    mov esi, result_str + 10
    sub esi, edi
    mov edx, esi
    int 80h

    mov eax, 4
    mov ebx, 1 ; file descriptor for stdout
    mov ecx, newline
    mov edx, 1
    int 80h

    xor ebx, ebx
    mov eax, 1
    int 80h

child_process:
    mov eax, 5
    mov ebx, 10
    add eax, ebx
    
    ; store addition result in shared memory
    mov [result], eax

    ; exit child process
    xor ebx, ebx
    mov eax, 1
    int 80h

fork_failed:
    mov eax, 1
    mov ebx, -1
    int 80h
