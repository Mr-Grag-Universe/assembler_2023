AS = nasm
LD = /usr/bin/ld

ASFLAGS = -g -f elf64
LDFLAGS = -static

SRCS = env.s string.s file.s lab.s
OBJS = lab.o env.o string.o file.o

EXE = lab

all: $(SRCS) $(EXE)

clean:
	rm -rf $(EXE) $(OBJS)

$(EXE): $(OBJS)
	# cd build
	$(LD) $(LDOBJS) $(OBJS) -o $@

.s.o:
	$(AS) $(ASFLAGS) $< -o $@


