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
%token <op> Keyword "keyword"
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
	type_identifier '(' paramenters ')' statments {
		$$ = new_node();
		add_child($$, $1);
		add_child($$, $3);
		add_child($$, $5);
		$$->type = rulesNames[function_declaration];
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
	{
		$$ = new_node();
		$$->type = rulesNames[statments];
	}

expression: 
	Id assignment expression {
		$$ = new_node();
		add_child($$, $2);
		add_child($$, $3);
		$$->type = rulesNames[expression];
		strcpy($$->op, $1);
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
	number Op3 expression_3 {
		$$ = new_node();
		strcpy($$->op, $2);
		add_child($$, $1);
		add_child($$, $3);
		$$->type = rulesNames[expression_3];
	}
	| number {
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
