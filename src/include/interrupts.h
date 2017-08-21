#ifndef __INTERRUPT_H__
#define __INTERRUPT_H__

#include <stdint.h>

#define KERNEL_CODE     0x8

static inline void int_enable(void)
{
    __asm__ volatile("sti" : : : "cc");
}

static inline void int_disable(void)
{
    __asm__ volatile("cli" : : : "c");
}

void register_irq_handler(int irqno, uint64_t addr);
void unregister_irq_handler(int irqno);

void init_idt(void);

#endif // __INTERRUPT_H__
