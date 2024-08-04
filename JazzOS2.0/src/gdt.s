global gdt_flush

gdt_flush:
    MOV eax, [esp+4] ; get gdt_ptr argument off the stack
    LGDT [eax] ; special instruction that tells processor where gdt is

    MOV eax, 0x10 ; entry 0 is the null segment. i.e. indexes 0-7.
    ; entry 1 is the kernel code segment at 0x08. i.e. indexes 8-15.
    ; entry 2 is kernel data segment at 0x10. i.e. 0x10 = 16, so index 16.
    MOV ds, ax
    MOV es, ax
    MOV fs, ax
    MOV gs, ax
    MOV ss, ax
    JMP 0x08:.flush

.flush:
    RET

global tss_flush

tss_flush:
    MOV ax, 0x2B
    LTR ax
    RET