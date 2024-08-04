section .data
    pathname DD "/home/daniel/Documents/repos/olivestem_asm_yt_playlist/21_create_files/test.txt"
    toWrite DD "0123456",0AH,0DH,"$"

section .text
global _start

_start:
    MOV eax, 5
    MOV ebx, pathname
    MOV ecx, 101o ; octal value that ORs O_CREAT (0100) and WR_ONLY (01)
    MOV edx, 700o ; octal for permissions
    INT 80h

    MOV ebx, eax ; file descriptor return into `fd` argument for `write`
    MOV eax, 4 ; `write` syscall
    MOV ecx, toWrite
    MOV edx, 10 ; toWrite length
    INT 80h

    cmp eax, 0
    JL .error; `write` returns -1 on error

    MOV eax, 1
    MOV ebx, 0
    INT 80h

.error:
    MOV ebx, eax
    MOV eax, 1
    INT 80h