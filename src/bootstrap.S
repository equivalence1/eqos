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

start_32:
    movl $0x2f4b2f4f, (0xb8000) /* just print "OK" on screen */
    hlt
