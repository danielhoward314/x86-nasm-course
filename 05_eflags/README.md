# Assemble, link, debug

```
nasm -f elf -o eflags.o eflags.s

ld -m elf_i386 -o eflags eflags.o

gdb
layout asm
break _start
run
```

# EFlags

If we debug the program, we can inspect the `eflags` register before and after stepping through the line with the `ADD` instruction (`stepi` can take an integer argument to step through that many lines at once).

```
info registers eflags
stepi 3
info registers eflags
```

The output should be `[ IF ]` and then `[ PF IF ]`. The `IF` is the interrupt flag which is set to allow for interrupts to be run, probably set by the OS before execution of the program. The `PF` flag is the parity flags, which is set to 1 when the result of the previous operation is an odd number.

If we step forward past the next `ADD` command and then check the eflags register again, we should see the `CF` or carry flag. Since we added 1 to a byte that was already made up of all 1s, the result has a carry and the `CF` flag is set to 1 to indicate the result carried. We can use the add-carry command or `ADC ah, 0` to add whatever value is in the operand, `0` in this case, and also whatever value is in the `CF`, `1` in this case, to the `ah` register. If we then print out what is in `ax`, we should get `256`, or the proper result where a byte value needed to overflow into a 2-byte value.


