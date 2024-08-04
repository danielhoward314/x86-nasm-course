# Assemble, link, debug

```
nasm -f elf -o div.o div.s

ld -m elf_i386 -o div div.o

gdb
layout asm
break _start
run
```


# Division

The `DIV` operation takes a single operand, divides the A register by this operand and stores the result into the A register. Any remainder is stored in the D register. The `IDIV` operation is for signed division.