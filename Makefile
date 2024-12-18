TARGET = rpncalc
SRCS = main.asm
OBJS = $(SRCS:.asm=.o)

.PHONY: all
all: $(TARGET)

.PHONY: clean
clean:
	rm -r *.o $(TARGET)

$(TARGET): $(OBJS)
	ld -m elf_x86_64 -o $(TARGET) $(OBJS)

%.o: %.asm
	nasm -f elf64 -o $@ $<
