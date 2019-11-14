#ifndef SYMBOLS
#define SYMBOLS

#include "misc.h"

typedef struct Symbol Symbol;
typedef struct SymbolList SymbolList;

#define tableSize 1000003

struct Symbol {
	DataType type;
	char name[34];
	int line, function, pos, scope;
	IntStack *parameters;
	Symbol *next;
};

struct SymbolList {
	Symbol *firstSymbol, *lastSymbol;
};

void add_symbol(DataType, char*, int, int, int, int);
void add_parameter(Symbol*, DataType);
void destroy_symbol();
int check_arguments(IntStack*, IntStack*, Symbol*, int);
void show_symbol();
Symbol* find_symbol(char*, int);
Symbol* stack_find(char*, IntStack*);
int erase_symbol(char*, int);

#endif