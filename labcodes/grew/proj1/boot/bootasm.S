#include <asm.h>

# Start the CPU: swith to 32-bit protected mode, jump to C.
# The BIOS loads this code form the first sector of the hard disk into 
# memory at physical address 0x7c00 and starts executing in real mode
# with %cs = 0 %ip = 7c00


.set PROT_MODE_CSEG,    0x8
.set PROT_MODE_DSEG,    0x10
.set CR0_PE_ON,         0x1


# start address should be 0:7c00, in real model, the beginning address of thre running bootloader
.globl start
start:
.code16                 # Assemble for 16-bit mode
    cli                 # disable interrupts
    cld                 # string operations increment

    # set up the import data segment registers (DS, ES, SS)
    xorw %ax, %ax       # Segment number zero
    movw %ax, %ds       # -> Date Segment
    movw %ax, %es       # -> Extra Segment
    movw %ax, %ss       # -> Stack Segment

    # Enable A20:
    # For backwards compatibility with the earliest PCs, physical
    # address line 20 is tied low, so that addresses higher than
    # 1MB wrap around to zero by default, This code undose this
seta20.1:
    inb $0x64, %al      # Wait for no busy
    testb $0x2, %al
    jnz seta20.1

    movb $0xd1, %al     # 0xd1 -> port 0x64
    outb %al, $0x64

seta20.2:
    inb $0x64, %al      # Wait for no busy
    testb $0x2, %al
    jnz seta20.2

    movb $0xdf, %al     # 0xdf -> port 0x60
    outb %al, $0x60

    # Switch form real to protected mode, using a bootstrap GDT
    # and segment translation that makes virtual address
    # identical to physical address, so that the 
    # effective memory map dos not change during the switch
    lgdt gdtdesc
    movl %cr0, %eax
    orl $CR0_PE_ON, %eax
    movl %eax, %cr0

    # Jump to the next instruction, but in 32-bit code segment.
    # SWitches processor into 32-bit mode.
    ljmp $PROT_MODE_CSEG, $protcseg


.code32         # Assemble for 32-bit mode
protcseg:
    # Set up the protected-mode data segment registers
    movw $PROT_MODE_DSEG, %ax       # Out data segment selector
    movw %ax, %ds                   # -> DS: Data segment
    movw %ax, %es                   # -> ES: Extra segment
    movw %ax, %fs                   # -> FS
    movw %ax, %gs                   # -> GS
    movw %ax, %ss                   # -> SS: Stack segment


    # Set up the stack pointer and call into C. The stack region is form 0--start(0x7c00)
    movl $0x0, %ebp
    movl $start, %esp
    call bootmain

    # If bootmain returns (it shouldn't), loop.
spin:
    jmp spin

.data
# Bootstrap GDT
.p2align 2          # force 4 byte alignment
gdt:
    SEG_NULLASM
    SEG_ASM(STA_X|STA_R, 0x0, 0xffffffff)
    SEG_ASM(STA_W, 0x0, 0xffffffff)

gdtdesc:
    .word 0x17      # sizeof(gdt) -1
    .long gdt       # address gdt


