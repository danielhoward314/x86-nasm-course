# Assemble, link, debug

```
nasm -f elf -o cj.o cj.s

ld -m elf_i386 -o cj cj.o

gdb
layout asm
break _start
run
```

# Comparison instruction

The example `CMP eax, ebx` works out to `operand1 - operand2 = result` where the result is used to set a flag that signals whether the result was positive (operand1 > operand2), negative (operand1 < operand2) or 0 (operand1 = operand2). After being used to set a flag, the result is discarded.

If we change the value of `eax` to test out each of these scenarios and check the `eflags` register after the compare occurs in each case, we get the following results:

```
eflags when eax is greater
[ IF ]

eflags when eax is lesser
[ CF PF AF SF IF ]

eflags when eax equals ebx
[ PF ZF IF ]
```

# Jump instructions

A jump instruction can jump the program to the label specified in the operand, and it can do these jumps unconditionally (`JMP`) or conditionally (e.g. `JL`) based off a previous comparision instruction.

Control flow in assembly does not work as in higher-level languages. When we want to conditionally jump to some label, i.e. the analogue to an `if` branch, for cases in which we do not meet the test condition, the code will not skip over this label unless we tell it to. Code executes sequentially top-to-bottom unless you tell it to do otherwise.

Other jump instructions: `JE` (jump equals), `JNE` (jump not equal), `JG` (greater than), `JGE` (jump greater than or equal), `JGL` (lesser than), `JLE` (jump lesser than or equal), `JZ` (subtraction resulted in 0).
