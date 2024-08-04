# Assemble, link, debug

```
nasm -f elf -o uninit.o uninit.s

ld -m elf_i386 -o uninit uninit.o

gdb
layout asm
break _start
run
```

# Naive movement of data into uninitialized memory block

The `.bss` section is used to reserve memory for variables without assigning any value to the variable:

```
section .bss
    num RESB 3
```

Above is how we can reserve 3 bytes of memory for the variable `num`.

If we wanted to assign a value to `num`, we might be tempted to do the following:

```
MOV [num], 1
```

If you try to assemble a program with this, you get an error from `nasm`:

```
error: operation size not specified
```

The problem is that x86 assembly does not know the size of this variable or the size of the immediate, `1`.

You have to assign the value to a register of the appropriate size and then move the value from the register into the variable. This assignment can move values into all or part of the variable, either by using a value that is the full byte-width of the variable or by using a value that only takes up part of its width. When assigning to part of the variable, you can use address offsets. The program in its final form does parts with offsets using the `bl` register and the `num` variable; it does assignment to the whole variable with the `ecx` register and the `list` variable.