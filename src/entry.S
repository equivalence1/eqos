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

    addq $16, %rsp /* skip pushed irqno and error code */

    iretq

/* see intel manual, 6.3.1, table 6-1 for the list of exc and ints */

#define EXC(n) \
    .align 16; \
EXC_##n: \
    pushq $n; \
    jmp int_wrapper

#define INT(n) \
    .align 16; \
INT_##n: \
    pushq $0; /* push fake error code */ \
    pushq $n; \
    jmp int_wrapper

INT(0)
INT(1)
INT(2)
INT(3)
INT(4)
INT(5)
INT(6)
INT(7)
EXC(8)
INT(9)
EXC(10)
EXC(11)
EXC(12)
EXC(13)
EXC(14)
INT(15)
INT(16)
EXC(17)
INT(18)
INT(19)
INT(20)
INT(21)
INT(22)
INT(23)
INT(24)
INT(25)
INT(26)
INT(27)
INT(28)
INT(29)
INT(30)
INT(31)
INT(32)

#define REGISTER_EXC(n) \
    movq $n, %rdi; \
    movq $(EXC_##n), %rsi; \
    call register_irq_handler

#define REGISTER_INT(n) \
    movq $n, %rdi; \
    movq $(INT_##n), %rsi; \
    call register_irq_handler

    .global init_execptions_handlers
    .extern register_irq_handler
init_execptions_handlers:
    enter $0, $0

    REGISTER_INT(0)
    REGISTER_INT(1)
    REGISTER_INT(2)
    REGISTER_INT(3)
    REGISTER_INT(4)
    REGISTER_INT(5)
    REGISTER_INT(6)
    REGISTER_INT(7)
    REGISTER_EXC(8)
    REGISTER_INT(9)
    REGISTER_EXC(10)
    REGISTER_EXC(11)
    REGISTER_EXC(12)
    REGISTER_EXC(13)
    REGISTER_EXC(14)
    REGISTER_INT(15)
    REGISTER_INT(16)
    REGISTER_EXC(17)
    REGISTER_INT(18)
    REGISTER_INT(19)
    REGISTER_INT(20)
    REGISTER_INT(21)
    REGISTER_INT(22)
    REGISTER_INT(23)
    REGISTER_INT(24)
    REGISTER_INT(25)
    REGISTER_INT(26)
    REGISTER_INT(27)
    REGISTER_INT(28)
    REGISTER_INT(29)
    REGISTER_INT(30)
    REGISTER_INT(31)
    REGISTER_INT(32)

    leave
    ret
