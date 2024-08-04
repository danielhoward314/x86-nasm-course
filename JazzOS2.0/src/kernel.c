#include "vga.h"
#include "gdt.h"
#include "interrupts/idt.h"

void kmain(void); // example of forward declaration

void kmain(void) {
    reset();
    print("Hello world!\r\n");
    initGdt();
    print("GDT init finished\r\n");
    initIdt();
    print("IDT init finished\r\n");
}