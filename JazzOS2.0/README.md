# JazzOS2.0

The videos start a new project for the second iteration of JazzOS that will use Grub for bootloading.

The rest of the sections correspond to titles of videos in the playlist.

## Booting with Grub

The `boot.s` file is simple. It has a directive for saying we'll be in 32-bit mode. The text section initializes the alignment to 4 bytes, sets up a magic number signature that Grub expects for a multiboot 1 compliant bootloader, sets up the external symbol reference to the main function of the `kernel.c` file, sets up the global entrypoint that the linker will reference.

The `linker.ld` file configures the format of the executable, the entrypoint, and the sections.

The `grub.cfg` file is used to configure Grub to do a multiboot with our build of `boot.s` + `kernel.c`.

### Compiling, linking & running

```shell
gcc -m32 -fno-stack-protector -fno-builtin -c kernel.c -o kernel.o
nasm -f elf32 boot.s -o boot.o
ld -m elf_i386 -T linker.ld -o kernel boot.o kernel.o
mv kernel Jazz/boot/kernel
sudo apt update
sudo apt install grub-common
sudo apt install xorriso
grub-mkrescue -o Jazz.iso Jazz/
qemu-system-i386 Jazz.iso
```

## Writing to video memory

The main changes for this video are in `vga.c`. The video doesn't give the background needed to understand the code changes: [wiki for Visual graphics array (VGA)](https://en.wikipedia.org/wiki/Video_Graphics_Array).

"The video memory of the VGA is mapped to the PC's memory via a window in the range between segments 0xA0000 and 0xBFFFF in the PC's real mode address space (A000:0000 and B000:FFFF in segment:offset notation). Typically, these starting segments are:

    0xA0000 for EGA/VGA graphics modes (64 KB)
    0xB0000 for monochrome text mode (32 KB)
    0xB8000 for color text mode and CGA-compatible graphics modes (32 KB)
"

The `vga` variable is initialized as a pointer to this last address. It is an unsigned short pointer, so it will be populated with 16-bit unsigned numbers. VGA has a convention for the meaning of the upper and lower bytes, with further subdivision of the upper byte into a lower and upper nibble:

lower 8 bits -> ASCII code for characters to be printed
upper 8 bits -> color attributes
    lower nibble -> foreground color
    upper nibble -> background color

This line sets up the color attributes in the upper 8 bits and zeroes out the lower 8 bits.

```C
const uint16_t defaultColor = (COLOR8_BLACK << 8) | (COLOR8_LIGHT_GREY << 12);
```

0000-0000 SHIFT LEFT 8 =       0000-0000-0000
0000-0111 SHIFT LEFT 12 = 0111-0000-0000-0000

     0000-0000-0000
0111-0000-0000-0000
-------OR----------
0111-0000-0000-0000


This gives us the colors in the upper 8 bits. Anytime we need to print something, we can a bitwise OR with an ASCII code and the value above. Since all of the ASCII codes fit in 8 bits, any of these bitwise ORs with the default color value will just populate the lower bits.

A 2-d array is used to represent rows/height/y-coordinate and columns/width/x-coordinate.

The `scrollUp` helper function iterates through the rows and sets their contents to whatever is in the row below them, ostensibly hoisting up every row to give the appearance of upward scrolling.

The `newLine` helper function does a bounds check of the height. For most cases, it increments the line and sets the column to 0. For the case where the line is the last line within the bounds of the height, it scrolls up and sets the column to 0.

The `print` helper function is what the `kernel.c` code calls to paint to the screen after booting up via Grub. It does a switch statement on the character, handling the special cases for newlines, carriage returns, and tabs. For everything else, it does a width bounds check, starting a new line if at the edge, and then does a bitwise OR with the character and the color.

I created the `Makefile` which has `make` and a `make clean`.

## Implementing a GDT

The [Global Descriptor Table](https://en.wikipedia.org/wiki/Global_Descriptor_Table) is memory layout structure used in x86. Even in 64-bit systems, the GDT is still used during boot when transitioning from real mode to protected mode.

The boot process should set the expected address for the GDT using a special register. From that starting address, GDT entries are stored contiguously according to a 64-bit structure.

0-15 Limit partial (15:0)
16-31 Base partial (15:0) // 16 bit
32-39 Base partial (23:16) // 32 bit
40-47 Access Byte
48-51 Limit partial (19:16)
52-55 Flags
56-63 Base partial (31:24) // 64 bit

The separation of the base address into different parts in the GDT entry is primarily the result of the evolution of the x86 architecture from 16-bit to 32-bit to 64-bit. The base address tells you where a memory segment starts and then the limit tells you the maximum possible memory area it may take up. You can calculate the start (base, as is) and the end (limit, either as is or multiplied by 4096 if using pages) to know the start and end addresses of the code/data the GDT entry is describing. The data in this segment may or may not utilize the full extent of this memory area.

The access byte uses each of its 8 bits to denote different things. 0 for whether the segment is present in memory. 1 for privilege level using the ring model where 0 is highest and 3 is lowest. 2 is segment type, code or data. 3 is a boolean for whether it is executable. 4 has different meanings for code and data; for code it indicates whether the segment is conforming; for data it indicates the direction of growth. 5 is RW permissions; for code it is a bool for readable/non-readable; for data it is a bool for writeable. 6 is whether it is being read or executed. 7 is to mark it as available or unavailable.

Flags are, well, flags, the most important of which seem to be for indicating the size of segments, 16, 32, or 64 bit. Also, there's a flag for setting the limit in terms of bytes or pages.

The code in `gdt.s` also involves some background the video doesn't explain well. You need to use segment selectors to get an entry from the GDT. They have an expected binary format.

0x00 is the null segment (think, it takes up indexes 0-7)
0x08 is the kernel code segment (think, it takes up indexes 8-15)
0x10 is the kernel data segment (think, this is hex for 16, so index 16)
0x18 is the user code segment (think, this is hex for 24, so index 24)
0x20 is the user data segment (think, this is hex for 32, so index 32)

## Debugging with GDB and QEMU

Update the gcc compile commands in the `Makefile` to use the debug flag `-g`. Rerun `make`.

Run qemu with flags:

```
qemu-system-i386 -s -S Jazz.iso
```

Another terminal tab, make gdb debug the kernel binary and set it to point to a remote target.

```
gdb Jazz/boot/kernel
target remote localhost:1234 # or just :1234
l # shows C code of `kmain`
break initGdt
continue

# go to qemu window and select Jazz as the OS
# which will trigger the kernel to be loaded
# and will cause execution to hit the breakpoint
layout asm
```

## Task State Segment

[Wiki](https://en.wikipedia.org/wiki/Task_state_segment). The TSS is used for storing the state of tasks to facilitate context switching, either between hardware or software tasks.

The video covers:

1. Defining the struct for a TSS entry. It has all the registers afforded by x86. Done in `/src/gdt.h`.
2. Defining the function signature for `writeTSS` in `/src/gdt.h`.
3. Invoking the `writeTSS` function in the `initGdt` function in `/src/gdt.c`. The TSS is another segment added to the end of what we had so far in the GDT.
4. Implementing `writeTSS`. Does the work of adding the TSS segment to the GDT. Then initializes with 0s the struct member fields on the TSS entry struct (done via a helper method, see point 5). Sets member fields for specific registers to point to the kernel code segment or kernel data, both with privilege 3.
5. Adding `util.h` and `util.c` with a helper method, `memset` to initialize struct member fields to 0.
6. Extending the `Makefile` with the util files.

What are the specific registers and why are they set this way?

- ss0 (Stack Segment for Ring 0):
  - `ss0` is set to `0x10` which is the segment descriptor in the GDT that describes the kernel data segment.
- esp0 (Stack Pointer for Ring 0):
  - `esp0` is set to `0x00`, which is the stack pointer the CPU uses when switching to kernel mode. Setting it this way indicates it's a placeholder and the actual stack pointer will be set later.
- cs (Code Segment):
  - `cs` is set to `0x08`, which is the kernel code segment.
- ss, ds, es, fs, gs:
  - Points all these registers to the kernel data segment.

This is done so that the kernel has a stack associated with it, and the privilege level is set to 3 so that user mode code runs with restricted privileges.

## Interrupts

[Wikipedia](https://en.wikipedia.org/wiki/Interrupt_descriptor_table) and the [OSDev Wiki](https://wiki.osdev.org/Interrupt_Descriptor_Table).

Hardware or software can trigger interrupts, requesting the CPU to interrupt its current execution task and run the interrupt routine for this kind of request. This video demonstrates firing an interrupt request for errors.

The video covers setting up the IDT in a way similar to the GDT or TSS. After initializing a part of the data structure, the video arrives at the more substantial bit, which is setting things up for two [Programmable Interrupt Controllers (PIC)](https://en.wikipedia.org/wiki/Programmable_interrupt_controller).

Send initialization command to primary and secondary PIC:

```
    outPortB(0x20, 0x11);
    outPortB(0xA0, 0x11);
```

Send vector offsets data to primary and secondary PIC:

```
    outPortB(0x21, 0x20); // primary PIC vector offsets 0x20-0x27
    outPortB(0xA1, 0x28); // secondary PIC vector offsets 0x28-0x2F
```

Send primary PIC a signal that there's a secondary, then configure the secondary to the second cascade priority. Interrupt request lines (IRQs) are zero-indexed while the cascade configuration is 1-based. So 0x02 is the second cascade line to match with IRQ1, the second interrupt request line.

```
    outPortB(0x21, 0x04);
    outPortB(0xA1, 0x02);
```

Set operation mode to 8086/8088 mode for backwards compatibility:

```
    outPortB(0x21, 0x01);
    outPortB(0xA1, 0x01);
```

Enable interrupts, allowing primary and secondary to process IRQs:

```
    outPortB(0x21, 0x0);
    outPortB(0xA1, 0x0);
```

The `idt.c` code registers all of the interrupt service routines (ISRs) and interrupt requests (IRQs) in the IDT. We have a table that allows devices or software to make an interrupt request and then look up the interrupt service routine that is meant to handle those requests.

The video covers how to use assembly macros to generate common stubs for all of the ISRs:

```
%macro ISR_NOERRCODE 1
    global isr%1
    isr%1:
        CLI
        PUSH LONG 0
        PUSH LONG %1
        JMP isr_common_stub
%endmacro

%macro ISR_ERRCODE 1
    global isr%1
    isr%1:
        CLI
        PUSH LONG %1
        JMP isr_common_stub
%endmacro
```

The macro has a name and then a number of arguments `%macro <name> <#-of-args>`. The arguments start at 1 and increment from there. These arguments can then be referenced in the template by `%n` where `n` is its argument number. Those template directives will be replaced with the value for that argument number. This generates all of the stubs for the external symbols declared in `idt.h`. The first form handles the fact that some ISRs don't have an error code, whereas the second form expects error codes.

The label for `isr_common_stub` does all of the common stack register setup, then calls an external symbol that is defined in C code, `isr_handler`, and then does the return callee clean up. The ISR handler does a lookup in an array where the ISR number is the index into the array to get a string for the exception. All of these ISRs are for exceptions, which is likely for pedagogical purposes to keep ISRs to a limited scope. In actual CPU architectures, ISRs have many other functions.

Another macro is used for the IRQs:

```
%macro IRQ 2
    global irq%1
    irq%1:
        CLI
        PUSH LONG 0
        PUSH LONG %2
        JMP irq_common_stub
%endmacro
```

## Setting up a Cross Compiler

Since we're on a 64-bit Linux machine (or VM in my case) and we're compiling for a target of 32-bit, we may get errors with things like division or strings even though we're providing flags signaling our 32-bit target. This video covers setting up a cross compiler to ensure correct compilation for a 32-bit target.

```shell
sudo apt-get install bison
sudo apt-get install flex
sudo apt-get install libgmp3-dev
sudo apt-get install libmpc-dev
sudo apt-get install libmpfr-dev
sudo apt-get install texinfo # video has incorrect package name `textinfo`
```

Env vars for it:

```shell
export PREFIX="/usr/opt/cross" # video has `usr/opt/cross`, which binutils doesn't like
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"
```

You need to clone `gcc` and `binutils`:

```shell
git clone git://sourceware.org/git/binutils-gdb.git
git clone git://gcc.gnu.org/git/gcc.git
```

Then build these, assuming clone repo names are `gcc` and `binutils-gdb`:

```shell
mkdir build-binutils
cd build-binutils
../binutils-gdb/configure --target="${TARGET}" --prefix="${PREFIX}" --with-sysroot --disable-nls --disable-werror # video does not properly wrap the env var references
make
make install
```

This runs the configure script that sets up the build environment for compiling the binutils and GDB tools. The target is the target platform for the tools being built; the prefix is binary folder path prefix for adding it to the path; the sysroot option says the tools should be built wiht support for a directory that's a minimal filesystem hierarchy used as the root directory, which will separate it from the native system's root directory; the nls option is to disable native language support (options for internationalization / localization); the werror option disables treating compiler warnings as errors.

```shell
mkdir build-gcc
cd build-gcc
../gcc/configure --target="${TARGET}" --prefix="${PREFIX}" --disable-nls --enable-languages=c,c++ --without-headers
make all-gcc
make all-target-libgcc
make install-gcc
make install-target-libgcc
```

Test the binary:

```shell
/usr/opt/cross/bin/i686-elf-gcc --version
```

The result is that `/usr/opt/cross/bin/i686-elf-gcc` has a custom configuration of the `gcc` binary.

The `Makefile` is updated to point to this custom gcc for compilation. The flags changes as well.

From:

```Makefile
-m32 -fno-stack-protector -fno-builtin
```

To:

```Makefile
-ffreestanding -Wall -Wextra -g -O2
```

The linker file also requires changes.

From:

```
OUTPUT_FORMAT(elf32-i386)
ENTRY(start)
SECTIONS
{
    . = 0x100000;
    .text : {*(.text)}
    .data : {*(.data)}
    .bss : {*(.bss)}
}
```

To:

```
ENTRY(start)
SECTIONS
{
    .text 0x100000 :
    {
        code = .; _code = .; __code = .;
        *(.text)
        . = ALIGN(4096);
    }

    .data :
    {
        data = .; _data = .; __data = .;
        *(.data)
        *(.rodata)
        . = ALIGN(4096);
    }

    .bss :
    {
        bss = .; _bss = .; __bss = .;
        *(.bss)
        . = ALIGN(4096)
    }

    end = .; _end = .; __end = .;
}
```