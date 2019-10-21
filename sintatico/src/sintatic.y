%define parse.error verbose
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
	char *op;;
};

}


%union {
	int valInt;
	float valFloat;
	Tok tok;
	Node *node;
}

%code provides {
	extern char rulesNames[100][100];
}

%code {
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
		add_symbol($1->op, $2.op, $2.line);
		$$->type = rulesNames[function_declaration];
		strcpy($$->op, $2.op);
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
		strcpy($$->op, $2.op);
		add_symbol($1->op, $2.op, $2.line);
	}
	| type_identifier Id '[' ']' {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[parameter];
		strcpy($$->op, $2.op);
		add_symbol($1->op, $2.op, $2.line);
	}

type_identifier:
	ArrayOp ArrayType {
		$$ = new_node();
		$$->line = $1.line;
		$$->type = rulesNames[type_identifier];
		strcpy($$->op, $1.op);
		strcat($$->op, $2.op);
	} |
	Type {
		$$ = new_node();
		$$->line = $1.line;
		$$->type = rulesNames[type_identifier];
		strcpy($$->op, $1.op);
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
		strcat($$->op, "{}");
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
	| function_call ';' {
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
		strcpy($$->op, $1.op);
		strcpy($$->op, " ");
		strcat($$->op, $2.op);
		add_symbol("", $2.op, $2.line);
	}


writi:
	Writi Id ';' {
		$$ = new_node();
		$$->line = $1.line;
		$$->type = rulesNames[writi];
		strcpy($$->op, $1.op);
		strcpy($$->op, " ");
		strcat($$->op, $2.op);
		add_symbol("", $2.op, $2.line);
	}

function_call:
	Id '(' arguments ')'  {
		$$ = new_node();
		$$->line = $1.line;
		add_child($$, $3);
		$$->type = rulesNames[function_call];
		strcpy($$->op, $1.op);
		add_symbol("", $1.op, $1.line);
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
		strcpy($$->op, $1.op);
	}

else_if:
	Else conditional {
		$$ = new_node();
		$$->line = $1.line;
		add_child($$, $2);
		$$->type = rulesNames[else_if];
		strcpy($$->op, $1.op);
		strcat($$->op, " if");
	}
	| Else '{' statments '}' {
		$$ = new_node();
		$$->line = $1.line;
		add_child($$, $3);
		$$->type = rulesNames[else_if];
		strcpy($$->op, $1.op);
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
		strcpy($$->op, $1.op);
	}

retrn:
	Return value ';' {
		$$ = new_node();
		$$->line = $1.line;
		add_child($$, $2);
		$$->type = rulesNames[retrn];
	}

value:
	Id {
		$$ = new_node();
		$$->line = $1.line;
		$$->type = rulesNames[value];
		strcpy($$->op, $1.op);
		add_symbol("", $1.op, $1.line);
	}
	| number {
		$$ = new_node();
		$$->line = $1->line;
		$$->type = rulesNames[value];
		add_child($$, $1);
		strcpy($$->op, $1->op);
	}
	| array_access {
		$$ = new_node();
		$$->line = $1->line;
		$$->type = rulesNames[value];
		add_child($$, $1);
		strcpy($$->op, $1->op);
	}
	| function_call {
		$$ = new_node();
		$$->line = $1->line;
		$$->type = rulesNames[value];
		add_child($$, $1);
		strcpy($$->op, $1->op);
	}

array_access:
	Id '[' expression ']'  {
		$$ = new_node();
		$$->line = $1.line;
		$$->type = rulesNames[array_access];
		add_child($$, $3);
		strcpy($$->op, $1.op);
		strcat($$->op, "[");
		strcat($$->op, $3->op);
		strcat($$->op, "]");
		add_symbol("", $1.op, $1.line);
	}
	| Id '[' expression ',' expression ']'  {
		$$ = new_node();
		$$->line = $1.line;
		$$->type = rulesNames[array_access];
		add_child($$, $3);
		add_child($$, $5);
		strcpy($$->op, $1.op);
		strcat($$->op, "[");
		strcat($$->op, $3->op);
		strcat($$->op, ",");
		strcat($$->op, $5->op);
		strcat($$->op, "]");
		add_symbol("", $1.op, $1.line);
	}

variables_declaration:
	type_identifier identifiers_list ';' {
		$$ = new_node();
		$$->line = $1->line;
		add_child($$, $1);
		add_child($$, $2);
		$$->type = rulesNames[variables_declaration];
		add_symbol($1->op, $2->op, $1->line);
	}

identifiers_list:
	Id ',' identifiers_list {
		$$ = new_node();
		$$->line = $1.line;
		add_child($$, $3);
		$$->type = rulesNames[identifiers_list];
		strcpy($$->op, $1.op);
	}
	| Id '[' Integer ']' ',' identifiers_list {
		$$ = new_node();
		$$->line = $1.line;
		add_child($$, $6);
		$$->type = rulesNames[identifiers_list];
		strcpy($$->op, $1.op);
	}
	| Id '[' Integer ']' {
		$$ = new_node();
		$$->line = $1.line;
		$$->type = rulesNames[identifiers_list];
		strcpy($$->op, $1.op);
	}
	| Id {
		$$ = new_node();
		$$->line = $1.line;
		$$->type = rulesNames[identifiers_list];
		strcpy($$->op, $1.op);
	}


expression: 
	Id assignment expression {
		$$ = new_node();
		$$->line = $1.line;
		add_child($$, $2);
		add_child($$, $3);
		$$->type = rulesNames[expression];
		strcpy($$->op, $1.op);
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
		strcpy($$->op, $2.op);
		add_child($$, $1);
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
		strcpy($$->op, $2.op);
		add_child($$, $1);
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
		strcpy($$->op, $2.op);
		add_child($$, $1);
		add_child($$, $3);
		$$->type = rulesNames[expression_3];
	}
	| UOp value {
		$$ = new_node();
		$$->line = $1.line;
		add_child($$, $2);	
		$$->type = rulesNames[expression_3];
		strcpy($$->op, $1.op);	
	}
	| UOp '(' expression ')' {
		$$ = new_node();
		$$->line = $1.line;
		add_child($$, $3);	
		$$->type = rulesNames[expression_3];
		strcpy($$->op, $1.op);	
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
		$$->op[0] = '=';
		$$->op[1] = 0;
		$$->type = rulesNames[assignment];
	}
	| UOp '=' {
		$$ = new_node();
		$$->line = $1.line;
		strcpy($$->op, $1.op);
		$$->op[1] = '=';
		$$->op[2] = 0;
		$$->type = rulesNames[assignment];
	}
	| Op2 '=' {
		$$ = new_node();
		$$->line = $1.line;
		strcpy($$->op, $1.op);
		$$->op[1] = '=';
		$$->op[2] = 0;
		$$->type = rulesNames[assignment];
	}
	| Op3 '=' {
		$$ = new_node();
		$$->line = $1.line;
		strcpy($$->op, $1.op);
		$$->op[1] = '=';
		$$->op[2] = 0;
		$$->type = rulesNames[assignment];
	}

number:
	Integer {
		$$ = new_node();
		$$->line = $1.line;
		strcpy($$->op, $1.op);
		$$->type = rulesNames[number];
	}
	| Float {
		$$ = new_node();
		$$->line = $1.line;
		strcpy($$->op, $1.op);
		$$->type = rulesNames[number];
	}

%%

int main (void) {
	return yyparse();
}
