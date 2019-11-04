#ifndef SYMBOLS
#define SYMBOLS

#include "misc.h"

typedef struct Symbol Symbol;
typedef struct SymbolList SymbolList;

#define tableSize 100005

struct Symbol {
	char type[20];
	char name[70];
	int line, function, pos;
	StringList *firstParameter, *lastParameter;
	Symbol *next;
};

struct SymbolList {
	Symbol *firstSymbol, *lastSymbol;
};

void add_symbol(char*, char*, int, int, int, char*);
void add_parameter(Symbol*, char*);
void destroy_symbol();
void show_symbol();
Symbol* find_symbol(char*, char*);
int erase_symbol(char*, char*);

#endif