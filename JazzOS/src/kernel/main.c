#include "stdint.h"
#include "stdio/stdio.h"

void _cdecl cstart_() {
    puts("Hello from C!\n");
    printf("Formatted: %% %c %s\r\n", 'f', "Hello");
    printf("%d %i %x %p %ld", 11, -9, 0xffa, 0x1d, -1000000000000l);
}
