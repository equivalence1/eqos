#ifndef __THREAD_REGS_H__
#define __THREAD_REGS_H__

#include <stdint.h>

/* see intel 6.14.4 on more info about error and below */

struct thread_regs {
    uint64_t rdi;
    uint64_t rsi;
    uint64_t rcx;
    uint64_t rdx;
    uint64_t rax;
    uint64_t r8;
    uint64_t r9;
    uint64_t r10;
    uint64_t r11;
    uint64_t rbx;
    uint64_t rbp;
    uint64_t r12;
    uint64_t r13;
    uint64_t r14;
    uint64_t r15;
    uint64_t irqno;
    uint64_t error; // error code
    uint64_t rip;
    uint64_t cs;
    uint64_t rflags;
    uint64_t rsp;
    uint64_t ss;
} __attribute__((packed));

typedef struct thread_regs thread_regs_t;

#endif // __THREAD_REGS_H__
