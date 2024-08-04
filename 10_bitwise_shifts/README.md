# Assemble, link, debug

```
nasm -f elf -o bitshft.o bitshft.s

ld -m elf_i386 -o bitshft bitshft.o

gdb
layout asm
break _start
run
```

# Shift right

If we have the value 2, the binary value shifts all bits to the right as many places as the second operand supplied to the `SHR` operation. So if we shift right 1 bit when the starting value is 2:

```
0010 -> 0001
```

A shift to the right is equivalent to dividing by 2 as many times as we have shifted. So if we start with the value 8 and shift right 2 times, we should expect to get (8 / 2) / 2 = 2, which is indeed reflected when looking at the bitwise shifts:

```
1000 -> 0010
```

# Shift left

Works the same as the right shift. The left shift is equivalent to multiplying by 2.

```
0010 -> 0100
```
