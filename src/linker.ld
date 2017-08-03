OUTPUT_FORMAT(elf64-x86-64)
OUTPUT_ARCH(i386:x86-64)
ENTRY(start_32)

PAGE_SIZE = 0x1000; /* 4096 bytes */
VIRTUAL_BASE = 0xffffffff80000000; /* skip Canonical Address Space Hole */

/* Remember that at the moment of booting, pagging is not yet enabled, so setting VMA does not actually do anything.
 * It's just handy to have those contants.
 */

SECTIONS {
    . = 1M + SIZEOF_HEADERS;

    text_phys_begin = .; /* all this constants are needed for mb_header, see https://www.gnu.org/software/grub/manual/multiboot/multiboot.html#Header-address-fields */
    text_virt_begin = . + VIRTUAL_BASE;
    .bootstrap : { *(.bootstrap) }

    /* location counter sets VMA.
     * This means that addresses in bootstrap section will be low (before hole)
     * and addresses (virtual ones) in text will be after hole.
     * This is important since bootstrap should work in protected mode (so only addresses which fit in 32-bit are allowed) while
     * the rest of the code in long mode and should be awailable to userspace. */
    . += VIRTUAL_BASE;

    .text : AT(ADDR(.bootstrap) + SIZEOF(.bootstrap)) { *(.text) } /* AT sets load address (phys) */

    data_phys_begin = . - VIRTUAL_BASE;
    data_virt_begin = .;
    .data : { *(.data) }
    data_phys_end = . - VIRTUAL_BASE;
    data_virt_end = .;

    . = ALIGN(PAGE_SIZE); /* paging + stack should be aligned */

    bss_phys_begin = . - VIRTUAL_BASE;
    bss_virt_begin = .;
    .bss : {
        . += 6 * PAGE_SIZE; /* this is for initial paging tables */
        *(.bss)
    }
    bss_phys_end = . - VIRTUAL_BASE;
    bss_virt_end = .;
}
