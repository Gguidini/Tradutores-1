#include <string.h>
#include <stdlib.h>
#include <stdio.h>
#include "symbol.h"

SymbolList *list;

void add_symbol(char type[], char name[], int line, int function){
	if(list == 0){
		list = (SymbolList*) malloc(sizeof(SymbolList));
		list->firstSymbol = 0;
		list->lastSymbol = 0;
	}
	Symbol *newSymbol = (Symbol*) malloc(sizeof(Symbol));
	strcpy(newSymbol->type, type);
	strcpy(newSymbol->name, name);
	newSymbol->line = line;
	newSymbol->function = function;
	newSymbol->next = 0;
	if(list->firstSymbol){
		list->lastSymbol->next = newSymbol;
		list->lastSymbol = newSymbol;
	}
	else{
		list->lastSymbol = newSymbol;	
		list->firstSymbol = newSymbol;	
	}
}

void show_symbol(){
	Symbol *aux = list->firstSymbol;
	printf("Symbols Table\n\n");
	printf("Line |      Type     |                Name               | Is function\n");
	printf("----------------------------------------------------------------------\n");
	while(aux){
		printf("%4d | %13s | %33s | %s\n", aux->line, aux->type, aux->name, aux->function ? "Yes" : "No");
		aux = aux->next;
	}
}

void destroy_symbol(){
	Symbol *aux = list->firstSymbol;
	while(aux){
		Symbol *aux2 = aux->next;
		free(aux);
		aux = aux2;
	}
	free(list);
}