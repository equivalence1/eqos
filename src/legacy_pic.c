#include <legacy_pic.h>
#include <ioport.h>

#define MASTER_COMMAND_REGISTER           0x20
#define MASTER_STATUS_REGISTER            0x20
#define MASTER_DATA_REGISTER              0x21
#define MASTER_INT_MASK_REGISTER          0x21

#define SLAVE_COMMAND_REGISTER            0xA0
#define SLAVE_STATUS_REGISTER             0xA0
#define SLAVE_DATA_REGISTER               0xA1
#define SLAVE_INT_MASK_REGISTER           0xA1

#define COMMON_ICW1                       0x11
#define MASTER_ICW2                       0x20
#define SLAVE_ICW2                        0x28
#define MASTER_ICW3                       0x04
#define SLAVE_ICW3                        0x02
#define MODE_8086                         0x01

#define NON_SPECIFIC_EOI                  0x20

void init_legacy_pic(void)
{
    out8(MASTER_COMMAND_REGISTER, COMMON_ICW1);
    out8(MASTER_COMMAND_REGISTER, COMMON_ICW1);

    out8(MASTER_DATA_REGISTER, MASTER_ICW2);
    out8(SLAVE_DATA_REGISTER, SLAVE_ICW2);

    out8(MASTER_DATA_REGISTER, MASTER_ICW3);
    out8(SLAVE_DATA_REGISTER, SLAVE_ICW3);

    out8(MASTER_DATA_REGISTER, MODE_8086);
    out8(SLAVE_DATA_REGISTER, MODE_8086);
}

void send_eoi(int controllers)
{
    if (controllers & MASTER_PIC)
        out8(MASTER_COMMAND_REGISTER, NON_SPECIFIC_EOI);
    if (controllers & SLAVE_PIC)
        out8(SLAVE_COMMAND_REGISTER, NON_SPECIFIC_EOI);
}
