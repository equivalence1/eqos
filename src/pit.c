#include <pit.h>
#include <kernel.h>
#include <ioport.h>

#include <stdint.h>

#define DEFAULT_HZ          1193180
#define PIT_CONTROL_PORT    0x43
#define PIT_DATA_PORT       0x40

#define CONTROL_WORD        0x34

void init_pit(int frequency)
{
    int divisor = DEFAULT_HZ / frequency;

    out8(PIT_CONTROL_PORT, CONTROL_WORD);
    out8(PIT_DATA_PORT, divisor & MAX_W);
    out8(PIT_DATA_PORT, (divisor >> 8) & MAX_W);
}
