#include <test.h>

void test_interrupts(void)
{
    int k = 0;
    int x = 1 / k;
    (void)sizeof(k);
    (void)sizeof(x);
}
