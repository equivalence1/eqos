#include <string.h>

void memset(void *ptr, int value, size_t num)
{
    size_t i = 0;
    while (i < num) {
        *((char *)ptr + i) = value;
        i++;
    }
}
