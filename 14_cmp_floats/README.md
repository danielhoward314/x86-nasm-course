# Assemble, link, debug

```
nasm -f elf -o cmp_float.o cmp_float.s

ld -m elf_i386 -o cmp_float cmp_float.o

gdb
layout asm
break _start
run
```

# Comparing floats

Instead of `CMP`, we need to use `UCOMISS` for comparing floats. This works similarly to the the regular comparison, placing values into different flags based on the comparison, which can then be used in subsequent jump instructions that will look to these flags. We also need to use different jump instructions.

Floating point jumps
```
JE ; same
JA ; jump above
JB ; jump below
```

What does the `eflags` register look like in each case?

For a comparison of the form, `UCOMISS a, b`, when a is:

- greater -> [ IF ]
- lesser -> [ CF IF ]
- equal -> [ ZF IF ]