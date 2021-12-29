#include <asm.h>

# Start the CPU: swith to 32-bit protected mode, jump to C.
# The BIOS loads this code form the first sector of the hard disk into 
# memory at physical address 0x7c00 and starts executing in real mode
# with %cs = 0 %ip = 7c00


.set PROT_MODE_CSEG,    0x8
.set PROT_MODE_DSEG,    0x10
.set CR0_PE_ON,         0x1



