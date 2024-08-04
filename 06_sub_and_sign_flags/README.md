# Assemble, link, debug

```
nasm -f elf -o sub.o sub.s

ld -m elf_i386 -o sub sub.o

gdb
layout asm
break _start
run
```

# Subtraction

The subtraction instruction takes the form `SUB eax, ebx`, where the second operand is subtracted from the first operand and the result is stored in the first operand.

If the value in `ebx` is larger than `eax`, then the result would be a negative number. We can inspect the `eflags` register to see that the `CF`, signifying borrowing here, and the `SF`, or sign flag, which indicates the last operation resulted in a negative number.
