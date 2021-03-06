%define parse.error verbose
%define parse.lac none
%define api.pure
%debug
%defines

%code requires {

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "tree.h"
#include "symbol.h"
#include "misc.h"

typedef enum Rules {
		ini = 0
		,program
		,function_declaration
		,parameters_list
		,parameter
		,type_identifier
		,statments
		,statment
		,readi
		,writi
		,function_call
		,arguments
		,arguments_list
		,conditional
		,else_if
		,loop
		,retrn
		,value
		,array_access
		,variables_declaration
		,identifiers_list
		,expression
		,expression_1
		,expression_2
		,expression_3
		,assignment
		,number
		,function_body
		,parameters
		,function_definition
		,ife
} Rules;

typedef struct Tok Tok;
struct Tok {
	int line, pos;
	char *op;
};


typedef struct IdList IdList;
typedef struct IdItem IdItem;

struct IdItem {
	IdItem *next;
	char *id;
};

struct IdList {
	IdItem *first, *last, *firstOut;
};

extern int yylex();
}

%union {
	int valInt;
	float valFloat;
	Tok tok;
	Node *node;
}

%code {
	IdList idList;
    char rulesNames[32][30] = {
				"Ini"
				,"Program"
				,"Function_declaration"
				,"Parameters_list"
				,"Parameter"
				,"Type_identifier"
				,"Statments"
				,"Statment"
				,"Read"
				,"Write"
				,"Function_call"
				,"Arguments"
				,"Arguments_list"
				,"Conditional"
				,"Else_if"
				,"Loop"
				,"Retrn"
				,"Value"
				,"Array_access"
				,"Variables_declaration"
				,"Identifiers_list"
				,"Expression"
				,"Expression_1"
				,"Expression_2"
				,"Expression_3"
				,"Assignment"
				,"Number"
				,"Function_body"
				,"Parameters"
				,"Function_definition"
				,"If"
    };

    void addIdItem(char *id){
    	IdItem *newItem = (IdItem*) malloc(sizeof(IdItem));
    	newItem->id = id;
    	newItem->next = 0;
    	if(idList.first == 0){
    		idList.first = idList.last = newItem;
    	}
    	else{
    		idList.last->next = newItem;
    		idList.last = newItem;
    	}
    	if(idList.firstOut == 0){
    		idList.firstOut = newItem;
    	}
    }

    IntStack *scopeStack;
    IntStack *argumentStack;

    char funcScope[34];
    DataType lastType;
    Node *root;
}

%token <tok> Integer "integer"
%token <tok> Float "float"
%token <tok> Return "return"
%token <tok> If "if"
%token <tok> Else "else"
%token <tok> While "while"
%token <tok> Write "write"
%token <tok> Read "read"
%token <tok> Type "type"
%token <tok> ArrayType "arrayType"
%token <tok> ArrayOp "arrayOp"
%token <tok> Id "id"
%token <tok> Op1 "op1"
%token <tok> Op2 "op2"
%token <tok> Op3 "op3"
%token <tok> UOp "uop"
%token <tok> '=' "assignment"
%token <tok> '('
%token <tok> ')'
%token <tok> '{'
%token <tok> '}'
%token <tok> '['
%token <tok> ']'
%token <tok> ';'
%token <tok> ','
 
%type <node> ini
%type <node> program
%type <node> function_declaration
%type <node> parameters_list
%type <node> parameter
%type <node> type_identifier
%type <node> statments
%type <node> statment
%type <node> read
%type <node> write
%type <node> function_call
%type <node> arguments
%type <node> arguments_list
%type <node> conditional
%type <node> else_if
%type <node> loop
%type <node> retrn
%type <node> value
%type <node> array_access
%type <node> variables_declaration
%type <node> identifiers_list
%type <node> expression
%type <node> expression_1
%type <node> expression_2
%type <node> expression_3
%type <node> assignment
%type <node> number
%type <node> function_body
%type <node> parameters
%type <node> function_definition
%type <node> if

%start ini

%%

ini:
	program {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[ini];
		root = $$;
	}

program:
	function_definition {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[program];
	}
	| function_definition program {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		add_child($$, $2);
		$$->type = rulesNames[program];
	}
	| variables_declaration program {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		add_child($$, $2);
		$$->type = rulesNames[program];
	}

function_definition:
	function_declaration parameters function_body {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;

		add_child($$, $1);
		add_child($$, $2);
		add_child($$, $3);

		$$->type = rulesNames[function_definition];

		scopeStack = intStackPop(scopeStack);
	}

function_declaration:
	type_identifier Id {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;

		add_child($$, $1);
		add_tchild($$, $2.op, $2.line);
		
		Symbol *onTable = find_symbol($2.op, 0);
		if(onTable){
			sprintf(wError + strlen(wError),"Error line %d: function %s redeclared, first occurrence on line %d\n", $1->line, $2.op, onTable->line);
		}
		else{
			add_symbol(getDtype($1->op), $2.op, $2.line, $2.pos, 1, 0);
		}

		$$->type = rulesNames[function_declaration];

		scopeStack = intStackPush(scopeStack, $2.pos);
		strcpy(funcScope, $2.op);
	}

function_body:
	'{' statments '}'{
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		add_tchild($$, $1.op, $1.line);
		add_child($$, $2);
		add_tchild($$, $3.op, $3.line);
		$$->type = rulesNames[function_body];
	}

parameters:
	'(' parameters_list ')'{
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		add_tchild($$, $1.op, $1.line);
		add_child($$, $2);
		add_tchild($$, $3.op, $3.line);
		$$->type = rulesNames[parameters];
	}
	| '(' ')'{
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		add_tchild($$, $1.op, $1.line);
		add_tchild($$, $2.op, $2.line);
		$$->type = rulesNames[parameters];
	}

parameters_list:
	parameter ',' parameters_list {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		add_tchild($$, $2.op, $2.line);
		add_child($$, $3);
		$$->type = rulesNames[parameters_list];
	}
	| parameter {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[parameters_list];
	}

parameter:
	type_identifier Id {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[parameter];
		
		Symbol *onTable = find_symbol($2.op, scopeStack->val);
		if(onTable){
			sprintf(wError + strlen(wError),"Error line %d: variable %s redeclared, first occurrence on line %d\n", $1->line, $2.op, onTable->line);
		}
		else{
			add_symbol(getDtype($1->op), $2.op, $2.line, $2.pos, 0, scopeStack->val);
			add_parameter(find_symbol(funcScope, 0), getDtype($1->op));
		}
		
		add_tchild($$, $2.op, $2.line);
	}
	| type_identifier Id '[' ']' {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[parameter];
		
		Symbol *onTable = find_symbol($2.op, scopeStack->val);
		if(onTable){
			sprintf(wError + strlen(wError),"Error line %d: variable %s redeclared, first occurrence on line %d\n", $1->line, $2.op, onTable->line);
		}
		else{
			add_symbol(getDtype($1->op), $2.op, $2.line, $2.pos, 0, scopeStack->val);
			add_parameter(find_symbol(funcScope, 0), getDtype($1->op));
		}

		add_tchild($$, $2.op, $2.line);
		add_tchild($$, $3.op, $3.line);
		add_tchild($$, $4.op, $4.line);
	}

type_identifier:
	ArrayOp ArrayType {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		$$->type = rulesNames[type_identifier];
		add_tchild($$, $1.op, $1.line);
		add_tchild($$, $2.op, $2.line);
		char *aux = malloc(sizeof(char) * (strlen($1.op) + strlen($2.op) + 1));
		strcpy(aux, $1.op);
		strcat(aux, $2.op);
		$$->op = aux;
	} |
	Type {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		$$->type = rulesNames[type_identifier];
		add_tchild($$, $1.op, $1.line);
		char *aux = malloc(sizeof(char) * (strlen($1.op) + 1));
		strcpy(aux, $1.op);
		$$->op = aux;
	}

statments:
	statment statments {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		add_child($$, $2);
		$$->type = rulesNames[statments];
	}
	| '{' statments '}' {
		$$ = new_node();
		root = $$;
		$$->line = $2->line;
		add_tchild($$, $1.op, $1.line);
		add_child($$, $2);
		add_tchild($$, $3.op, $3.line);
		$$->type = rulesNames[statments];
	}
	| statment {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[statments];
	}

statment:
	variables_declaration {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[statment];
	} 
	| retrn {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[statment];
	} 
	| conditional {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[statment];
	}
	| loop {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[statment];
	}
	| expression ';' {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		add_tchild($$, $2.op, $2.line);
		$$->type = rulesNames[statment];
	}
	| read {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[statment];
	}
	| write {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[statment];
	}

read:
	Read Id ';' {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		$$->type = rulesNames[readi];
		add_tchild($$, $1.op, $1.line);
		add_tchild($$, $2.op, $2.line);
		add_tchild($$, $3.op, $3.line);
	}

write:
	Write Id ';' {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		$$->type = rulesNames[writi];
		add_tchild($$, $1.op, $1.line);
		add_tchild($$, $2.op, $2.line);
		add_tchild($$, $3.op, $3.line);
	}

function_call:
	Id { argumentStack = intStackPush(argumentStack, -1); } '(' arguments ')'  {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		add_tchild($$, $1.op, $1.line);
		add_tchild($$, $3.op, $3.line);
		add_child($$, $4);
		add_tchild($$, $5.op, $5.line);
		$$->type = rulesNames[function_call];

		Symbol *onTable = find_symbol($1.op, 0);
		if(!onTable){
			sprintf(wError + strlen(wError),"Error line %d: function %s not declared\n", $1.line, $1.op);
			lastType = 20;
		}
		else{
			if(!check_arguments(onTable->parameters, argumentStack, onTable, $1.line)){
				sprintf(wError + strlen(wError),"Error line %d: function %s used with wrong number of arguments\n", $1.line, $1.op);
			}
			lastType = onTable->type;
		}
		argumentStack = popAllIntStackm1(argumentStack);
	}

arguments:
	arguments_list {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[arguments];
	}
	| {
		$$ = new_node();
		root = $$;
		$$->type = rulesNames[arguments];
	}

arguments_list:
	arguments_list ',' value  {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		add_tchild($$, $2.op, $2.line);
		add_child($$, $3);
		$$->type = rulesNames[arguments_list];
		argumentStack = intStackPush(argumentStack, lastType);
	}
	| value {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[arguments_list];

		argumentStack = intStackPush(argumentStack, lastType);
	}

conditional:
	if '{' statments '}' else_if {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		add_tchild($$, $2.op, $2.line);
		add_child($$, $3);
		add_tchild($$, $4.op, $4.line);
		add_child($$, $5);
		$$->type = rulesNames[conditional];
	}
	| if '{' statments '}' {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		add_tchild($$, $2.op, $2.line);
		add_child($$, $3);
		add_tchild($$, $4.op, $4.line);
		$$->type = rulesNames[conditional];
	}

if:
	If '(' expression ')' {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		add_tchild($$, $1.op, $1.line);
		add_tchild($$, $2.op, $2.line);
		add_child($$, $3);
		add_tchild($$, $4.op, $4.line);
		$$->type = rulesNames[ife];
		scopeStack = intStackPush(scopeStack, $1.pos);
	}

else_if:
	Else { scopeStack = intStackPush(scopeStack, $1.pos); } conditional {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		add_tchild($$, $1.op, $1.line);
		add_child($$, $3);
		$$->type = rulesNames[else_if];
	}
	| Else { scopeStack = intStackPush(scopeStack, $1.pos); } '{' statments '}' {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		add_tchild($$, $1.op, $1.line);
		add_tchild($$, $3.op, $3.line);
		add_child($$, $4);
		add_tchild($$, $5.op, $5.line);
		$$->type = rulesNames[else_if];
	}

loop:
	While '(' expression ')' '{' statments '}' {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		add_tchild($$, $1.op, $1.line);
		add_tchild($$, $2.op, $2.line);
		add_child($$, $3);
		add_tchild($$, $4.op, $4.line);
		add_tchild($$, $5.op, $5.line);
		add_child($$, $6);
		add_tchild($$, $7.op, $7.line);
		$$->type = rulesNames[loop];
	}

retrn:
	Return value ';' {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		add_tchild($$, $1.op, $1.line);
		add_child($$, $2);
		add_tchild($$, $3.op, $3.line);
		$$->type = rulesNames[retrn];
	}

value:
	Id {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		$$->type = rulesNames[value];
		add_tchild($$, $1.op, $1.line);

		Symbol *onTable = stack_find($1.op, scopeStack);
		if(!onTable){
			sprintf(wError + strlen(wError),"Error line %d: variable %s used but not declared\n", $1.line, $1.op);
			lastType = 0;
		}
		else{
			lastType = onTable->type;
		}
	}
	| number {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		$$->type = rulesNames[value];
		add_child($$, $1);
	}
	| array_access {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		$$->type = rulesNames[value];
		add_child($$, $1);
	}
	| function_call {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		$$->type = rulesNames[value];
		add_child($$, $1);
	}

array_access:
	Id '[' expression ']'  {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		$$->type = rulesNames[array_access];
		add_tchild($$, $1.op, $1.line);
		add_tchild($$, $2.op, $2.line);
		add_child($$, $3);
		add_tchild($$, $4.op, $4.line);

		Symbol *onTable = stack_find($1.op, scopeStack);
		if(!onTable){
			sprintf(wError + strlen(wError),"Error line %d: variable %s used but not declared\n", $1.line, $1.op);
			lastType = 0;
		}
		else{
			lastType = onTable->type;
		}
	}
	| Id '[' expression ',' expression ']'  {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		$$->type = rulesNames[array_access];
		add_tchild($$, $1.op, $1.line);
		add_tchild($$, $2.op, $2.line);
		add_child($$, $3);
		add_tchild($$, $4.op, $4.line);
		add_child($$, $5);
		add_tchild($$, $6.op, $6.line);
		
		Symbol *onTable = stack_find($1.op, scopeStack);
		if(!onTable){
			sprintf(wError + strlen(wError),"Error line %d: variable %s used but not declared\n", $1.line, $1.op);
			lastType = 0;
		}
		else{
			lastType = onTable->type;
		}
	}

variables_declaration:
	type_identifier identifiers_list ';' {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		add_child($$, $2);
		add_tchild($$, $3.op, $3.line);
		$$->type = rulesNames[variables_declaration];
		DataType dType = getDtype($1->op);
		while(idList.first){
			Symbol *onTable = find_symbol(idList.first->id, scopeStack->val);
			if(onTable){
				sprintf(wError + strlen(wError),"Error line %d: variable %s redeclared, first occurrence on line %d\n", $1->line, idList.first->id, onTable->line);
			}
			else{
				add_symbol(dType, idList.first->id, $1->line, $2->pos, 0, scopeStack->val);
			}
			IdItem *aux = idList.first->next;
			myfree((void**)&idList.first);
			idList.first = aux;
		}
	}

identifiers_list:
	Id ',' identifiers_list {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		add_tchild($$, $1.op, $1.line);
		add_tchild($$, $2.op, $2.line);
		add_child($$, $3);
		$$->type = rulesNames[identifiers_list];
		$$->pos = $1.pos;
		addIdItem($1.op);
	}
	| Id '[' Integer ']' ',' identifiers_list {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		add_tchild($$, $1.op, $1.line);
		add_tchild($$, $2.op, $2.line);
		add_tchild($$, $3.op, $3.line);
		add_tchild($$, $4.op, $4.line);
		add_tchild($$, $5.op, $5.line);
		add_child($$, $6);
		$$->type = rulesNames[identifiers_list];
		$$->pos = $1.pos;
		addIdItem($1.op);
	}
	| Id '[' Integer ']' {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		$$->type = rulesNames[identifiers_list];
		add_tchild($$, $1.op, $1.line);
		add_tchild($$, $2.op, $2.line);
		add_tchild($$, $3.op, $3.line);
		add_tchild($$, $4.op, $4.line);
		$$->pos = $1.pos;
		addIdItem($1.op);
	}
	| Id {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		$$->type = rulesNames[identifiers_list];
		add_tchild($$, $1.op, $1.line);
		$$->pos = $1.pos;
		addIdItem($1.op);
	}

expression: 
	Id assignment expression {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		add_tchild($$, $1.op, $1.line);
		add_child($$, $2);
		add_child($$, $3);
		$$->type = rulesNames[expression];
		
		Symbol *onTable = stack_find($1.op, scopeStack);
		if(!onTable){
			sprintf(wError + strlen(wError),"Error line %d: variable %s used but not declared\n", $1.line, $1.op);
		}
	}
	| array_access assignment expression {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		add_child($$, $2);
		add_child($$, $3);
		$$->type = rulesNames[expression];
	}
	| expression_1 {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[expression];
	}

expression_1:
	expression_2 Op1 expression_1 {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		add_tchild($$, $2.op, $2.line);
		add_child($$, $3);
		$$->type = rulesNames[expression_1];
	}
	| expression_2 {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[expression_1];
	}

expression_2:
	expression_3 Op2 expression_2 {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		add_tchild($$, $2.op, $2.line);
		add_child($$, $3);
		$$->type = rulesNames[expression_2];
	}
	| expression_3 {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[expression_2];
	}

expression_3:
	value Op3 expression_3 {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		add_tchild($$, $2.op, $2.line);
		add_child($$, $3);
		$$->type = rulesNames[expression_3];
	}
	| UOp value {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		add_tchild($$, $1.op, $1.line);
		add_child($$, $2);	
		$$->type = rulesNames[expression_3];
	}
	| UOp '(' expression ')' {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		add_tchild($$, $1.op, $1.line);
		add_tchild($$, $2.op, $2.line);
		add_child($$, $3);	
		add_tchild($$, $4.op, $4.line);
		$$->type = rulesNames[expression_3];
	}
	| value {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);	
		$$->type = rulesNames[expression_3];
	}
	| '(' expression ')' {
		$$ = new_node();
		root = $$;
		$$->line = $2->line;
		add_tchild($$, $1.op, $1.line);
		add_child($$, $2);	
		add_tchild($$, $3.op, $3.line);
		$$->type = rulesNames[expression_3];
	}

assignment:
	'=' {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		add_tchild($$, $1.op, $1.line);
		$$->type = rulesNames[assignment];
	}

number:
	Integer {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		$$->type = rulesNames[number];
		add_tchild($$, $1.op, $1.line);
		lastType = getDtype("int");
	}
	| Float {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		$$->type = rulesNames[number];
		add_tchild($$, $1.op, $1.line);
		lastType = getDtype("float");
	}

%%

int main (void) {
	scopeStack = intStackPush(scopeStack, 0);
	argumentStack = 0;
	idList.first = idList.last = idList.firstOut = 0;
	root = 0;
	yyparse();
	if(root){
		show_tree(root, 1);
		destroy_tree(root);
	}
	show_symbol();
	destroy_symbol();
	popAllIntStack(argumentStack);
	popAllIntStack(scopeStack);

	printf("\n");
	printf("%s\n",wError );
}
