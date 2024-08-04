# Assemble, link, debug

```
nasm -f elf -o csl.o csl.s

ld -m elf_i386 -o csl csl.o

gdb
layout asm
break _start
run
```

# ASCII

A single ASCII character can be represented with a byte. A string then can be represented using a list of chars. However, we must have some way of knowing when the list ends, which is usually achieved with a null terminating byte, i.e. a `0` at the end.

If we debug the program, we can see ASCII encoding in action. We can also see how a list of characters is represented as a contiguous block of memory, hence the need for a null-terminating character to indicate the end of the block.

```
p &mychar
x/b 0x804a000
stepi
info registers bl
```

Above shows how to get the address of the `mychar` variable, print out the byte at that memory address, and printing out the value of the `bl` register after this value has been moved into that register. The value print in both instances should be `65`, which is the ASCII encoding of 'A'.

```
p &list
x/4 0x804a001
```

Above shows how to get the memory address of the `list` variable and print out 4-bytes of data starting from that address. The output should be `65 66 65 0`, which is the ASCII encoding of the values we put into the list "ABA" followed by the null-terminating character.