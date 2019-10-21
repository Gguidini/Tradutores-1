all: sintatic

sintatic: sintatic.tab.o lex.yy.o tree.o
	gcc -o sintatic lex.yy.o sintatic.tab.o tree.o

tree.o:
	gcc -c -o tree.o tree.c

lex.yy.o: lex.yy.c sintatic.tab.c
	gcc -c -o lex.yy.o lex.yy.c

lex.yy.c: 
	flex tokens.l

sintatic.tab.o: sintatic.tab.c
	gcc -c -o sintatic.tab.o sintatic.tab.c

sintatic.tab.c:
	bison sintatic.y

clean:
	rm sintatic.tab.* lex.yy.c *.o
