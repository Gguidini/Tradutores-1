#ifndef SYMBOLS
#define SYMBOLS

typedef struct Symbol Symbol;
typedef struct SymbolList SymbolList;

struct Symbol {
	char type[100];
	char name[100];
	int line;
	Symbol *next;
};

struct SymbolList {
	Symbol *firstSymbol, *lastSymbol;
};

void add_symbol(char type[], char name[], int line);
void destroy_symbol();
void show_symbol();

#endif