#include <legacy_pic.h>
#include <interrupts.h>
#include <pit.h>
#include <test.h>

int main(void)
{
    init_legacy_pic();
    init_idt();
    init_pit(20);

    int_enable();

    while (1);
}
