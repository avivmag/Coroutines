all: gol

gol:	gol.o main.o scheduler.o printer.o
	gcc -g -m32 -Wall -o gol gol.o main.o scheduler.o printer.o

gol.o: gol.asm
	nasm -f elf  gol.asm -o gol.o

scheduler.o: scheduler.asm	
	nasm -f elf  scheduler.asm -o scheduler.o

printer.o: printer.asm	
	nasm -f elf  printer.asm -o printer.o

main.o: main.c
	gcc -m32 -Wall -ansi -c main.c -o main.o


.PHONY: clean

clean: 
	rm -f *.o gol

 
