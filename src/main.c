#include <legacy_pic.h>
#include <interrupts.h>
#include <test.h>

int main(void)
{
    init_legacy_pic();
    init_idt();

    test_interrupts();

    while (1);
}
