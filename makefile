exec: printf.out
		./printf.out

printf.out: tester.o printf.o
		gcc -no-pie tester.o printf.o -o printf.out

printf.o: printf.asm
		nasm -f elf64 printf.asm -o printf.o 

tester.o: tester.c
		gcc -c -no-pie -m64 tester.c
