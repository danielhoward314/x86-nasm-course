# Bootloader

When a computer is turned on and starts to receive power, the CPU relies on a bootloader to load software, either the operating system, a standalone utility, a storage dump program for diagnosing problems, or another bootloader in the case of multi-stage bootloading.

Bootloaders historically performed a multi-stage boot because of size and memory constraints. The first-stage bootloader had to fit within the first 446 bytes of the Master Boot Record and could only use 32 KiB of memory. Early bootloaders also had to limit the operations of the first-stage to ones supported by 8088/8086 processors, for backwards compatibility.

Where the bootloader is on a computer has changed over time. Early x86 computers stored the first stage of the bootloader at a hard-coded address in ROM, `000FFFF0h`, since the processor would be designed to start execution that address. In the late 80s and early 90s, computers started to store the bootloader on electrically erasable programmable read-only memory (EEPROM). EEPROM has the limitation that it must be entirely erased before it can be rewritten to. In the mid-to-late 90s, computers started storing the bootloader on flash memory, which can be rewritten to in sections. In the early 2000s, the UEFI standard was developed to address the limitations of legacy BIOS. In UEFI, the bootloader is firmware stored on flash memory on the mainboard.

The multi-stage concept is retained, albeit for different reasons: modularity, separation of concerns like hardware initialization, secure boot (ensure only signed and trusted bootloaders are executed) + TPM (perform system integrity checks for each boot component, attest to those values in a cryptographically signed report backed by an OEM platform key), boot manager (interface for users to configure the boot process), kernel loader, etc.

# BIOS (Basic Input Output System) and Unified Extensible Firmware Interface (UEFI)

The CPU begins executing instructions from its reset vector, a default memory address to start execution. Whether in ROM, EEPROM, or flash, this address points to nonvolatile memory where the BIOS/UEFI is stored.

The BIOS was the bootloader for x86 systems until UEFI gained adoption starting in the early 2000s.

1. The BIOS first does the Power-on self test (POST), which identifies, tests and initializes the CPU, chipset, RAM, motherboard, video card, keyboard, mouse, hard disk drive, optical disk drive, and other hardware such as integrated peripherals.
2. The BIOS discovers what boot devices are present in settings on its own dedicated memory.
3. The BIOS checks the first sector (boot sector) of each device and, optionally, checks for the signature `0x55 0xAA` in the last 2 bytes of the 512-byte long sector. If bootable, the BIOS transfers execution to the boot device. The order of these checks may be dictated by settings from the dedicated BIOS memory.
4. The bootloader must contain the Master Boot Record (MBR). This data is expected to begin at sector 0 of the boot device and contain:
- the bootstrap code itself
- partition table describing how the hard drive is partitioned
- boot signature (aforementioned final 2 byte sequence)
5. The bootstrap code is executed, which finds the kernel code and transfers execution to it.

# The Code

Since the teacher iterates on the same code over several videos, the annotations below map to each video by their title.

## Building a Simple Bootloader

### main.asm

Since bootloader will be loaded in memory at a hard-coded address `0x7C00`, we use the `ORG` directive to set the `IP` (instruction pointer) to this address.

The `BITS` directive is used since the BIOS expects us to be in 16-bit real-mode in the first stage.

The `TIMES 510 - ($-$$) DB 0` initializes the first 510 bytes of the program with zeros.

The `DW 0AA55h` is the signature in little-endian.

### Makefile

```
ASM=nasm

SRC_DIR=src
BUILD_DIR=build

$(BUILD_DIR)/main.img: $(BUILD_DIR)/main.bin
	cp $(BUILD_DIR)/main.bin $(BUILD_DIR)/main.img
	truncate -s 1440k $(BUILD_DIR)/main.img

$(BUILD_DIR)/main.bin: $(SRC_DIR)/main.asm
	$(ASM) $(SRC_DIR)/main.asm -f bin -o $(BUILD_DIR)/main.bin
```

This automates using `nasm` to assemble the program as a binary file, copying it to the build directory, and extending the `main.img` file to have as many bytes as is expected for a floppy disk.

Can be run with `make`.

### Running with qemu

```
qemu-system-i386 -fda build/main.img
```

Should pop up an emulator window with the program booting in the BIOS. The `-fda` flag specifies a floppy disk image that we expect the emulator to boot from.

## Printing a Message in BIOS

### main.asm

```
    MOV ax, 0
    MOV ds, ax
    MOV es, ax
    MOV ss, ax
    MOV sp, 0x7C00
```

Make sure registers are initialized to 0 and set up the stack pointer.

```
print:
    PUSH si
    PUSH ax
    PUSH bx

print_loop:
    LODSB ; load a single byte...no-operand form, assumes ds is source and al is destination
    OR al, al
    JZ done_print
    MOV ah, 0x0E
    MOV bh, 0
    INT 0x10
    JMP print_loop

done_print:
    POP bx
    POP ax
    POP si
    RET

os_boot_msg: DB 'Our OS has booted!', 0x0D, 0x0A, 0
```

The `print` label saves the values of the registers the rest of these labels will modify. The `print_loop` label assumes a caller of `print` has put the argument into `si`, which `main` did by loading the message into `si` before calling `print`; so `print_loop` uses `LODSB` to load from `si` into `al` the message to print one byte at a time in a loop. The `OR al, al` is a trick to get the zero flag `ZF` set in the case that `al` equals zero; this gets the null terminating character to act as the value that breaks us out of the loop.

## Disk Storage Structure in 6 Minutes

No code for this video. The info is on hard disk drives even though modern computers tend to use solid state drives. The HDD concepts can be applied by analogy to SSD.

The hard disk is a series of platters that are like CDs stacked on top of each other. They spin at a high RPM. Tracks are concentric rings on the platters and sectors are a given amount of width of one of these tracks. Data is read and written to these track-sectors by read-write heads. There is an actuator, or like a moving arm, that moves the read-write heads to the top or bottom of a given platter and at the right track-sector. A head then refers to whether it is the read-write head for the topside or underside of a given platter. Reading means transforming the magnetic polarity on the platter into an electrical charge; writing means transforming electrical charge into magnetic polarity. Conceptually, a cyclinder is the same track-sector across several layers of platters.

All of this is what is needed conceptually to understand how you address parts of a HDD with cylinder-head-sector (CHS). This is the older method of addressing HDD. A newer method, logical block addressing (LBA), is what allows you to use analogies for SSD. There are formulas for converting between the two addressing formats:

LBA = (C * TH * TS) + (H * TS) + (S -1)
C -> Sector cylinder number
TH -> Total headers on disk
TS -> Total sections on disk
H -> Sector head number
S -> Sector number

t = LBA/sectors per track
s = (LBA % sectors per track) + 1
h = (t % number of heads)
c = (t/number of headers)

## Creating a FAT12 Disk

Why do this? We separate responsibilities by loading the bootloader into memory so it can set up the initial state of the computer. Once finished with boot tasks, the bootloader loads the kernel code into memory so it can set up the operating system and start executing user space programs. Since a BIOS expects a bootable drive that has a bootloader that fits within 512 bytes of memory, we can only initially load a program that fits in that size. The bootloader and kernel cannot both fit in 512 bytes, so we need some kind of disk formatting to be able to load the bootloader and kernel separately.

[Design of the FAT file system](https://en.wikipedia.org/wiki/Design_of_the_FAT_file_system) is a good wiki describing the layout on disk of the different regions and sectors.

There are four regions: Reserved Sectors region, FAT region, Root Directory region, and the Data region. These are "logical", or abstract, divisions of the disk according to the conventions of the FAT file system. Each region has a conventional size and function. The reserved region has the BIOS Parameter Block and the bootloader code itself. The FAT region contains the file allocation tables which keep track of what clusters are used by directory and file entries. It marks cluster numbers with a hex number to indicate whether they are allocated or unallocated. The root directory region contains entries with the name of files or directories, their metadata, and the starting cluster number. The data region is the data itself.

### Modified directory structure

The `bootloader` and `kernel` directories are added to split out these responsibilities. Filepaths in the `Makefile` are updated to accommodate the new directory structure.

### Makefile floppy_image rule

- We make this rule depend on the `bootloader` and `kernel` rules.
- Initialize the `main.img` file with a block size of 512 and a count of 2880 blocks, all of to be filled with zeros.
- Build a file system in the FAT12 format for the given device (our floppy image that we will point to in the `qemu` invocation with `-fda`).
- Copy the bootloader to the file system. Since the bootloader is only 512 bytes and the floppy disk was initialized to 2880 blocks of 512 bytes-per-block, we need the `notrunc` option to tell `dd` not to truncate the floppy down to just the space taken up by the bootloader's 512 bytes.
- We need to use `mcopy` to copy, without overwriting, the kernel code to the floppy.

### Running make at this point

Running make at this point yields the following error:

```
Cannot initialize '::'
Bad target ::kernel.bin
make: *** [Makefile:13: build/main.img] Error 1
```

### Header section

The fields needed are collectively the [BIOS Parameter Block (BPB)](https://en.wikipedia.org/wiki/BIOS_parameter_block). Remember that the `ORG 0x7C00` directive tells the assembler to assemble the code as if it starts at that address even though physically it starts at the first sector of the floppy disk image. According to the FAT12 specification, the BPB must occur at a fixed offset from this `0x7C00` address; this offset is 3 bytes which is how much space is taken up by the `JMP` and `NOP` (no-op) instructions. The directives at the top of the `boot.asm` file do not end up in the text section of the final binary executable, hence how we have only these 3 bytes at the start of the text section. After the following code is added, we can run `make` without errors and see that it writes the 512 bytes to the `build/main.img`. If we open the `build/main.img` in a hex editor, we see the first 3 hex values are `EB 3C 90`. This is the opcode for `JMP SHORT` (EB), the `main` label which is the operand for it `3C`, and the opcode for the `NOP` (90). The operand for `JMP SHORT main` that translates to `3C` (or 60 in decimal) is a relative jump; in a hex editor you can count 60 hex values from whatever immediately follows `3C` and get to the hex values we'd expect to see for the first line of the `main` label, which is `MOV ax, 0` or `B8 00 00`. 

After the `EB 3C 90` for the only instructions at the start of the text section, the very next hex values start the BPB, beginning with the ASCII encodings for `MSWIN4.1`: `4D 53 57 49 4E 34 2E 31`. The BPB values occupy the 60 values between the `3C` and the `B8 00 00`.
.
```
JMP SHORT main
NOP

bdb_oem: DB 'MSWIN4.1'
bdb_bytes_per_sector: DW 512
bdb_sectors_per_cluster: DB 1
bdb_reserved_sectors: DW 1
bdb_fat_count: DB 2
bdb_dir_entries_count: DW 0E0h
bdb_total_sectors: DW 2880
bdb_media_descriptor_type: DB 0F0h
bdb_sectors_per_fat: DW 9
bdb_sectors_per_track: DW 18
bdb_heads: DW 2
bdb_hidden_sectors: DD 0
bdb_large_sector_count: DD 0

ebr_drive_number: DB 0
                  DB 0
ebr_signature: DB 29h
ebr_volume_id: DB 12h,34h,56h,78h
ebr_volume_label: DB '12345678901'
ebr_system_id: DB '12345678'
```

## Reading from the Disk in BIOS

[This interrupt](https://stanislavs.org/helppc/int_13-2.html) is needed. It requires CHS format. Olivestem uses LBA as the starting point since it is easier to conceptualize, then converts it to the CHS format required by the interrupt.

To test, generate the floppy image and then use a hex editor to modify some data into an easily identifiable pattern. Run the emulator in debug mode, which will wait until you've connected with the debugger before starting up the graphical BIOS. Start the debugger in remote mode (using qemu's port) and step through to where the code loads into memory the floppy data.

It was helpful to rerun `make` and open `build/main.img` in a hex editor. Change the values that occur right after `55 AA` (in hex editor, aka `DW 0AA55h` in the code because values are little-endian) to make it more obvious what was read from the FAT12 file system. Debug it to check that opening files works. Use gdb with the qemu debugger port:
```
qemu-system-i386 -boot c -m 256 -hda build/main.img -s -S
gdb
target remote localhost:1234
layout asm
br *0x7c00
continue
stepi # until right before the INT 13h
br *<addr-after-interrupt>
continue
info registers ebx # i.e. the disk read buffer given by BIOS 13.2 interrupt
x/5x <addr-at-ebx> 
```

## Loading The Kernel File from Disk

[Design of the FAT file system](https://en.wikipedia.org/wiki/Design_of_the_FAT_file_system) is a good wiki describing the layout on disk of the different regions and sectors.

File names can be 11 characters max and must follow the [8.3 format](https://en.wikipedia.org/wiki/8.3_filename), hence the variable `file_kernel_bin DB 'KERNEL  BIN'`.

This video covers a few things:

1. How to calculate where the root directory region begins on disk within the FAT file system.

```
    MOV ax, [bdb_sectors_per_fat]
    MOV bl, [bdb_fat_count]
    XOR bh, bh
    MUL bx
    ADD ax, [bdb_reserved_sectors]
    PUSH ax
```

It helps to look side-by-side at the wiki article and this calculation, which gets the logical block address (LBA) of the root directory. An imperfect analogy, it's like the reserved sectors and the FAT region are the first two songs on a vinyl record; this calculation is like figuring out far in on the record you need to put the needle to land on the "Root Directory" song.

2. How to calculate the size of the root directory.

```
    MOV ax, [bdb_dir_entries_count]
    SHL ax, 5 ; ax *= 32
    XOR dx, dx
    DIV word [bdb_bytes_per_sector]

    TEST dx, dx
    JZ rootDirAfter
    INC dx

rootDirAfter:
    MOV cl, al
    POP ax
    MOV dl, [ebr_drive_number]
    CALL disk_read
    XOR bx, bx
    MOV di, buffer
```

Step 1 got us to the sector-offset-from-zero of where the root directory starts. We need to calculate its size so that in a future step we can iterate through it to check for an entry for the kernel file.

The calculation multiples the number of root directory entries by the size of each entry (multiplication done via a shift left, but it's equivalent). It is then divided by the bytes per sector. Why divide? Let's assume we have 224 directory entries. The multiplication makes sense: each entry is 32 bytes, so we must multiply the number of entries by the number of bytes. The division is needed because the disk is physically organized in sectors, hence we need to address it with sectors. We divide by the bytes per sector to get a sector-based offset from the start of the root directory region.

The `TEST` instruction is used to check whether the division had a remainder. We need to round up in case there was a remainder.

3. Iterate over the root directory to find the kernel file.

```
searchKernel:
    MOV si, file_kernel_bin ; 11-char long file name
    MOV cx, 11 ; size of file as value
    PUSH di ; buffer
    REPE CMPSB ; keep comparing single byte of di and si until non-match found or end of register value
    POP di
    JE foundKernel

    ; didn't find kernel, go to next directory
    ADD di, 32
    INC bx
    CMP bx, [bdb_dir_entries_count]
    JL searchKernel
    JMP kernelNotFound

kernelNotFound:
    MOV si, msg_kernel_not_found
    CALL print
    HLT
    JMP halt
```

This code iterates over root directory entries, searching for a match on the kernel file.

4. Load the file allocation table and initialize the memory chunk for the kernel.

```
foundKernel:
    MOV ax, [di + 26]
    MOV [kernel_cluster], ax
    MOV ax, [bdb_reserved_sectors]
    MOV bx, buffer
    MOV cl, [bdb_sectors_per_fat]
    MOV dl, [ebr_drive_number]
    CALL disk_read

    MOV bx, kernel_load_segment
    MOV es, bx
    MOV bx, kernel_load_offset
```

The first chunk reads the FAT from disk. The second chunk initializes variables for the memory addresses (start, end) where we'll load the kernel.

5. Load the kernel file into memory.

```
loadKernel:
    MOV ax, [kernel_cluster]
    ADD ax, 31
    MOV cl, 1
    MOV dl, [ebr_drive_number]
    CALL disk_read
    ADD bx, [bdb_bytes_per_sector]
    MOV ax, [kernel_cluster]
    MOV cx, 3
    MUL cx
    MOV cx, 2
    DIV cx
    MOV si, buffer
    ADD si, ax
    MOV ax, [ds:si]
    OR dx, dx
    JZ even

odd:
    SHR ax, 4
    JMP nextClusterAfter

even:
    AND ax, 0x0FFF

nextClusterAfter:
    CMP ax, 0xFF8
    JAE readFinish ; jump is above or equal
    MOV [kernel_cluster], ax
    JMP loadKernel

readFinish:
    MOV dl, [ebr_drive_number]
    MOV ax, kernel_load_segment
    MOV ds, ax
    MOV es, ax
    JMP kernel_load_segment:kernel_load_offset
    HLT
```

## Implementing Puts with C and x86

The kernel code starts executing in 16-bit real mode. In order to run C code, we need a 16-bit compiler. [open-watcom-v2](https://github.com/open-watcom/open-watcom-v2) has a 16-bit compiler. The installer is fiddly, you need to tab through things (especially the license agreement). I had to download an x64 release from the repo, run `chmod +x` on the download, and run it with `sudo`.

You need the full installation to get the `wcc` tool in `/usr/bin/watcom/binl`.

watcom also comes with a linker that we can use for 16-bit files.

The `Makefile` adds changes for compiling and linking the C code. It also changes the `-f` flag for nasm to target object file format.

A linker file is used for setting up the stack memory, the layout of different sections, and configuring the entrypoint.

So we compile the assembly and C code into object files, then link those object files together to produce a single binary. The main assembly file points to an external symbol (a C function), the linker knows that the entrypoint of the application is a certain text section label in that assembly file, and that label calls the main C function. The main C function itself has dependencies that C files that reference an underlying assembly implementation. The same idea applies: the assembly implementation is exposed to a header file via the `global` directive, a header file exposes that global to the C code. We assemble/compile to object files and link all the dependencies. The code execution becomes: bootloader loads the entrypoint of `main.asm`, which calls the `entry_` function in the `main.c` file.

## Implementing a basic printf function

This video covers the logic of how to process a format string one character at a time to mimic the behavior of the C standard library `printf` function.

The function takes a format string and a variadic list of values to be substituted in place of formatting directives like `%s`. Remember the C calling convention and how stack variables are set up for arguments passed to C functions? Here it is in practice. The calling code will have pushed onto the stack the arguments in inverted order, last argument first and so on until the first argument last. Because we can assume the caller of `printf` followed the C calling convention, we know the offset from the stack pointer where we can find the format string's pointer, i.e. `const char* fmt`. We can also assume locality of the rest of arguments. If the stack pointer offset for `fmt` is +4, then the offset for the second argument would be +8, and so on (assuming 32-bit system).

Given all of this, `argp` is initialized to the same pointer as `fmt` and then it is incremented `argp++`. Why not `argp += 4`? Because C knows the type is pointer, C uses the correct pointer size when incrementing.

The main while loop then iterates over the format string, printing characters, detecting `%` and setting the state for processing formatting directives, processing directives by getting the next `argp` value for it.

## Implementing disk resets

This video covers a refactor. Instead of doing disk reads in assembly, this video refactors the code to do it in C. I skipped this.