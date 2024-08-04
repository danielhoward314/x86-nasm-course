#include "gdt.h"
#include "util.h"

extern void gdt_flush(uint32_t);

struct gdt_entry gdt_entries[6];
struct gdt_ptr gdt_ptr;
struct tss_entry tss_entry;

void initGdt() {
    gdt_ptr.limit = (sizeof(struct gdt_entry) * 6) - 1;
    gdt_ptr.base = (uint32_t)&gdt_entries;
    setGdtGate(0,0,0,0,0); // NULL segment required
    setGdtGate(1, 0, 0xFFFFFFFF, 0x9A, 0xCF); // kernel code segment
    setGdtGate(2, 0, 0xFFFFFFFF, 0x92, 0xCF); // kernel data segment
    setGdtGate(3, 0, 0xFFFFFFFF, 0xFA, 0xCF); // user code segment
    setGdtGate(4, 0, 0xFFFFFFFF, 0xF2, 0xCF); // user data segment
    writeTSS(5, 0x10, 0x0);
    gdt_flush((uint32_t)&gdt_ptr);
    tss_flush();
}

void setGdtGate(uint32_t index, uint32_t base, uint32_t limit, uint8_t access, uint8_t gran) {
    gdt_entries[index].base_low = (base & 0xFFFF); // bitmask to get lower set of bits
    gdt_entries[index].base_middle = (base >> 16) & 0xFF;
    gdt_entries[index].base_high = (base >> 24) & 0xFF;
    gdt_entries[index].limit = (limit & 0xFFFF);
    gdt_entries[index].flags = (limit >> 16) & 0x0F;
    gdt_entries[index].flags |= (gran & 0xF0);
    gdt_entries[index].access = access;
}

void writeTSS(uint32_t index, uint16_t ss0, uint32_t esp0) {
    uint32_t base = (uint32_t) &tss_entry;
    uint32_t limit = base + sizeof(tss_entry);
    setGdtGate(index, base, limit, 0xE9, 0x00);
    memset(&tss_entry, 0, sizeof(tss_entry));
    tss_entry.ss0 = ss0;
    tss_entry.esp0 = esp0;
    tss_entry.cs = 0x08 | 0x3; // kernel code segment OR'd with privilege that lets TSS to switch to kernel mode from ring 3
    tss_entry.ss = tss_entry.ds = tss_entry.es = tss_entry.fs = tss_entry.gs = 0x10 | 0x3;
    // kernel data segment OR'd with privilege that lets TSS switch to kernel mode from ring 3
}