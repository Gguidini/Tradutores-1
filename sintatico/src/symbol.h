#ifndef SYMBOLS
#define SYMBOLS

typedef struct Symbol Symbol;
typedef struct SymbolList SymbolList;

#define tableSize 100005

struct Symbol {
	char type[100];
	char name[100];
	int line, function, pos;
	Symbol *next;
};

struct SymbolList {
	Symbol *firstSymbol, *lastSymbol;
};

void add_symbol(char*, char*, int, int, int);
void destroy_symbol();
void show_symbol();
Symbol* find_symbol(char*);

#endif