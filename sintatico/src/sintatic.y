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
	program = 0
	,expression
	,expression_1
	,expression_2
	,expression_3
	,assignment
	,number
	,function_declaration
	,type_identifier
	,paramenters
	,statments
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
    char rulesNames[100][100] = {"program"
                        ,"expression"
                        ,"expression_1"
                        ,"expression_2"
                        ,"expression_3"
                        ,"assignment"
                        ,"number"
                    	,"function_declaration"
						,"type_identifier"
						,"paramenters"
						,"statments"};
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
%type <node> expression
%type <node> expression_1
%type <node> expression_2
%type <node> expression_3
%type <node> assignment
%type <node> number
%type <node> function_declaration
%type <node> type_identifier
%type <node> paramenters
%type <node> statments


%start ini

%%

ini:
	program {
		$$ = new_node();
		add_child($$, $1);
		show_tree($$, 1);
	}

program:
	function_declaration {
		$$ = new_node();
		add_child($$, $1);
		$$->type = rulesNames[program];
		show_tree($$, 1);
		$$->op[0] = 0;
	}

function_declaration:
	type_identifier '(' paramenters ')' statments {
		$$ = new_node();
		add_child($$, $1);
		add_child($$, $3);
		add_child($$, $5);
		$$->type = rulesNames[function_declaration];
		$$->op[0] = 0;
	}

paramenters:
	'x' {
		$$ = new_node();
	}

type_identifier:
	'y' {
		$$ = new_node();
	}

statments:
	'z' {
		$$ = new_node();
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
