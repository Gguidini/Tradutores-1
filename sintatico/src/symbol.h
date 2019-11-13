#ifndef SYMBOLS
#define SYMBOLS

#include "misc.h"

typedef struct Symbol Symbol;
typedef struct SymbolList SymbolList;

#define tableSize 1000003

struct Symbol {
	char type[20];
	char name[34];
	int line, function, pos, scope;
	StringList *firstParameter, *lastParameter;
	Symbol *next;
};

struct SymbolList {
	Symbol *firstSymbol, *lastSymbol;
};

void add_symbol(char*, char*, int, int, int, int);
void add_parameter(Symbol*, char*);
void destroy_symbol();
void show_symbol();
Symbol* find_symbol(char*, int);
Symbol* stack_find(char*, IntStack*);
int erase_symbol(char*, int);

#endif