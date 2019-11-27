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

int hasha(char *s, int scope){
	int hash = 0;
	int i = 0;
	while(s[i]){
		hash = (hash * 256) % tableSize + s[i];
		i++;
	}
	hash ^= scope;
	return ((hash % tableSize) + tableSize) % tableSize;
}

void insert(Symbol *newSymbol){
	int id = hasha(newSymbol->name, newSymbol->scope);
	insert_list(newSymbol, id);
}

void add_symbol(DataType type, char name[], int line, int pos, int function, int scope){
	Symbol *newSymbol = (Symbol*) malloc(sizeof(Symbol));
	newSymbol->type = type;
	strcpy(newSymbol->name, name);
	newSymbol->line = line;
	newSymbol->pos = pos;
	newSymbol->function = function;
	newSymbol->next = 0;
	newSymbol->parameters = 0;
	newSymbol->scope = scope;
	insert(newSymbol);
}

Symbol* find_symbol(char *s, int scope){
	int id = hasha(s, scope);
	if(sTable[id] == 0) return 0;
	Symbol *symbol = sTable[id]->firstSymbol;
	while(symbol && (strcmp(symbol->name, s) != 0 || symbol->scope != scope)){
		symbol = symbol->next;
	}
	return symbol;
}

int erase_symbol(char *s, int scope){
	int id = hasha(s, scope);
	if(sTable[id] == 0) return 0;
	Symbol *symbol = sTable[id]->firstSymbol;
	if(strcmp(symbol->name, s) == 0 && symbol->scope == scope){
		sTable[id]->firstSymbol = symbol->next;
		myfree((void**)&symbol);
		return 1;
	}
	while(symbol->next && (strcmp(symbol->next->name, s) != 0 || symbol->next->scope != scope)){
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

void add_parameter(Symbol *function, DataType parameter){
	if(function == 0) return;
	function->parameters = intStackPush(function->parameters, parameter);
}

void show_parameters(IntStack *parameters){
	if(parameters == 0 || parameters->val == -1) return;
	show_parameters(parameters->prev);
	printf("%s ", dTypeName[parameters->val]);
}

void show_symbol(){
	printf("Symbols Table\n\n");
	printf("Pos | Line |      Type       |                 Name              | Is function | Scope | Pamareters\n");
	printf("----------------------------------------------------------------------------------------------\n");
	IntList *id = firstTableId;
	while(id){
		Symbol *aux = sTable[id->val]->firstSymbol;
		while(aux){
			printf("%3d | %4d | %15s | %33s | %11s | %5d |", aux->pos, aux->line, dTypeName[aux->type], aux->name, aux->function ? "Yes" : "No", aux->scope);
			show_parameters(aux->parameters);
			printf("\n");
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
			popAllIntStack(aux->parameters);
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

Symbol* stack_find(char* name, IntStack *scope_stack){
	while(scope_stack){
		Symbol *aux = find_symbol(name, scope_stack->val);
		if(aux){
			return aux;
		}
		scope_stack = scope_stack->prev;
	}
	return 0;
}
