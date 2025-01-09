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
    LDFLAGS = $(CFLAGS) -no-pie  # Disable position-independent executable
else ifeq ($(UNAME), Darwin)
    ifeq ($(ARCH), arm64)
        ASM_FLAGS = -f macho64 -D__MACOS__
        LDFLAGS = $(CFLAGS)
        # Prefix commands with arch -x86_64 for arm64
        CC := arch -x86_64 $(CC)
        NASM := arch -x86_64 $(NASM)
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

run: $(OUTPUT)
	./$(OUTPUT)

.PHONY: all clean run
