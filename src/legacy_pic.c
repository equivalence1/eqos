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

#define MAIN_WORD                         0x11
#define MASTER_ICW                        0x20
#define SLAVE_ICW                         0x28
#define MASTER_CASCADE_CONF               0x04
#define SLAVE_CASCADE_CONF                0x02
#define MODE_8086                         0x01

void init_legacy_pic(void)
{
    out8(MASTER_COMMAND_REGISTER, MAIN_WORD);
    out8(MASTER_COMMAND_REGISTER, MAIN_WORD);

    out8(MASTER_DATA_REGISTER, MASTER_ICW);
    out8(SLAVE_DATA_REGISTER, SLAVE_ICW);

    out8(MASTER_DATA_REGISTER, MASTER_CASCADE_CONF);
    out8(SLAVE_DATA_REGISTER, SLAVE_CASCADE_CONF);

    out8(MASTER_DATA_REGISTER, MODE_8086);
    out8(SLAVE_DATA_REGISTER, MODE_8086);
}
