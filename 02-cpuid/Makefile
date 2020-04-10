src = $(wildcard src/*.asm)
obj = $(src:.asm=.obj)

ASM = nasm
ASMFLAGS = -fwin32
CC = i686-w64-mingw32-gcc
LDFLAGS = -luser32 -lkernel32

bin/cpuid.exe: $(obj)
		@mkdir bin
		$(CC) -o $@ $^ $(LDFLAGS)
src/cpuid.obj: $(src)
		$(ASM) $(ASMFLAGS) -o $@ $^

.PHONY: clean
clean:
		rm -rf $(obj) bin
