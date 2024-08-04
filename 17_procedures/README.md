# Assemble, link, debug

```
nasm -f elf -o procs.o procs.s

ld -m elf_i386 -o procs procs.o

gdb
layout asm
break _start
run
```

# How does the program move into and out of procedures?

If we check what is stored in register `esp` just before and just after the `CALL` instruction, what do we see?

- before
```
info register esp ; some address, e.g. 0xffffd1e0
x/x <esp_val> ; doesn't seem important, is 0x00000001
```

- after
```
info register esp ; some address, e.g. 0xffffd1e0
x/x <esp_val> ; address of next line in `_start` after the `CALL` instruction
```

The `esp` register holds the address of where to resume execution after we finish the `addTwo` procedure. This works by using the `eip`, or the instruction pointer. Usually, `eip` just increments by 1 to keep executing top-to-bottom. However, when we use the `RET` instruction, the value of `esp` is popped off the stack and put into `eip`.