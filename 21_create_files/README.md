# Assemble, link, debug

```
nasm -f elf -o cf.o cf.s

ld -m elf_i386 -o cf cf.o

gdb
layout asm
break _start
run
```