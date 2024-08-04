# Assemble and link

Similar to video 15, we can push C fn arguments onto the stack in the order of last to first as they appear in the function signature. Unlike `printf`, this custom C function returns an `int` value, which will be in the `eax` register after calling it, hence the `PUSH eax` in order to take the result of the custom C function and use it as the exit code in the call to `exit`.

The only difference when using a custom C function is that we have to include it in the `gcc` command since gcc doesn't already know from where to link the custom C fn, `my`--as it does with standard library C functions that we point to with `#include`.

```
nasm -f elf my_c.s -o my_c.o
gcc -no-pie -m32 my_c.o my.c -o my_c
```