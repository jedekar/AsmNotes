SRCDIR = src
OBJDIR = obj
BINDIR = bin
TARGET = number-repr.exe

SRC := $(wildcard $(SRCDIR)/*.asm)
OBJ := $(SRC:$(SRCDIR)/%.asm=$(OBJDIR)/%.obj)

ASM = nasm
ASMFLAGS = -fwin32
LINKER = i686-w64-mingw32-gcc
LFLAGS = -luser32 -lkernel32
RM = rm -f

$(BINDIR)/$(TARGET): $(OBJ)
		@$(LINKER) $(OBJ) $(LFLAGS) -o $@ 
		@echo "Linking complete."
$(OBJ): $(OBJDIR)/%.obj : $(SRCDIR)/%.asm
		@$(ASM) $(ASMFLAGS) -o $@ $^
		@echo "Compiled "$<" successfully."

.PHONY: clean
clean:
		@$(RM) $(OBJ) $(BINDIR)/$(TARGET)
		@echo "Cleanup complete."
