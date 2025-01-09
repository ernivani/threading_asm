# Detect platform
UNAME := $(shell uname)
ARCH := $(shell uname -m)

# Compiler and assembler
NASM = nasm
CC = gcc
CFLAGS = -lpthread

# Output executable
OUTPUT = projet_asm/main

# Source file
SRC = projet_asm/main.asm

# Object file
OBJ = projet_asm/main.o

# Platform-specific settings
ifeq ($(UNAME), Linux)
    ASM_FLAGS = -f elf64 -D__LINUX__
    LDFLAGS = $(CFLAGS)
else ifeq ($(UNAME), Darwin)
    ifeq ($(ARCH), arm64)
        ASM_FLAGS = -f macho64 -D__MACOS__ --target=arm64-apple-darwin
        LDFLAGS = $(CFLAGS) -arch arm64
    else
        ASM_FLAGS = -f macho64 -D__MACOS__
        LDFLAGS = $(CFLAGS)
    endif
else
    $(error Unsupported platform: $(UNAME))
endif

# Build rules
all: $(OUTPUT)

$(OUTPUT): $(OBJ)
	$(CC) $(OBJ) -o $(OUTPUT) $(LDFLAGS)

$(OBJ): $(SRC)
	$(NASM) $(ASM_FLAGS) $(SRC) -o $(OBJ)

clean:
	rm -f $(OBJ) $(OUTPUT)

.PHONY: all clean
