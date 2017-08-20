#include <videomem_print.h>

#define ROWS 25
#define COLS 80
#define ADDR 0xb8000

static int row = 0;
static int col = 0;

static void new_line()
{
    row = (row + 1) % ROWS;
    col = 0;
}

static void putchar(char ch)
{
    if (ch == '\n') {
        new_line();
        return;
    }

    char *addr = (char *)((char *)ADDR + 2 * (COLS * row + col));
    *(addr) = ch;
    *(addr + 1) = 7;

    col++;
    if (col == COLS)
        new_line();
}

void video_print(const char *str)
{
    int i = 0;
    while (str[i] != 0) {
        putchar(str[i]);
        i++;
    }
}
