all: sintatic

sintatic: sintatic.tab.o lex.yy.o tree.o symbol.o
	gcc -o sintatic lex.yy.o sintatic.tab.o tree.o symbol.o

tree.o:
	gcc -c -o tree.o tree.c

symbol.o:
	gcc -c -o symbol.o symbol.c

lex.yy.o: lex.yy.c sintatic.tab.c
	gcc -c -o lex.yy.o lex.yy.c

lex.yy.c: 
	flex tokens.l

sintatic.tab.o: sintatic.tab.c
	gcc -c -o sintatic.tab.o sintatic.tab.c

sintatic.tab.c:
	bison sintatic.y --report=all

clean:
	rm sintatic.tab.c sintatic.tab.h lex.yy.c *.o sintatic
