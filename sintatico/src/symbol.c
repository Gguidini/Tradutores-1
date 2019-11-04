#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "symbol.h"
#include "misc.h"

SymbolList *sTable[tableSize];
IntList *firstTableId, *lastTableId;

void insert_list(Symbol *newSymbol, int id){
	if(sTable[id] == 0){
		IntList *newId = (IntList*) malloc(sizeof(IntList));
		newId->next = 0;
		newId->val = id;
		if(firstTableId == 0){
			firstTableId = lastTableId = newId;
		}
		else{
			lastTableId->next = newId;
			lastTableId = newId;
		}
		sTable[id] = (SymbolList*) malloc(sizeof(SymbolList));
		sTable[id]->firstSymbol = newSymbol;
		sTable[id]->lastSymbol = newSymbol;
	}
	else {
		sTable[id]->lastSymbol->next = newSymbol;
		sTable[id]->lastSymbol = newSymbol;
	}
}

int hasha(char *s){
	int hash = 0;
	int i = 0;
	while(s[i]){
		hash = (hash * 256) % tableSize + s[i];
		i++;
	}
	return hash % tableSize;
}

void insert(Symbol *newSymbol){
	int id = hasha(newSymbol->name);
	insert_list(newSymbol, id);
}

void add_symbol(char type[], char name[], int line, int pos, int function, char* preffix){
	Symbol *newSymbol = (Symbol*) malloc(sizeof(Symbol));
	strcpy(newSymbol->type, type);
	newSymbol->name[0] = 0;
	if(preffix[0]){
		strcpy(newSymbol->name, preffix);
		strcat(newSymbol->name, ":");
	}
	strcat(newSymbol->name, name);
	newSymbol->line = line;
	newSymbol->pos = pos;
	newSymbol->function = function;
	newSymbol->next = 0;
	insert(newSymbol);
}

Symbol* find_symbol(char *s){
	int id = hasha(s);
	if(sTable[id] == 0) return 0;
	Symbol *symbol = sTable[id]->firstSymbol;
	while(symbol && strcmp(symbol->name, s) != 0){
		symbol = symbol->next;
	}
	return symbol;
}

int erase_symbol(char *s){
	int id = hasha(s);
	if(sTable[id] == 0) return 0;
	Symbol *symbol = sTable[id]->firstSymbol;
	if(strcmp(symbol->name,s) == 0){
		sTable[id]->firstSymbol = symbol->next;
		myfree((void**)&symbol);
		return 1;
	}
	while(symbol->next && strcmp(symbol->next->name, s) != 0){
		symbol = symbol->next;
	}
	if(!symbol->next){
		return 0;
	}
	Symbol *aux = symbol->next;
	symbol->next = aux->next;
	myfree((void**)&aux);
	return 1;
}

void show_symbol(){
	printf("Symbols Table\n\n");
	printf("Pos | Line |      Type     |                Name               | Is function\n");
	printf("----------------------------------------------------------------------\n");
	IntList *id = firstTableId;
	while(id){
		Symbol *aux = sTable[id->val]->firstSymbol;
		while(aux){
			printf("%3d | %4d | %13s | %33s | %s\n", aux->pos, aux->line, aux->type, aux->name, aux->function ? "Yes" : "No");
			aux = aux->next;
		}
		id = id->next;
	}
}

void destroy_symbol(){
	IntList *id = firstTableId;
	while(id){
		Symbol *aux = sTable[id->val]->firstSymbol;
		while(aux){
			Symbol *aux2 = aux->next;
			myfree((void**)&aux);
			aux = aux2;
		}
		myfree((void**)&sTable[id->val]);
		IntList *nextId = id->next;
		myfree((void**)&id);
		id = nextId;
	}
}