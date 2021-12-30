#ifndef __BOOT_ASM_H__
#define __BOOT_ASM_H__

/* Assembler macros to create x86 segments */

/* Normal segment */

/* define a null asm segment */
#define SEG_NULLASM         \
    .word 0, 0;             \
    .byte 0, 0, 0, 0        

#define SEG_ASM(type, base, lim)                            \
    .word 0, 0;                                             \
    .byte 0, 0, 0, 0            


/* Application segment type bits */
#define STA_X       0x8         // Executable segment
#define STA_E       0x4         // Expand down(non-executable segments) 
#define STA_C       0x4         // Comforming code segment(executable only) 
#define STA_W       0x2         // Writable(non-executable segments)
#define STA_R       0x2         // Readable(executable segments)
#define STA_A       0x1         // Accessed


#endif       /* !__BOOT_ASM_H__ */
