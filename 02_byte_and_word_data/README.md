# Assemble, link, debug

```
nasm -f elf -o bw.o bw.s

ld -m elf_i386 -o bw bw.o

gdb
layout asm
break _start
run
```

# First version

```
section .data
    num0 DB 1
    num1 DB 2

section .text
global _start

_start:
    MOV ebx, [num0]
    MOV ecx, [num1]
    MOV eax, 1
    INT 80h
```

When debugging this first version, we do not see the values `1` and `2` that we may expect in registers `ebx` and `ecx`:

```
stepi
info registers ebx
```

This will print `0x00000201`. We can also check the memory address that the `num0` variable points to and see what value is held at that address:

```
p &num0
x/x 0x804a000
```

This also will print `0x00000201`.

We see `0x00000201` printed because `num0` and `num1` are adjacent to each other in memory. If `p &num0` printed out memory address `0x804a000`, then `p &num1` prints out `0x804a001`. We were using 32-bit registers to store both of them. When reading the contents of `ebx` or the memory address where `num0` starts, we were getting `0x00000201` because this is a little endian system and the 4 bytes of data were laid out like the following in memory:

```
0x804a003:[0x00] 0x804a002:[0x00] 0x804a001:[0x02] 0x804a000[0x01]
```

Reading the next 2 memory addresses, `0x804a002` and `0x804a003`, confirms this ordering.

You can print a single byte at a time in `gdb`, but obviously this just allows us to see the data we intend without really solving the problem of how we're using 1-byte data in 4-byte registers:

```
x/b 0x804a000
```

The program needs to be modified to use a register whose size corresponds to the size of the data type, which is a `DB` or byte in this case. The general purpose registers can be subdivided, where the lower 16-bits of `eax` are `ax` and the higher and lower bytes of `ax` are divided into `ah` and `al`, respectively. The same goes for `ebx`, `ecx`, etc. We change the program to use `bl` and `cl` for the move of `num0` and `num1` into registers. If we step past these move instructions, we can check the context of these registers and find the values of `num0` and `num1`:

```
info registers bl
info registers cl
```

What would happen if we use the higher bits of `bx` and `cx`, i.e. assign the variables to registers `bh` and `ch`? This means modifying the program to the following:

```
section .data
    num0 DB 1
    num1 DB 2

section .text
global _start

_start:
    MOV bh, [num0]
    MOV ch, [num1]
    MOV eax, 1
    INT 80h
```

If we step through the program past the assignements, then we can inspect `bh` and `ch` to see the values we expect:

```
info registers bh
info registers ch
```

This prints `1` and `2`. However, if we inspect `bx` and `cx`, we can see the issue that may arise:

```
info registers bx
info registers cx
```

This prints `256` and `512`. The data within the registers is laid out like the following:

```
bx:bh[0x01]bl[0x00]
cx:ch[0x02]cl[0x00]
```

Since we are storing data in the higher bytes of the register, when looking at the entire register `bx` or `cx`, these 1-byte values are treated as the most significant bytes of a 2-byte value. We get `1 * (16^2) = 256` and `2 * (16^2) = 512`.