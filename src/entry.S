    .code64
    .global int_wrapper

#define SAVE_REGISTERS \
/* calle-safe */ \
    pushq %r15; \
    pushq %r14; \
    pushq %r13; \
    pushq %r12; \
    pushq %rbp; \
    pushq %rbx; \
/* caller-safe */ \
    pushq %r11; \
    pushq %r10; \
    pushq %r9;  \
    pushq %r8;  \
    pushq %rax; \
    pushq %rdx; \
    pushq %rcx; \
    pushq %rsi; \
    pushq %rdi

#define RESTORE_REGISTERS \
/* caller-safe */ \
    popq %rdi; \
    popq %rsi; \
    popq %rcx; \
    popq %rdx; \
    popq %rax; \
    popq %r8;  \
    popq %r9;  \
    popq %r10; \
    popq %r11; \
/* calle-safe */ \
    popq %rbx; \
    popq %rbp; \
    popq %r12; \
    popq %r13; \
    popq %r14; \
    popq %r15

    .extern int_common_handler
int_wrapper:
    SAVE_REGISTERS

    cld
    movq %rsp, %rdi
    call int_common_handler

    RESTORE_REGISTERS

    addq $8, %rsp /* skip pushed irqno */

    iretq

/* see intel manual, 6.3.1, table 6-1 for the list of exc and ints */

    .global EXC_0
#define EXC(n) \
EXC_##n: \
    pushq $n; \
    jmp int_wrapper

EXC(0)
EXC(1)
EXC(2)
EXC(3)
EXC(4)
EXC(5)
EXC(6)
EXC(7)
EXC(8)
EXC(9)
EXC(10)
EXC(11)
EXC(12)
EXC(13)
EXC(14)
EXC(15)
EXC(16)
EXC(17)
EXC(18)
EXC(19)
EXC(20)
EXC(21)
EXC(22)
EXC(23)
EXC(24)
EXC(25)
EXC(26)
EXC(27)
EXC(28)
EXC(29)
EXC(30)
EXC(31)
EXC(32)

#define REGISTER_EXC(n) \
    movq $n, %rdi; \
    movq $(EXC_##n), %rsi; \
    call register_irq_handler

    .global init_execptions_handlers
    .extern register_irq_handler
init_execptions_handlers:
    enter $0, $0

    REGISTER_EXC(0)
    REGISTER_EXC(1)
    REGISTER_EXC(2)
    REGISTER_EXC(3)
    REGISTER_EXC(4)
    REGISTER_EXC(5)
    REGISTER_EXC(6)
    REGISTER_EXC(7)
    REGISTER_EXC(8)
    REGISTER_EXC(9)
    REGISTER_EXC(10)
    REGISTER_EXC(11)
    REGISTER_EXC(12)
    REGISTER_EXC(13)
    REGISTER_EXC(14)
    REGISTER_EXC(15)
    REGISTER_EXC(16)
    REGISTER_EXC(17)
    REGISTER_EXC(18)
    REGISTER_EXC(19)
    REGISTER_EXC(20)
    REGISTER_EXC(21)
    REGISTER_EXC(22)
    REGISTER_EXC(23)
    REGISTER_EXC(24)
    REGISTER_EXC(25)
    REGISTER_EXC(26)
    REGISTER_EXC(27)
    REGISTER_EXC(28)
    REGISTER_EXC(29)
    REGISTER_EXC(30)
    REGISTER_EXC(31)
    REGISTER_EXC(32)

    leave
    ret
