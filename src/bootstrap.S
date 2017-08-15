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


gdt:
    .quad 0x0000000000000000    /* zero entry */
    .quad 0x00a09a0000000000    /* code segment: bits[55, 53, 47, 44, 43, 41] */
    .quad 0x00a0920000000000    /* data, etc. segment: bits[55, 53, 47, 44, 41] */
gdt_ptr:
    .word (gdt_ptr - gdt - 1)
    .quad gdt


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
    call check_cpuid
    call check_long_mode
    call setup_initial_paging
    call enable_paging
    lgdt (gdt_ptr)
    ljmp $0x8, $start_64   /* need to update cs register, so ljmp */


#define PTE_PRESENT     (1 << 0)
#define PTE_WRITE       (1 << 1)
#define PTE_LARGE       (1 << 7)
#define CR4_PAE         (1 << 5)

#define p4_table        (bss_phys_begin)
#define p3_table        (bss_phys_begin + 0x1000)
#define p2_table        (bss_phys_begin + 0x2000)

setup_initial_paging:
    movl $p3_table, %eax
    orl $(PTE_PRESENT | PTE_WRITE), %eax
    movl $p4_table, %edx

    movl %eax, (%edx)           // first entry
    movl %eax, 2048(%edx)       // entry just after Hole
    movl %eax, 4088(%edx)       // last entries

	addl $PAGE_SIZE, %edx       // now %edx points to p3
	addl $PAGE_SIZE, %eax       // %eax points to p2
	movl %eax, (%edx)
	movl %eax, 4080(%edx)

	addl $PAGE_SIZE, %eax       // %eax points to next p2 (we need 4 of them since we want to map 4GiB)
	movl %eax, 8(%edx)
	movl %eax, 4088(%edx)

	addl $PAGE_SIZE, %eax
	movl %eax, 16(%edx)
	addl $PAGE_SIZE, %eax
	movl %eax, 24(%edx)

	addl $PAGE_SIZE, %edx
	movl $(PTE_LARGE | PTE_PRESENT | PTE_WRITE), %eax
	movl $2048, %ecx
1:
	movl %eax, (%edx)
	addl $0x200000, %eax
	addl $8, %edx
	loop 1b

    ret


enable_paging:
    movl $p4_table, %eax
    movl %eax, %cr3
    // enable PAE flag in cr4
    movl %cr4, %eax
    orl $CR4_PAE, %eax
    movl %eax, %cr4
    // set the long mode bit in the EFER MSR (model specific register)
    movl $0xC0000080, %ecx
    rdmsr
    orl $(1 << 8), %eax
    wrmsr
    // enable paging in the cr0 register
    movl %cr0, %eax
    orl $(1 << 31), %eax
    movl %eax, %cr0

    ret


/* see http://wiki.osdev.org/CPUID and https://os.phil-opp.com/entering-longmode/ for this checks */
check_long_mode:
    movl $0x80000000, %eax
    cpuid
    cmpl $0x80000001, %eax
    jl no_long_mode

    movl $0x80000001, %eax
    cpuid
    testl $(1 << 29), %edx
    jz no_long_mode
    ret

no_long_mode:
    pushl $no_long_mode_message
    jmp fail


check_cpuid:
    // Copy FLAGS in to EAX via stack
    pushf
    popl %eax
    // Copy to ECX as well for comparing later on
    movl %eax, %ecx
    // Flip the ID bit
    xorl $(1 << 21), %eax
    // Copy EAX to FLAGS via the stack
    pushl %eax
    popf
    // Copy FLAGS back to EAX (with the flipped bit if CPUID is supported)
    pushf
    popl %eax
    // Restore FLAGS from the old version stored in ECX (i.e. flipping the
    // ID bit back if it was ever flipped).
    pushl %ecx
    popf
    // Compare EAX and ECX. If they are equal then that means the bit
    // wasn't flipped, and CPUID isn't supported.
    cmpl %eax, %ecx
    je no_cpuid
    ret

no_cpuid:
    pushl $no_cpuid_message
    jmp fail


/* check that the bootloader is really multiboot-compatible */
check_multiboot:
    cmpl $0x2badb002, %eax
    jne not_multiboot
    ret
not_multiboot:
    pushl $not_multiboot_message
    jmp fail


fail:
    call videomem_puts
halt: /* just hlt is not enough -- CPU might continue because of interrupt */
    hlt
    jmp halt


not_multiboot_message:
    .asciz "Not a multiboot compatible bootloader\n";
no_cpuid_message:
    .asciz "CPUID is not supported\n"
no_long_mode_message:
    .asciz "long mode is not supported\n"


    .code64
    .extern main
start_64:
    movq $stack_top, %rsp

    movw $0x10, %ax
    movw %ax, %ss
    movw %ax, %ds
    movw %ax, %es
    movw %ax, %fs
    movw %ax, %gs

    // print OKAY
    mov $0x2f592f412f4b2f4f, %rax
    mov %rax, (0xb8000)

    cld
    movabsq $main, %rax

    call *%rax

// should be unreachable. (return from kernel main???)

    cli
1:
    hlt
    jmp 1b

    .section .bss
/* this is our normal stack for the rest of the code.
   We can not use it here, in bootstrap because it's VMA
   is to huge for 32-bit value.
   See this for more info: https://stackoverflow.com/questions/10486116/what-does-this-gcc-error-relocation-truncated-to-fit-mean
   (2nd answer is better) */
    .align 0x1000
stack_bottom:
    .space 0x2000
stack_top:
