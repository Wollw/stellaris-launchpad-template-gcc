TARGET = target
SRC = $(wildcard src/*.c)

#### Setup ####
TOOLCHAIN  = arm-eabi
PART       = LM4F120H5QR
CPU        = cortex-m4
FPU        = fpv4-sp-d16
FABI       = softfp

LINKER_FILE = lib/LM4F.ld
SRC        += lib/LM4F_startup.c

CC = $(TOOLCHAIN)-gcc
LD = $(TOOLCHAIN)-ld
CP = $(TOOLCHAIN)-objcopy
OD = $(TOOLCHAIN)-objdump

CFLAGS = -mthumb -mcpu=$(CPU) -mfpu=$(FPU) -mfloat-abi=$(FABI)
CFLAGS+= -O0 -ffunction-sections -fdata-sections
CFLAGS+= -MD -std=c99 -Wall -pedantic
CFLAGS+= -DPART_$(PART) -c
CFLAGS+= -g

LIB_GCC_PATH=$(shell $(CC) $(CFLAGS) -print-libgcc-file-name)
LIBC_PATH=$(shell $(CC) $(CFLAGS) -print-file-name=libc.a)
LIBM_PATH=$(shell $(CC) $(CFLAGS) -print-file-name=libm.a)
LFLAGS = --gc-sections

CPFLAGS = -Obinary

ODFLAGS = -S

FLASHER=lm4flash
FLASHER_FLAGS=-v

OBJS = $(SRC:.c=.o)

#### Rules ####
all: $(OBJS) $(TARGET).axf $(TARGET)

%.o: %.c
	@echo
	@echo Compiling $<...
	$(CC) -c $(CFLAGS) $< -o $@

$(TARGET).axf: $(OBJS)
	@echo
	@echo Linking...
	$(LD) $(LFLAGS) -o bin/$(TARGET).axf -T $(LINKER_FILE) $(OBJS) $(LIBM_PATH) $(LIBC_PATH) $(LIB_GCC_PATH) --entry=rst_handler

$(TARGET): $(TARGET).axf
	@echo
	@echo Copying...
	$(CP) $(CPFLAGS) bin/$(TARGET).axf bin/$(TARGET).bin
	$(OD) $(ODFLAGS) bin/$(TARGET).axf > bin/$(TARGET).lst

install: $(TARGET)
	@echo
	@echo Flashing...
	$(FLASHER) bin/$(TARGET).bin $(FLASHER_FLAGS)

clean:
	@echo
	@echo Cleaning...
	rm lib/*.o lib/*.d src/*.o src/*.d bin/*
