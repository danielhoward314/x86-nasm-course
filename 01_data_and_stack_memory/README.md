# Assemble, link, debug

```
nasm -f elf -o data.o data.s

ld -m elf_i386 -o data data.o

gdb
layout asm
break _start
run
```

# First version

The first version of the program attempt to initialize data in the `.data` section and then use that value for the exit code. This version has the following:

```
section .data
    num DD 5

section .text
global _start

_start:
    MOV eax, 1
    MOV ebx, num
    INT 80h
```

If we debug, step through until we are on the last line, and check the value in register ebx:

```
info registers ebx
```

This prints a memory address rather than `5`. If we use a different technique of `gdb`, we can print the value at the memory address:

```
x/x $ebx
```

The value printed should be `5` and the hex value at the far left should be the memory address we saw previously.

All that's needed is to get the value at the address and store that in the register:

```
MOV ebx, [num]
```