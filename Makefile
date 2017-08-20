srcdir = src
objdir = obj
bindir = bin
incdir = src/include

CC ?= gcc
LD ?= gcc

CFLAGS := -g -m64 -mno-red-zone -mno-mmx -mno-sse -mno-sse2 -ffreestanding \
	-mcmodel=kernel -Wall -Wextra -Werror -pedantic-errors -std=c99 \
	-Wframe-larger-than=4096 -Wstack-usage=4096 -Wno-unknown-warning-option
LFLAGS := -nostdlib -z max-page-size=0x1000

ASM  := bootstrap.S videomem.S entry.S
AOBJ := $(ASM:.S=.o)
ADEP := $(ASM:.S=.d)

SRC := main.c legacy_pic.c interrupts.c string.c videomem_print.c pit.c test.c
OBJ := $(AOBJ) $(SRC:.c=.o)
DEP := $(ADEP)

all: kernel

kernel: $(objdir) $(bindir) $(OBJ) $(srcdir)/linker.ld
	$(LD) $(LFLAGS) -T $(srcdir)/linker.ld -o $(bindir)/kernel $(addprefix $(objdir)/, $(OBJ))

$(objdir):
	mkdir -p $(objdir)

$(bindir):
	mkdir -p $(bindir)

%.o: $(srcdir)/%.S
	$(CC) -D__ASM_FILE__ -g -MMD -c -I$(incdir) $< -o $(objdir)/$@

%.o: $(srcdir)/%.c
	$(CC) $(CFLAGS) -MMD -c -I$(incdir) $< -o $(objdir)/$@

.PHONY: clean
clean:
	rm -rf $(bindir)
	rm -rf $(objdir)
