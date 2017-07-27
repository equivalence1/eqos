#define MB_HEADER_MAGIC 0x1BADB002
#define MB_HEADER_FLAGS ((1 << 16) | (1 << 1))
#define MB_HEADER_CKSUM -(MB_HEADER_MAGIC + MB_HEADER_FLAGS)

/* see https://sourceware.org/binutils/docs/as/Section.html for "ax" flags */
    .section .bootstrap, "ax"
    .code32
    .global start_32

/* see https://www.gnu.org/software/grub/manual/multiboot/multiboot.html#OS-image-format for more info */
    .align 32
mb_header_begin:
    .long MB_HEADER_MAGIC
    .long MB_HEADER_FLAGS
    .long MB_HEADER_CKSUM
    .long mb_header_begin /* header_addr */
    .long text_phys_begin /* load_addr */
    .long data_phys_end   /* load_end_addr */
    .long bss_phys_end    /* bss_end_addr */
    .long start_32        /* entry_addr */

/* this stack is only to use here, in bootstrap */
    .space 0x100
bootstrap_stack_top:

start_32:
    movl $bootstrap_stack_top, %esp
    movl $0x2f4b2f4f, (0xb8000) /* just print "OK" on screen */
    hlt

/* this is our normal stack for the rest of the code.
   We can not use it here, in bootstrap because it's VMA
   is to huge for 32-bit value.
   See this for more info: https://stackoverflow.com/questions/10486116/what-does-this-gcc-error-relocation-truncated-to-fit-mean
   (2nd answer is better) */
    .section .bss
    .align 0x1000
stack_bottom:
    .space 0x2000
stack_top:
