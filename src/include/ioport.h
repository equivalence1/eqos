#ifndef __IOPORT_H__
#define __IOPORT_H__

#include <stdint.h>

static inline void out8(uint16_t port, uint8_t data)
{
    __asm__ volatile("outb %0, %1" : : "a"(data), "d"(port));
}

static inline uint8_t in8(uint16_t port)
{
    uint8_t res;
    __asm__ volatile("inb %1, %0" : "=a"(res) : "d"(port));

    return res;
}

#endif // __IOPORT_H__
