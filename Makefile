srcdir = src
objdir = obj
bindir = bin

CC ?= gcc
LD ?= gcc

CFLAGS := -g -m64 -mno-red-zone -mno-mmx -mno-sse -mno-sse2 -ffreestanding \
	-mcmodel=kernel -Wall -Wextra -Werror -pedantic-errors -std=c99 \
	-Wframe-larger-than=4096 -Wstack-usage=4096 -Wno-unknown-warning-option
LFLAGS := -nostdlib -z max-page-size=0x1000

ASM  := bootstrap.S
AOBJ := $(ASM:.S=.o)
ADEP := $(ASM:.S=.d)

SRC := 
OBJ := $(AOBJ)
DEP := $(ADEP)

all: kernel

kernel: $(objdir) $(bindir) $(OBJ) $(srcdir)/linker.ld
	$(LD) $(LFLAGS) -T $(srcdir)/linker.ld -o $(bindir)/kernel $(addprefix $(objdir)/, $(OBJ))

$(objdir):
	mkdir -p $(objdir)

$(bindir):
	mkdir -p $(bindir)

%.o: $(srcdir)/%.S
	$(CC) -D__ASM_FILE__ -g -MMD -c $< -o $(objdir)/$@

.PHONY: clean
clean:
	rm -rf $(bindir)
	rm -rf $(objdir)