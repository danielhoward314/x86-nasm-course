# Assemble, link, debug

```
nasm -f elf -o mul.o mul.s

ld -m elf_i386 -o mul mul.o

gdb
layout asm
break _start
run
```

# Multiplication

The first version multiplies two numbers and stores the result in `al`.

```
section .text
global _start

_start:
    MOV al, 3
    MOV bl, 2
    MUL bl ; A register is accumulator, assumed destination for MUL
    INT 80h
```

What happens if the result will be larger than the register sizes involved in the calculation, i.e. we change the first move instruction to `MOV al, 255`? The multiply instruction will expand the destination operand automatically to accommodate the size needed for the result. In this case, `al` will expand into `ax` to give the final result of `510`.

```
info register ax
```

The `IMUL` operation is used for signed multiplication. If we again multiply `255` and `2`, the result is `-2` when looking at either `al` or even `ax`. The reason why is because the `IMUL` operation treats operands as signed.
