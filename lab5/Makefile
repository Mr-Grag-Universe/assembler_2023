AS = nasm
LD = /usr/bin/ld
CC = gcc

ZERO=0

export asm_func

ifneq ($(1), $(ZERO))
asm_func=INCLUDE_ASM_FUNC
# $(info flag's been set)
else
asm_func=NOT_INCLUDE_ASM_FUNC
endif

ASFLAGS = -g -f elf64
CCFLAGS = -g -lm
LDFLAGS = -static

ASM_SRCS = func.s
C_SRCS = main.c
AS_OBJS = func.o
C_OBJS = main.o
O0 = $(subst .o,0.o, $(C_OBJS))
O1 = $(subst .o,1.o, $(C_OBJS))
O2 = $(subst .o,2.o, $(C_OBJS))
O3 = $(subst .o,3.o, $(C_OBJS))
Ofast = $(subst .o,fast.o, $(C_OBJS))

EXE = app

all: $(ASM_SRCS) $(C_SRCS) $(EXE)

clean:
	rm -rf $(EXE) $(C_OBJS) $(AS_OBJS)
clean_all:
	rm -rf $(EXE)* *.o

$(EXE): $(AS_OBJS) $(C_SRCS)
	$(CC) -c -O0 -D$(asm_func) -o $(subst .o,0.o, $(C_OBJS)) $(C_SRCS)
	$(CC) $(LDOBJS) $(CCFLAGS) -D$(asm_func) -O0 -o $@0 -lm $(O0) $(AS_OBJS)

	$(CC) -c -O1 -D$(asm_func) -o $(subst .o,1.o, $(C_OBJS)) $(C_SRCS)
	$(CC) $(LDOBJS) $(CCFLAGS) -D$(asm_flag) -O1 $(O1) $(AS_OBJS) -o $@1
	
	$(CC) -c -O2 -D$(asm_func) -o $(subst .o,2.o, $(C_OBJS)) $(C_SRCS)
	$(CC) $(LDOBJS) $(CCFLAGS) -D$(asm_func) -O2 $(O2) $(AS_OBJS) -o $@2
	
	$(CC) -c -O3 -D$(asm_func) -o $(subst .o,3.o, $(C_OBJS)) $(C_SRCS)
	$(CC) $(LDOBJS) $(CCFLAGS) -D$(asm_func) -O3 $(O3) $(AS_OBJS) -o $@3
	
	$(CC) -c -Ofast -D$(asm_func) -o $(subst .o,fast.o, $(C_OBJS)) $(C_SRCS)
	$(CC) $(LDOBJS) $(CCFLAGS) -D$(asm_func) -Ofast $(Ofast) $(AS_OBJS) -o $@fast

$(EXE)0: $(AS_OBJS) $(C_SRCS)
	$(CC) -c -O0 -D$(asm_func) -o $(subst .o,0.o, $(C_OBJS)) $(C_SRCS)
	$(CC) $(LDOBJS) $(CCFLAGS) -D$(asm_func) -O0 -o $@ -lm $(O0) $(AS_OBJS)

$(EXE)1: $(AS_OBJS) $(C_SRCS)
	$(CC) -c -O1 -D$(asm_func) -o $(subst .o,1.o, $(C_OBJS)) $(C_SRCS)
	$(CC) $(LDOBJS) $(CCFLAGS) -D$(asm_flag) -O1 $(O1) $(AS_OBJS) -o $@

$(EXE)2: $(AS_OBJS) $(C_SRCS)
	$(CC) -c -O2 -D$(asm_func) -o $(subst .o,2.o, $(C_OBJS)) $(C_SRCS)
	$(CC) $(LDOBJS) $(CCFLAGS) -D$(asm_func) -O2 $(O2) $(AS_OBJS) -o $@

$(EXE)3: $(AS_OBJS) $(C_SRCS)
	$(CC) -c -O3 -D$(asm_func) -o $(subst .o,3.o, $(C_OBJS)) $(C_SRCS)
	$(CC) $(LDOBJS) $(CCFLAGS) -D$(asm_func) -O3 $(O3) $(AS_OBJS) -o $@

$(EXE)fast: $(AS_OBJS) $(C_SRCS)
	$(CC) -c -Ofast -D$(asm_func) -o $(subst .o,fast.o, $(C_OBJS)) $(C_SRCS)
	$(CC) $(LDOBJS) $(CCFLAGS) -D$(asm_func) -Ofast $(Ofast) $(AS_OBJS) -o $@

.s.o:
	$(AS) $(ASFLAGS) -O2 $< -o  $@

$(subst .o, o, C_OBJS):
	$(CC) $(C_SRCS) -c -O1 -o $(C_OBJS)
