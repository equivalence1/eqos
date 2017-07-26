OUTPUT_FORMAT(elf64-x86-64)
OUTPUT_ARCH(i386:x86-64)
ENTRY(start_32)

PAGE_SIZE = 0x1000; /* 4096 bytes */
VIRTUAL_BASE = 0xffffffff80000000; /* skip Canonical Address Space Hole */

SECTIONS {
    . = 1M + SIZEOF_HEADERS;

    text_phys_begin = .; /* all this constants are needed for mb_header, see https://www.gnu.org/software/grub/manual/multiboot/multiboot.html#Header-address-fields */
    text_virt_begin = . + VIRTUAL_BASE;
    .bootstrap : { *(.bootstrap) }

    . += VIRTUAL_BASE;
    .text : AT(ADDR(.bootstrap) + SIZEOF(.bootstrap)) { *(.text) } /* AT sets load address (phys) */

    data_phys_begin = . - VIRTUAL_BASE;
    data_virt_begin = .;
    .data : { *(.data) }
    data_phys_end = . - VIRTUAL_BASE;
    data_virt_end = .;

    . = ALIGN(PAGE_SIZE); /* TODO */

    bss_phys_begin = . - VIRTUAL_BASE;
    bss_virt_begin = .;
    .bss : { *(.bss) }
    bss_phys_end = . - VIRTUAL_BASE;
    bss_virt_end = .;
}
