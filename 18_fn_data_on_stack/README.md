# Assemble, link, debug

```
nasm -f elf -o fds.o fds.s

ld -m elf_i386 -o fds fds.o

gdb
layout asm
break _start
run
```

# Change from previous video

In the code from the previous video, we used registers to hold the arguments passed into the `addTwo` procedure:

```
    MOV eax, 4
    MOV ebx, 1
    CALL addTwo
```

We do not always have this luxury, and so it is common to instead utilize the stack for passing arguments into procedures.

# Stack frames

Before the `PUSH` instructions, the values of `ebp` and `esp` don't seem to point to anything valuable. After pushing the value 4:

```
stepi ; corresponds to stepping past the PUSH 4 line
info register esp ; prints an address 0xffffd1cc
x/x 0xffffd1cc ; prints the immediate value of 0x00000004
stepi ; corresponds to stepping past the PUSH 1 line
info register esp ; prints an address that is -4 from last esp, so 0xffffd1c8
x/x 0xffffd1c8 ; prints the immediate value of 0x00000001
stepi ; corresponds to stepping past the CALL addTwo line
info register esp ; prints an address that is -4 from last esp, so 0xffffd1c4
x/x 0xffffd1c4 ; prints return address (i.e. JMP end line)
info register ebp ; prints 0x0
stepi ; corresponds to stepping past the PUSH ebp line
info register esp ; prints an address that is -4 from last esp, so 0xffffd1c0
x/x 0xffffd1c0 ; prints 0x00000000 (old ebp)
stepi ; corresponds to stepping past the MOV ebp, esp line
info register ebp ; prints 0xffffd1c0
x/x 0xffffd1c0 ; print 0x00000000 (old ebp)
info register esp ; prints 0xffffd1c0
stepi ; corresponds to stepping past the MOV eax, [ebp+8] line
info register eax ; prints 1
stepi ; corresponds to stepping past the MOV ebx, [ebp+12] line
info register ebx ; prints 4
stepi ; corresponds to stepping past the ADD eax, ebx line
info register eax ; prints 5
; remember that esp and epb hold value 0xffffd1c0, which is an address pointing to old ebp which is 0x00000000
stepi ; corresponds to stepping past the POP ebp line
info register esp ; prints 0xffffd1c4
x/x ; prints return address (i.e. JMP end line)
stepi ; corresponds to stepping past the RET line
; execution resumes at the JMP end line
info register esp ; prints 0xffffd1c8
```