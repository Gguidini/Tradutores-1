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
    char rulesNames[30][30] = {
				"Ini"
				,"Program"
				,"Function_declaration"
				,"Parameters_list"
				,"Parameter"
				,"Type_identifier"
				,"Statments"
				,"Statment"
				,"Readi"
				,"Writi"
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

    int pos;

    char funcScope[34];
}

%token <tok> Integer "integer"
%token <tok> Float "float"
%token <tok> Return "return"
%token <tok> If "if"
%token <tok> Else "else"
%token <tok> While "while"
%token <tok> Writi "writi"
%token <tok> Readi "readi"
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
%type <node> readi
%type <node> writi
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

%start ini

%%

ini:
	program {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[ini];
		show_tree($$, 1);
		destroy_tree($$);
		show_symbol();
		destroy_symbol();
	}

program:
	function_declaration {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[program];
	}
	| function_declaration program {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);
		add_child($$, $2);
		$$->type = rulesNames[program];
	}
	| variables_declaration program {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);
		add_child($$, $2);
		$$->type = rulesNames[program];
	}

function_declaration:
	function_definition parameters function_body {
		$$ = new_node();
		$$->line = $1->line;

		add_child($$, $1);
		add_child($$, $2);
		add_child($$, $3);

		$$->type = rulesNames[function_declaration];

		strcpy(funcScope, "1Global");
	}

function_definition:
	type_identifier Id {
		$$ = new_node();
		$$->line = $1->line;

		add_child($$, $1);
		add_tchild($$, $2.op, $2.line);
		strcpy(funcScope, $2.op);
		add_symbol($1->op, $2.op, $1->line, $2.pos, 1, "");

		$$->type = rulesNames[function_definition];
	}

function_body:
	'{' statments '}'{
		$$ = new_node();
		$$->line = $1.line;
		add_tchild($$, $1.op, $1.line);
		add_child($$, $2);
		add_tchild($$, $3.op, $3.line);
		$$->type = rulesNames[function_body];
	}

parameters:
	'(' parameters_list ')'{
		$$ = new_node();
		$$->line = $1.line;
		add_tchild($$, $1.op, $1.line);
		add_child($$, $2);
		add_tchild($$, $3.op, $3.line);
		$$->type = rulesNames[parameters];
	}
	| '(' ')'{
		$$ = new_node();
		$$->line = $1.line;
		add_tchild($$, $1.op, $1.line);
		add_tchild($$, $2.op, $2.line);
		$$->type = rulesNames[parameters];	
	}

parameters_list:
	parameter ',' parameters_list {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);
		add_tchild($$, $2.op, $2.line);
		add_child($$, $3);
		$$->type = rulesNames[parameters_list];
	}
	| parameter {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[parameters_list];
	}

parameter:
	type_identifier Id {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[parameter];
		add_symbol($1->op, $2.op, $2.line, $2.pos, 0, funcScope);
		add_tchild($$, $2.op, $2.line);
	}
	| type_identifier Id '[' ']' {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[parameter];
		add_symbol($1->op, $2.op, $2.line, $2.pos, 0, funcScope);
		add_tchild($$, $2.op, $2.line);
		add_tchild($$, $3.op, $3.line);
		add_tchild($$, $4.op, $4.line);
	}

type_identifier:
	ArrayOp ArrayType {
		$$ = new_node();
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
		$$->line = $1->line;
		add_child($$, $1);
		add_child($$, $2);
		$$->type = rulesNames[statments];
	}
	| '{' statments '}' {
		$$ = new_node();
		$$->line = $2->line;
		add_tchild($$, $1.op, $1.line);
		add_child($$, $2);
		add_tchild($$, $3.op, $3.line);
		$$->type = rulesNames[statments];
	}
	| statment {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[statments];
	}

statment:
	variables_declaration {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[statment];
	} 
	| retrn {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[statment];
	} 
	| conditional {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[statment];
	}
	| loop {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[statment];
	}
	| expression ';' {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);
		add_tchild($$, $2.op, $2.line);
		$$->type = rulesNames[statment];
	}
	| readi {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[statment];
	}
	| writi {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[statment];
	}

readi:
	Readi Id ';' {
		$$ = new_node();
		$$->line = $1.line;
		$$->type = rulesNames[readi];
		add_tchild($$, $1.op, $1.line);
		add_tchild($$, $2.op, $2.line);
		add_tchild($$, $3.op, $3.line);
	}

writi:
	Writi Id ';' {
		$$ = new_node();
		$$->line = $1.line;
		$$->type = rulesNames[writi];
		add_tchild($$, $1.op, $1.line);
		add_tchild($$, $2.op, $2.line);
		add_tchild($$, $3.op, $3.line);
	}

function_call:
	Id '(' arguments ')'  {
		$$ = new_node();
		$$->line = $1.line;
		add_tchild($$, $1.op, $1.line);
		add_tchild($$, $2.op, $2.line);
		add_child($$, $3);
		add_tchild($$, $4.op, $4.line);
		$$->type = rulesNames[function_call];
	}

arguments:
	arguments_list  {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[arguments];
	}
	| {
		$$ = new_node();
		$$->type = rulesNames[arguments];
	}

arguments_list:
	value ',' arguments_list  {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);
		add_tchild($$, $2.op, $2.line);
		add_child($$, $3);
		$$->type = rulesNames[arguments_list];
	}
	| value {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[arguments_list];
	}

conditional:
	If '(' expression ')' '{' statments '}' else_if {
		$$ = new_node();
		$$->line = $1.line;
		add_tchild($$, $1.op, $1.line);
		add_tchild($$, $2.op, $2.line);
		add_child($$, $3);
		add_tchild($$, $4.op, $4.line);
		add_tchild($$, $5.op, $5.line);
		add_child($$, $6);
		add_tchild($$, $7.op, $7.line);
		add_child($$, $8);
		$$->type = rulesNames[conditional];
	}
	| If '(' expression ')' '{' statments '}' {
		$$ = new_node();
		$$->line = $1.line;
		add_tchild($$, $1.op, $1.line);
		add_tchild($$, $2.op, $2.line);
		add_child($$, $3);
		add_tchild($$, $4.op, $4.line);
		add_tchild($$, $5.op, $5.line);
		add_child($$, $6);
		add_tchild($$, $7.op, $7.line);
		$$->type = rulesNames[conditional];
	}

else_if:
	Else conditional {
		$$ = new_node();
		$$->line = $1.line;
		add_tchild($$, $1.op, $1.line);
		add_child($$, $2);
		$$->type = rulesNames[else_if];
	}
	| Else '{' statments '}' {
		$$ = new_node();
		$$->line = $1.line;
		add_tchild($$, $1.op, $1.line);
		add_tchild($$, $2.op, $2.line);
		add_child($$, $3);
		add_tchild($$, $4.op, $4.line);
		$$->type = rulesNames[else_if];
	} 

loop:
	While '(' expression ')' '{' statments '}' {
		$$ = new_node();
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
		$$->line = $1.line;
		add_tchild($$, $1.op, $1.line);
		add_child($$, $2);
		add_tchild($$, $3.op, $3.line);
		$$->type = rulesNames[retrn];
	}

value:
	Id {
		$$ = new_node();
		$$->line = $1.line;
		$$->type = rulesNames[value];
		add_tchild($$, $1.op, $1.line);
	}
	| number {
		$$ = new_node();
		$$->line = $1->line;
		$$->type = rulesNames[value];
		add_child($$, $1);
	}
	| array_access {
		$$ = new_node();
		$$->line = $1->line;
		$$->type = rulesNames[value];
		add_child($$, $1);
	}
	| function_call {
		$$ = new_node();
		$$->line = $1->line;
		$$->type = rulesNames[value];
		add_child($$, $1);
	}

array_access:
	Id '[' expression ']'  {
		$$ = new_node();
		$$->line = $1.line;
		$$->type = rulesNames[array_access];
		add_tchild($$, $1.op, $1.line);
		add_tchild($$, $2.op, $2.line);
		add_child($$, $3);
		add_tchild($$, $4.op, $4.line);
	}
	| Id '[' expression ',' expression ']'  {
		$$ = new_node();
		$$->line = $1.line;
		$$->type = rulesNames[array_access];
		add_tchild($$, $1.op, $1.line);
		add_tchild($$, $2.op, $2.line);
		add_child($$, $3);
		add_tchild($$, $4.op, $4.line);
		add_child($$, $5);
		add_tchild($$, $6.op, $6.line);
	}

variables_declaration:
	type_identifier identifiers_list ';' {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);
		add_child($$, $2);
		add_tchild($$, $3.op, $3.line);
		$$->type = rulesNames[variables_declaration];
		while(idList.first){
			add_symbol($1->op, idList.first->id, $1->line, $2->pos, 0, funcScope);
			IdItem *aux = idList.first->next;
			myfree((void**)&idList.first);
			idList.first = aux;
		}
	}

identifiers_list:
	Id ',' identifiers_list {
		$$ = new_node();
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
		$$->line = $1.line;
		$$->type = rulesNames[identifiers_list];
		add_tchild($$, $1.op, $1.line);
		$$->pos = $1.pos;
		addIdItem($1.op);
	}

expression: 
	Id assignment expression {
		$$ = new_node();
		$$->line = $1.line;
		add_tchild($$, $1.op, $1.line);
		add_child($$, $2);
		add_child($$, $3);
		$$->type = rulesNames[expression];
	}
	| array_access assignment expression {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);
		add_child($$, $2);
		add_child($$, $3);
		$$->type = rulesNames[expression];
	}
	| expression_1 {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[expression];
	}

expression_1:
	expression_2 Op1 expression_1 {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);
		add_tchild($$, $2.op, $2.line);
		add_child($$, $3);
		$$->type = rulesNames[expression_1];
	}
	| expression_2 {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[expression_1];
	}

expression_2:
	expression_3 Op2 expression_2 {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);
		add_tchild($$, $2.op, $2.line);
		add_child($$, $3);
		$$->type = rulesNames[expression_2];
	}
	| expression_3 {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[expression_2];
	}

expression_3:
	value Op3 expression_3 {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);
		add_tchild($$, $2.op, $2.line);
		add_child($$, $3);
		$$->type = rulesNames[expression_3];
	}
	| UOp value {
		$$ = new_node();
		$$->line = $1.line;
		add_tchild($$, $1.op, $1.line);
		add_child($$, $2);	
		$$->type = rulesNames[expression_3];
	}
	| UOp '(' expression ')' {
		$$ = new_node();
		$$->line = $1.line;
		add_tchild($$, $1.op, $1.line);
		add_tchild($$, $2.op, $2.line);
		add_child($$, $3);	
		add_tchild($$, $4.op, $4.line);
		$$->type = rulesNames[expression_3];
	}
	| value {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);	
		$$->type = rulesNames[expression_3];
	}
	| '(' expression ')' {
		$$ = new_node();
		$$->line = $2->line;
		add_tchild($$, $1.op, $1.line);
		add_child($$, $2);	
		add_tchild($$, $3.op, $3.line);
		$$->type = rulesNames[expression_3];
	}

assignment:
	'=' {
		$$ = new_node();
		$$->line = $1.line;
		add_tchild($$, $1.op, $1.line);
		$$->type = rulesNames[assignment];
	}

number:
	Integer {
		$$ = new_node();
		$$->line = $1.line;
		$$->type = rulesNames[number];
		add_tchild($$, $1.op, $1.line);
	}
	| Float {
		$$ = new_node();
		$$->line = $1.line;
		$$->type = rulesNames[number];
		add_tchild($$, $1.op, $1.line);
	}

%%

int main (void) {
	strcpy(funcScope, "1Global");
	idList.first = idList.last = idList.firstOut = 0;
	pos = 0;
	return yyparse();
}
