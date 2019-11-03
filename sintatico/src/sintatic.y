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

typedef enum Rules {
		ini = 0
		,program
		,function_declaration
		,paramenters
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
} Rules;

typedef struct Tok Tok;
struct Tok {
	int line;
	char *op;
};


typedef struct IdList IdList;
typedef struct IdItem IdItem;

struct IdItem {
	IdItem *next;
	char *id;
};

struct IdList {
	IdItem *first, *last;
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
    char rulesNames[100][100] = {
				"ini"
				,"program"
				,"function_declaration"
				,"paramenters"
				,"parameters_list"
				,"parameter"
				,"type_identifier"
				,"statments"
				,"statment"
				,"readi"
				,"writi"
				,"function_call"
				,"arguments"
				,"arguments_list"
				,"conditional"
				,"else_if"
				,"loop"
				,"retrn"
				,"value"
				,"array_access"
				,"variables_declaration"
				,"identifiers_list"
				,"expression"
				,"expression_1"
				,"expression_2"
				,"expression_3"
				,"assignment"
				,"number"
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
    }
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
 
%type <node> ini
%type <node> program
%type <node> function_declaration
%type <node> paramenters
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
	type_identifier Id '(' paramenters ')' '{' statments '}' {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);
		add_child($$, $4);
		add_child($$, $7);
		add_symbol($1->op, $2.op, $2.line, 1);
		$$->type = rulesNames[function_declaration];
		free($2.op);
		free($1->op);
	}

paramenters:
	parameters_list {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[paramenters];
	}
	| {
		$$ = new_node();
		$$->type = rulesNames[paramenters];
	}

parameters_list:
	parameter ',' parameters_list {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);
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
		add_symbol($1->op, $2.op, $2.line, 0);
		free($2.op);
		free($1->op);
	}
	| type_identifier Id '[' ']' {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[parameter];
		add_symbol($1->op, $2.op, $2.line, 0);
		free($2.op);
		free($1->op);
	}

type_identifier:
	ArrayOp ArrayType {
		$$ = new_node();
		$$->line = $1.line;
		$$->type = rulesNames[type_identifier];
		free($1.op);
		$$->op = $2.op;
	} |
	Type {
		$$ = new_node();
		$$->line = $1.line;
		$$->type = rulesNames[type_identifier];
		$$->op = $1.op;
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
		add_child($$, $2);
		$$->type = rulesNames[statments];
	}
	|{
		$$ = new_node();
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
		free($1.op);
		free($2.op);
	}

writi:
	Writi Id ';' {
		$$ = new_node();
		$$->line = $1.line;
		$$->type = rulesNames[writi];
		free($1.op);
		free($2.op);
	}

function_call:
	Id '(' arguments ')'  {
		$$ = new_node();
		$$->line = $1.line;
		add_child($$, $3);
		$$->type = rulesNames[function_call];
		free($1.op);
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
		add_child($$, $3);
		add_child($$, $6);
		add_child($$, $8);
		$$->type = rulesNames[conditional];
		free($1.op);
	}

else_if:
	Else conditional {
		$$ = new_node();
		$$->line = $1.line;
		add_child($$, $2);
		$$->type = rulesNames[else_if];
		free($1.op);
	}
	| Else '{' statments '}' {
		$$ = new_node();
		$$->line = $1.line;
		add_child($$, $3);
		$$->type = rulesNames[else_if];
		free($1.op);
	} 
	|{
		$$ = new_node();
		$$->type = rulesNames[statments];
	}

loop:
	While '(' expression ')' '{' statments '}' {
		$$ = new_node();
		$$->line = $1.line;
		add_child($$, $3);
		add_child($$, $6);
		$$->type = rulesNames[loop];
		free($1.op);
	}

retrn:
	Return value ';' {
		$$ = new_node();
		$$->line = $1.line;
		add_child($$, $2);
		$$->type = rulesNames[retrn];
		free($1.op);
	}

value:
	Id {
		$$ = new_node();
		$$->line = $1.line;
		$$->type = rulesNames[value];
		free($1.op);
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
		add_child($$, $3);
		free($1.op);
	}
	| Id '[' expression ',' expression ']'  {
		$$ = new_node();
		$$->line = $1.line;
		$$->type = rulesNames[array_access];
		add_child($$, $3);
		add_child($$, $5);
		free($1.op);
	}

variables_declaration:
	type_identifier identifiers_list ';' {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);
		add_child($$, $2);
		$$->type = rulesNames[variables_declaration];
		while(idList.first){
			IdItem *aux = idList.first->next;
			add_symbol($1->op, idList.first->id, $1->line, 0);
			free(idList.first->id);
			free(idList.first);
			idList.first = aux;
		}
		free($1->op);
	}

identifiers_list:
	Id ',' identifiers_list {
		$$ = new_node();
		$$->line = $1.line;
		add_child($$, $3);
		$$->type = rulesNames[identifiers_list];
		addIdItem($1.op);
	}
	| Id '[' Integer ']' ',' identifiers_list {
		$$ = new_node();
		$$->line = $1.line;
		add_child($$, $6);
		$$->type = rulesNames[identifiers_list];
		free($3.op);
		addIdItem($1.op);
	}
	| Id '[' Integer ']' {
		$$ = new_node();
		$$->line = $1.line;
		$$->type = rulesNames[identifiers_list];
		free($3.op);
		addIdItem($1.op);
	}
	| Id {
		$$ = new_node();
		$$->line = $1.line;
		$$->type = rulesNames[identifiers_list];
		addIdItem($1.op);
	}

expression: 
	Id assignment expression {
		$$ = new_node();
		$$->line = $1.line;
		add_child($$, $2);
		add_child($$, $3);
		$$->type = rulesNames[expression];
		free($1.op);
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
		add_child($$, $3);
		$$->type = rulesNames[expression_1];
		free($2.op);
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
		add_child($$, $3);
		$$->type = rulesNames[expression_2];
		free($2.op);
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
		add_child($$, $3);
		$$->type = rulesNames[expression_3];
		free($2.op);
	}
	| UOp value {
		$$ = new_node();
		$$->line = $1.line;
		add_child($$, $2);	
		$$->type = rulesNames[expression_3];
		free($1.op);
	}
	| UOp '(' expression ')' {
		$$ = new_node();
		$$->line = $1.line;
		add_child($$, $3);	
		$$->type = rulesNames[expression_3];
		free($1.op);
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
		add_child($$, $2);	
		$$->type = rulesNames[expression_3];
	}

assignment:
	'=' {
		$$ = new_node();
		free($1.op);
		$$->type = rulesNames[assignment];
	}

number:
	Integer {
		$$ = new_node();
		$$->line = $1.line;
		$$->type = rulesNames[number];
		free($1.op);
	}
	| Float {
		$$ = new_node();
		$$->line = $1.line;
		$$->type = rulesNames[number];
		free($1.op);
	}

%%

int main (void) {
	idList.first = idList.last = 0;
	return yyparse();
}
