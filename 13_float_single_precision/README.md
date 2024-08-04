# Assemble, link, debug

```
nasm -f elf -o float.o float.s

ld -m elf_i386 -o float float.o

gdb
layout asm
break _start
run
```

# Floats Single Precision

The `MOVSS` is like a move, where the trailing letters mean "scalar", as opposed to "packed" values or multiple values packed into a register, and "single" as in single precision (32-bit floats). We need to use `xmm0`-`xmm15` to store floating point values. The same trailing `SS` is used on the arithmetic operations for single precision floats (e.g. `ADDSS`).


When debugging, to see the value of one of these floats:

```
p $xmm0.v4_float[0]
```

The values are slightly off. This happens in floating point. Different rounding strategies need to be used to deal with this lack of precision.