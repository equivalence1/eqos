#define MB_HEADER_MAGIC 0x1BADB002
#define MB_HEADER_FLAGS ((1 << 16) | (1 << 1))
#define MB_HEADER_CKSUM -(MB_HEADER_MAGIC + MB_HEADER_FLAGS)

/* see https://sourceware.org/binutils/docs/as/Section.html for "ax" flags */
    .section .bootstrap, "ax"
    .code32
    .global start_32

/* see https://www.gnu.org/software/grub/manual/multiboot/multiboot.html#OS-image-format for more info */
    .align 4
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
    .align 16 /* System V ABI wants it to be 16-byte aligned */
    .space 0x100
bootstrap_stack_top:

/* entry point of our OS, still in protected mode now */
start_32:
    movl $bootstrap_stack_top, %esp

    pushl %eax
    call videomem_clrscr
    popl %eax

    call check_multiboot

    pushl $ok_message
    call videomem_puts
    addl $4, %esp

    hlt

/* check that the bootloader is really multiboot-compatible */
check_multiboot:
    cmp $0x2badb002, %eax
    jne not_multiboot
    ret
not_multiboot:
    push $not_multiboot_message
    jmp fail

fail:
    call videomem_puts
halt: /* just hlt is not enough -- CPU might continue because of interrupt */
    hlt
    jmp halt

not_multiboot_message:
    .asciz "Not a multiboot compatible bootloader!\n";
ok_message:
    .asciz "OK!\n";

/* this is our normal stack for the rest of the code.
   We can not use it here, in bootstrap because it's VMA
   is to huge for 32-bit value.
   See this for more info: https://stackoverflow.com/questions/10486116/what-does-this-gcc-error-relocation-truncated-to-fit-mean
   (2nd answer is better) */
    .section .bss
    .align 0x1000 /* TODO: Why do we use align both here and in kernel.ld? */
stack_bottom:
    .space 0x2000
stack_top:
