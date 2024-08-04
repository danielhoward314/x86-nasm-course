# Assembly -> C interop

- The `extern` is used to tell `nasm` that we will have external symbols that we will link in.
- The global entrypoint needs to be what the C toolchain expects it to be, which is `main`.

We have to push data onto the stack if we want to call C function. The stack is a LIFO data structure so we should push arguments onto the stack in the opposite order in which they are passed into the C function. For example, the function signature of printf is `printf(fmtS, fmtVal)`, so we push `fmtVal` first and then `fmtS`.


# Assemble and link

```
nasm -f elf c_iop.s -o c_iop.o
gcc -no-pie -m32 c_iop.o -o c_iop
```

The `-no-pie` flag tells gcc to not generate a position-independent executable. The `-m32` tells gcc we want a 32-bit executable.