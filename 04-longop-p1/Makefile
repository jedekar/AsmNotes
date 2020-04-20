SRCDIR = src
OBJDIR = obj
BINDIR = bin
TARGET = longop.exe

SRC := $(wildcard $(SRCDIR)/*.asm)
OBJ := $(SRC:$(SRCDIR)/%.asm=$(OBJDIR)/%.obj)

ASM = nasm
ASMFLAGS = -fwin32
LINKER = i686-w64-mingw32-gcc
LFLAGS = -luser32 -lkernel32
RM = rm -rf

$(BINDIR)/$(TARGET): $(OBJ)
		@mkdir -p $(BINDIR)
		@$(LINKER) $(OBJ) $(LFLAGS) -o $@ 
		@echo "Linking complete."
$(OBJ): $(OBJDIR)/%.obj : $(SRCDIR)/%.asm
		@mkdir -p $(OBJDIR)
		@$(ASM) $(ASMFLAGS) -o $@ $^
		@echo "Compiled "$<" successfully."

.PHONY: clean
clean:
		@$(RM) $(OBJDIR) $(BINDIR)
		@echo "Cleanup complete."
