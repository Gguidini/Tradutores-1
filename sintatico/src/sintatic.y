%define parse.error verbose
%define api.pure
%debug
%defines

%code requires {

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "tree.h"

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
}


%union {
	int valInt;
	float valFloat;
	char* op;
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

%token <op> Integer "integer"
%token <op> Float "float"
%token <op> Return "return"
%token <op> If "if"
%token <op> Else "else"
%token <op> While "while"
%token <op> Write "write"
%token <op> Read "read"
%token <op> Type "type"
%token <op> ArrayType "arrayType"
%token <op> ArrayOp "arrayOp"
%token <op> Id "id"
%token <op> Op1 "op1"
%token <op> Op2 "op2"
%token <op> Op3 "op3"
%token <op> UOp "uop"
 
%type <node> ini
%type <node> program
%type <node> function_declaration
%type <node> paramenters
%type <node> parameters_list
%type <node> parameter
%type <node> type_identifier
%type <node> statments
%type <node> statment
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
		add_child($$, $1);
		$$->type = rulesNames[ini];
		show_tree($$, 1);
	}

program:
	function_declaration {
		$$ = new_node();
		add_child($$, $1);
		$$->type = rulesNames[program];
	}

function_declaration:
	type_identifier Id '(' paramenters ')' '{' statments '}' {
		$$ = new_node();
		add_child($$, $1);
		add_child($$, $4);
		add_child($$, $7);
		$$->type = rulesNames[function_declaration];
		strcpy($$->op, $2);
	}

paramenters:
	parameters_list {
		$$ = new_node();
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
		add_child($$, $1);
		add_child($$, $3);
		$$->type = rulesNames[parameters_list];
	}
	| parameter {
		$$ = new_node();
		add_child($$, $1);
		$$->type = rulesNames[parameters_list];
	}

parameter:
	type_identifier Id {
		$$ = new_node();
		add_child($$, $1);
		$$->type = rulesNames[parameter];
		strcpy($$->op, $2);
	}
	| type_identifier Id '[' ']' {
		$$ = new_node();
		add_child($$, $1);
		$$->type = rulesNames[parameter];
		strcpy($$->op, $2);
	}

type_identifier:
	ArrayOp ArrayType {
		$$ = new_node();
		$$->type = rulesNames[type_identifier];
		strcpy($$->op, $1);
		strcat($$->op, $2);
	} |
	Type {
		$$ = new_node();
		$$->type = rulesNames[type_identifier];
		strcpy($$->op, $1);
	}

statments:
	statment statments {
		$$ = new_node();
		add_child($$, $1);
		add_child($$, $2);
		$$->type = rulesNames[statments];
	}
	| '{' statments '}' {
		$$ = new_node();
		add_child($$, $2);
		$$->type = rulesNames[statments];
		strcat($$->op, "{}");
	}
	|{
		$$ = new_node();
		$$->type = rulesNames[statments];
	}

statment:
	variables_declaration 
	| retrn 
	| conditional
	| loop
	| expression ';'

conditional:
	If '(' expression ')' '{' statments '}' else_if {
		$$ = new_node();
		add_child($$, $3);
		add_child($$, $6);
		add_child($$, $8);
		$$->type = rulesNames[conditional];
		strcpy($$->op, $1);
	}

else_if:
	Else conditional {
		$$ = new_node();
		add_child($$, $2);
		$$->type = rulesNames[else_if];
		strcpy($$->op, $1);
		strcat($$->op, " if");
	}
	| Else '{' statments '}' {
		$$ = new_node();
		add_child($$, $3);
		$$->type = rulesNames[else_if];
		strcpy($$->op, $1);
	} 
	|{
		$$ = new_node();
		$$->type = rulesNames[statments];
	}

loop:
	While '(' expression ')' '{' statments '}' {
		$$ = new_node();
		add_child($$, $3);
		add_child($$, $6);
		$$->type = rulesNames[loop];
		strcpy($$->op, $1);
	}

retrn:
	Return value ';' {
		$$ = new_node();
		add_child($$, $2);
		$$->type = rulesNames[retrn];
	}

value:
	Id {
		$$ = new_node();
		$$->type = rulesNames[value];
		strcpy($$->op, $1);
	}
	| number {
		$$ = new_node();
		$$->type = rulesNames[value];
		add_child($$, $1);
		strcpy($$->op, $1->op);
	}
	| array_access {
		$$ = new_node();
		$$->type = rulesNames[value];
		add_child($$, $1);
		strcpy($$->op, $1->op);
	}

array_access:
	Id '[' value ']'  {
		$$ = new_node();
		$$->type = rulesNames[array_access];
		add_child($$, $3);
		strcpy($$->op, $1);
		strcat($$->op, "[");
		strcat($$->op, $3->op);
		strcat($$->op, "]");
	}
	| Id '[' value ',' value ']'  {
		$$ = new_node();
		$$->type = rulesNames[array_access];
		add_child($$, $3);
		add_child($$, $5);
		strcpy($$->op, $1);
		strcat($$->op, "[");
		strcat($$->op, $3->op);
		strcat($$->op, ",");
		strcat($$->op, $5->op);
		strcat($$->op, "]");
	}

variables_declaration:
	type_identifier identifiers_list ';' {
		$$ = new_node();
		add_child($$, $1);
		add_child($$, $2);
		$$->type = rulesNames[variables_declaration];
	}

identifiers_list:
	Id ',' identifiers_list {
		$$ = new_node();
		add_child($$, $3);
		$$->type = rulesNames[identifiers_list];
		strcpy($$->op, $1);
		strcat($$->op, ",");
	}
	| Id '[' Integer ']' ',' identifiers_list {
		$$ = new_node();
		add_child($$, $6);
		$$->type = rulesNames[identifiers_list];
		strcpy($$->op, $1);
		strcat($$->op, "[");
		strcat($$->op, $3);
		strcat($$->op, "],");
	}
	| Id '[' Integer ']' {
		$$ = new_node();
		$$->type = rulesNames[identifiers_list];
		strcpy($$->op, $1);
		strcat($$->op, "[");
		strcat($$->op, $3);
		strcat($$->op, "]");
	}
	| Id {
		$$ = new_node();
		$$->type = rulesNames[identifiers_list];
		strcpy($$->op, $1);
	}


expression: 
	Id assignment expression {
		$$ = new_node();
		add_child($$, $2);
		add_child($$, $3);
		$$->type = rulesNames[expression];
		strcpy($$->op, $1);
	}
	| array_access assignment expression {
		$$ = new_node();
		add_child($$, $1);
		add_child($$, $2);
		add_child($$, $3);
		$$->type = rulesNames[expression];
	}
	| expression_1 {
		$$ = new_node();
		add_child($$, $1);
		$$->type = rulesNames[expression];
	}

expression_1:
	expression_2 Op1 expression_1 {
		$$ = new_node();
		strcpy($$->op, $2);
		add_child($$, $1);
		add_child($$, $3);
		$$->type = rulesNames[expression_1];
	}
	| expression_2 {
		$$ = new_node();
		add_child($$, $1);
		$$->type = rulesNames[expression_1];
	}

expression_2:
	expression_3 Op2 expression_2 {
		$$ = new_node();
		strcpy($$->op, $2);
		add_child($$, $1);
		add_child($$, $3);
		$$->type = rulesNames[expression_2];
	}
	| expression_3 {
		$$ = new_node();
		add_child($$, $1);
		$$->type = rulesNames[expression_2];
	}

expression_3:
	value Op3 expression_3 {
		$$ = new_node();
		strcpy($$->op, $2);
		add_child($$, $1);
		add_child($$, $3);
		$$->type = rulesNames[expression_3];
	}
	| value {
		$$ = new_node();
		add_child($$, $1);	
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
		strcpy($$->op, $1);
		$$->op[1] = '=';
		$$->op[2] = 0;
		$$->type = rulesNames[assignment];
	}
	| Op2 '=' {
		$$ = new_node();
		strcpy($$->op, $1);
		$$->op[1] = '=';
		$$->op[2] = 0;
		$$->type = rulesNames[assignment];
	}
	| Op3 '=' {
		$$ = new_node();
		strcpy($$->op, $1);
		$$->op[1] = '=';
		$$->op[2] = 0;
		$$->type = rulesNames[assignment];
	}

number:
	Integer {
		$$ = new_node();
		strcpy($$->op, $1);
		$$->type = rulesNames[number];
	}
	| Float {
		$$ = new_node();
		strcpy($$->op, $1);
		$$->type = rulesNames[number];
	}

%%

int main (void) {
	return yyparse();
}
