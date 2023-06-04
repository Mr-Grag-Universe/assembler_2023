AS = nasm
LD = /usr/bin/ld

ASFLAGS = -g -f elf64
LDFLAGS = -static

SRCS = lab.s
OBJS = $(SRCS:.s=.o)

export order

F = forward
B = backward

EXE = lab

all: $(SRCS) $(EXE)

clean:
	rm -rf $(EXE) $(OBJS)

$(EXE): $(OBJS)
	$(LD) $(LDOBJS) $(OBJS) -o $@

.s.o:
ifeq ($(B), $(order))
	$(AS) $(ASFLAGS) -DReversedOrder $< -o $@
else
	$(AS) $(ASFLAGS) $< -o $@
endif

