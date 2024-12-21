TARGET = rpncalc
MAIN = main.asm
DEP = $(filter-out $(MAIN), $(wildcard *.asm))
MAINOBJ = $(MAIN:.asm=.o)

.PHONY: all
all: $(TARGET)

.PHONY: clean
clean:
	rm -r *.o $(TARGET)

$(TARGET): $(DEP)
	nasm -f elf64 -o $(MAINOBJ) $(MAIN)
	ld -m elf_x86_64 -o $(TARGET) $(MAINOBJ)
