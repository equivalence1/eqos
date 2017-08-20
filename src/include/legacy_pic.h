#ifndef __LEGACY_PIC_H__
#define __LEGACY_PIC_H__

#define MASTER_PIC     (1 << 0)
#define SLAVE_PIC      (1 << 1)

void init_legacy_pic(void);
void send_eoi(int controllers);

#endif // __LEGACY_PIC_H__
