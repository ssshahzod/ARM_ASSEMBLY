CROSS_COMPILE ?= aarch64-linux-gnu-

AS = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld

ASFLAGS = -g
LDFLAGS = -g -static

SRCS = prog2.s
OBJS = $(SRCS:.s=.o)

EXE = prog2

all: $(SRCS) $(EXE)

clean: 
	rm -rf $(EXE) $(OBJS)

$(EXE): $(OBJS) 
		$(LD) $(LDFLAGS) $(OBJS) -o $@

.s.o:
		$(AS) $(ASFLAGS) $< -o $@
		
.PHONY: default 
deafault: asc

.PHONY: asc
asc:
	$(AS) $(ASFLAGS) $(SRCS) -o $(OBJS) --defsym ascending=1
	$(LD) $(LDFLAGS) $(OBJS) -o $(EXE)

.PHONY: desc
desc:
	$(AS) $(ASFLAGS) $(SRCS) -o $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $(EXE)