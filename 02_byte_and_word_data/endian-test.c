#include <stdio.h>

int main() {
    // set 1 to a data type we know is 4-byte sized
    // so should either be:
    // [0x01] [0x00] [0x00] [0x00] little endian
    // [0x00] [0x00] [0x00] [0x01] big endian
    // where memory addresses increase from left to right
    unsigned int x = 1;

    // get the value at the address where variable x's data is stored
    // cast that 4-byte data into a type that is 1 byte
    // which means we only grab the first byte of data
    // and this byte is the lowest memory address (or leftmost byte as shown above)
    char *c = (char*)&x;

    // we can treat the byte of data as a 1 or 0 in a conditional
    // where each case tells us whether the lowest memory address
    // was a 1 or a 0 
    if (*c) {
        printf("little endian\n");
    } else {
        printf("big endian\n");
    }
}