# Assemble, link, debug

```
nasm -f elf -o logops.o logops.s

ld -m elf_i386 -o logops logops.o

gdb
layout asm
break _start
run
```

# Logical operators

AND
```
[1010]
[0010]
------
[0010]
```

OR
```
[1010]
[0110]
------
[1110]
```

NOT (naive expection)
```
[1010]
------
[0101]
```

NOT
```
[xxxx-1010]
------
[notXnotXnotXnotX-0101]
```

The `NOT` operation will flip the bits of the entire registers, which can cause unexpected results if we passed in a binary value with fewer bits than the width of the register.

How can we flip only the bits we intend? We can perform an `AND` operation to retroactively flip the unwanted flips back to their previous values. We perform `AND` with the register that has our not'd value and a mask, or a value that ensures the truth tables work out to undo unwanted bit flips: `AND eax, 0x0000000F`. The leading zeros of the mask are not needed, but illustrate how the mask bits will line up with the full width of the `eax` register: `AND eax, 0xF`.

Let's assume a concrete example for the `NOT` and `AND`:

```
NOT
[0000-1010] ; we only want to flip least significant 4 bits
-----------
[1111-0101] ; however, NOT flipped them all

AND
[1111-0101] ; using result from NOT
[0000-1111] ; mask guaranteed to reverse unwanted flips and keep wanted ones
-----------
[0000-0101] ; gets us the intended bit flips
```

The `XOR` operation is an exclusive-OR, so only a single 1 bit results in a 1 bit, otherwise the result is a 0.

XOR
```
[1010]
[0110]
------
[1100]
```