# Assemble, link, debug

```
nasm -f elf -o loops.o loops.s

ld -m elf_i386 -o loops loops.o

gdb
layout asm
break _start
run
```

# Loops

We can use `eax` as the index, or `i` as in higher-level languages, and use offsets from the starting address of a list of data.

The loop sub-routine itself can be written in different ways. From the video:

```
loop:
    MOV bl, [list+eax]
    ADD cl, bl
    INC eax
    CMP eax, 4
    JE end
    JMP loop
```

The following behaves the same way and matches up more with how I think about loops in higher-level languages.

```
loop:
    CMP eax, 4
    JE end
    MOV bl, [list+eax]
    ADD cl, bl
    INC eax
    JMP loop
```