# Assemble, link, debug

```
nasm -f elf -o lseek.o lseek.s

ld -m elf_i386 -o lseek lseek.o

gdb
layout asm
break _start
run
```

# lseek syscall

Previously, we used the `open` and `read` syscalls to get a file descriptor and read some bytes from the start of the file. With `lseek`, we can change where the open file descriptor is pointing within the file, i.e. start reading from some offset either from the start or end of the file. If we were to use it in a loop to read a file some amount of bytes at a time, we can also seek to some offset from the current position, kind of like a cursor. What was not intuitive to me is that `lseek` modifies the file descriptor and then you use another syscall to act on the modified file descriptor; I expected it to return a memory address pointing to the location within the file.

We can step through the program to the point after the `read` call and see that the offset argument passed to `lseek` causes us to skip the first 10 bytes (line 1 of the `test.txt` file) and read the second line:

```
info register ecx
x/10s <address>
```
