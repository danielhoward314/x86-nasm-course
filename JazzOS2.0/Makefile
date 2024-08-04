ASM=nasm
CC=gcc
CC_FLAGS=-m32 -fno-stack-protector -fno-builtin
LD=ld
ISO_TOOL=grub-mkrescue
SRC_DIR=src
BUILD_DIR=build
JAZZ_DIR=Jazz

all: always kernel iso

kernel: $(BUILD_DIR)/kernel
$(BUILD_DIR)/kernel:
	$(ASM) -f elf32 $(SRC_DIR)/boot.s -o $(BUILD_DIR)/boot.o
	$(ASM) -f elf32 $(SRC_DIR)/gdt.s -o $(BUILD_DIR)/gdts.o
	$(ASM) -f elf32 $(SRC_DIR)/interrupts/idt.s -o $(BUILD_DIR)/idts.o
	$(CC) $(CC_FLAGS) -g -c $(SRC_DIR)/interrupts/idt.c -o $(BUILD_DIR)/idt.o
	$(CC) $(CC_FLAGS) -g -c $(SRC_DIR)/util.c -o $(BUILD_DIR)/util.o
	$(CC) $(CC_FLAGS) -g -c $(SRC_DIR)/gdt.c -o $(BUILD_DIR)/gdt.o
	$(CC) $(CC_FLAGS) -g -c $(SRC_DIR)/vga.c -o $(BUILD_DIR)/vga.o
	$(CC) $(CC_FLAGS) -g -c $(SRC_DIR)/kernel.c -o $(BUILD_DIR)/kernel.o
	$(LD) -m elf_i386 -T $(SRC_DIR)/linker.ld -o $(BUILD_DIR)/kernel $(BUILD_DIR)/boot.o $(BUILD_DIR)/kernel.o $(BUILD_DIR)/vga.o $(BUILD_DIR)/gdt.o $(BUILD_DIR)/gdts.o $(BUILD_DIR)/util.o $(BUILD_DIR)/idt.o $(BUILD_DIR)/idts.o

iso: $(JAZZ_DIR)/kernel
$(JAZZ_DIR)/kernel: kernel
	mv $(BUILD_DIR)/kernel $(JAZZ_DIR)/boot/kernel
	$(ISO_TOOL) -o Jazz.iso $(JAZZ_DIR)

always:
	mkdir -p $(BUILD_DIR)

clean:
	rm -rf build/*
	rm $(JAZZ_DIR)/boot/kernel
	rm Jazz.iso