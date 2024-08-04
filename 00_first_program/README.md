# What program does and why

The `global` directive tells the assembler to mark the symbol that follows it, usually a label, as globally accessible entry points for the program.

Working backwards from `INT 80h`, we know that this instruction causes a software interrupt. The 80 is an index, or offset from start address, of the interrupt vector table which is set to a fixed address by the CPU architecture. So IVT start address + 80 points to the address of an interrupt handler, which the kernel will have loaded into RAM on startup of the OS. This handler is the system call handler. This handler expects an argument in `eax`, which points to an index in a system call handler table. The index 1 points to the `exit` syscall, which expects an argument in `ebx` indicating the exit code for the exit. The 2 `MOV` instructions set up this software interrupt.

# Assemble, link, debug

```
nasm -f elf -o first.o first.s

ld -m elf_i386 -o first first.o

gdb
layout asm
break _start
run
```

We run the assembly source code through the assembler to get an object file:

```
nasm -f elf -o first.o first.s
```

We can use the `nm` command line utility to inspect the generated object file:

```
nm -g first.o
```

The `-g` flag is used to print only the external symbols.

We can run the object file through `ld`, the GNU linker:

```
ld -m elf_i386 -o first first.o
```

The `-m` flag sets the emulation linker, since the target architecture may not be the same as the actual machine (or virtual machine) the linker is run from.

We can run the generated 32-bit ELF executable and check the exit code:

```
./first
echo $? # should print value moved into register ebx
```

The `MOV eax, 1` is meant to move into 

We can debug the executable:

```
gdb
layout asm
break _start
run
```

Above is the basic setup for debugging, invoke the debugger, use the assembly layout, set a breakpoint that corresponds to a label in the `.text` section and run the program. The video series uses this technique throughout and shows more techniques for inspecting the values at registers, at memory addresses, etc.

In this video, we do the following:

```
stepi
info registers eax
```

- `stepi` increment the program by one step
- `info registers eax` prints the value of register eax

The gdb debugger disassembles the program in order to display the code and in doing so makes assumptions about the syntax for the assembly. The default is to display code with the AT&T syntax. In order to override this default, we can run the following:

```
echo "set disassembly-flavor intel" > ~/.gdbinit
```