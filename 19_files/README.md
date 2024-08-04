# Assemble, link, debug

```
nasm -f elf -o files.o files.s

ld -m elf_i386 -o files files.o

gdb
layout asm
break _start
run
```

# Linux Syscall Table

The video has a link to a syscall table reference. We can look at the Linux source on a given system to see:

```
cat /usr/include/asm/unistd_32.h # for x86
cat /usr/include/asm/unistd_64.h # for x86-64
```

In what registers do we put arguments? Chatgpt says the syscall number goes into `eax`/`rax` and then the arguments go into:

1. ebx/rbx
2. ecx/rcx
3. edx/rdx
4. esi/rsi
5. edi/rdi

The return values go into `eax`.

Putting all this together, we can use the `open` and `read` syscalls to open a file and then read some bytes from it. Comments in the source file spell out how we put data in registers as needed for each syscall. Stepping through the program, once we get past the `INT 80h` line that invokes the `read` syscall, we can do the following to see the byte we read printed out as an ASCII string:

```
info register ecx
x/1s <address>
```

The first line reads the register where we put the pointer to the buffer, the second line reads 1 byte as a string.