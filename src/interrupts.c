#include <interrupts.h>
#include <stdint.h>
#include <kernel.h>
#include <thread_regs.h>
#include <string.h>
#include <videomem_print.h>

#define IDT_PRESENT              (1ull << 15)
#define IDT_64INT                14ull

struct idt_entry {
    uint16_t offset_1;
    uint16_t selector;
    uint16_t flags;
    uint16_t offset_2;
    uint32_t offset_3;
    uint32_t reserved;
} __attribute__((packed));

struct idt_ptr {
    uint16_t limit;
    uint64_t base;
} __attribute__((packed));

typedef struct idt_entry idt_entry_t;
typedef struct idt_ptr idt_ptr_t;

idt_entry_t IDT[256];

static const char *messages[33] = {
    "0: Divide Error",
    "1: Debug Excecption",
    "2: NMI Interrupt",
    "3: Breakpoint",
    "4: Overflow",
    "5: BOUND Range Exceeded",
    "6: Invalid Opcode",
    "7: Device Not Available",
    "8: Double Fault",
    "9: Coprocessor Segment Overrun",
    "10: Invalid TSS",
    "11: Segment Not Presented",
    "12: Stack-Segment Fault",
    "13: General Protection",
    "14: Page Fault",
    "15: Undefined Exception",
    "16: x87 FPU Floating-Point Error",
    "17: Aligment Check",
    "18: Machine Check",
    "19: SIMD Floating-Point Exception",
    "20: Virtualization Exception",
    "21: Undefined Exception",
    "22: Undefined Exception",
    "23: Undefined Exception",
    "24: Undefined Exception",
    "25: Undefined Exception",
    "26: Undefined Exception",
    "27: Undefined Exception",
    "28: Undefined Exception",
    "29: Undefined Exception",
    "30: Undefined Exception",
    "31: Undefined Exception",
    "32: Timer",
};

static void set_idt(idt_ptr_t *ptr)
{
    __asm__ volatile("lidt (%0)" : : "a"(ptr));
}

void register_irq_handler(int irqno, uint64_t addr)
{
    idt_entry_t entry = {0};

    entry.offset_1 = addr & MAX_W;
    entry.offset_2 = (addr & (MAX_W << 16)) >> 16;
    entry.offset_3 = (addr & (MAX_L << 32)) >> 32;

    entry.selector = KERNEL_CODE;

    entry.flags |= IDT_PRESENT;
    entry.flags |= IDT_64INT << 8;

    IDT[irqno] = entry;
}

void unregister_irq_handler(int irqno)
{
    memset(IDT + irqno, 0, sizeof(IDT[irqno]));
}

void int_common_handler(thread_regs_t *regs)
{
    (void)sizeof(regs);

    video_print(messages[regs->irqno]);

    while (1);
    return;
}

void init_idt(void)
{
    extern void init_execptions_handlers(void);
    init_execptions_handlers();

    idt_ptr_t ptr = {0};
    ptr.limit = sizeof(IDT) / sizeof(IDT[0]) - 1;
    ptr.base = (uint64_t)IDT;
    set_idt(&ptr);
}
