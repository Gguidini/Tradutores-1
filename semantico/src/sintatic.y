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
		,to_int
		,to_float
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
	Node *id;
};

struct IdList {
	IdItem *first, *last, *firstOut;
};

extern int yylex();


extern int yylex_destroy();
}

%union {
	int valInt;
	float valFloat;
	Tok tok;
	Node *node;
}

%code {
	IdList idList;
    char rulesNames[34][30] = {
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
				,"To Int"
				,"To Float"
    };

    void addIdItem(Node *id){
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
    int needSize = 0;
    DataType funcType = 0;
    Node *root;

    const int intTypes = ((1 <<  dInt) | (1 << dIntArray) | (1 << dMaxArrayI) | (1 << dMinArrayI) | (1 << dSumArrayI));
    DataType toBasicType(DataType tp){
    	if((1 << tp) & intTypes){
    		return dInt;
    	}
    	return dFloat;
    }

    void convertChildrenFloat(Node *pai, Node *f1, Tok op, Node *f2){
    	DataType t1 = toBasicType(f1->dType);
    	DataType t2 = toBasicType(f2->dType);
    	if(t1 < t2){
			Node *newNode = new_node();
			newNode->type = rulesNames[to_float];
			add_child(pai, newNode);
			add_child(newNode, f1);
			add_tchild(pai, op.op, op.line);
			add_child(pai, f2);
		}
		else if(t1 > t2){
			Node *newNode = new_node();
			newNode->type = rulesNames[to_float];
			add_child(pai, f1);
			add_tchild(pai, op.op, op.line);
			add_child(pai, newNode);
			add_child(newNode, f2);
		}
		else{
			add_child(pai, f1);
			add_tchild(pai, op.op, op.line);
			add_child(pai, f2);
		}
		pai->dType = t1 >= t2 ? t1 : t2;
    }
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
		$$->op = $2.op;
		add_child($$, $1);
		
		Symbol *onTable = find_symbol($2.op, 0);
		if(onTable){
			sprintf(wError + strlen(wError),"Error line %d: function %s redeclared, first occurrence on line %d\n", $1->line, $2.op, onTable->line);
		}
		else{
			add_symbol(getDtype($1->op), $2.op, $2.line, $2.pos, 1, 0);
			funcType = getDtype($1->op);
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
		add_child($$, $2);
		myfree((void**)&$1.op);
		myfree((void**)&$3.op);
		$$->type = rulesNames[function_body];
	}

parameters:
	'(' parameters_list ')'{
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		add_child($$, $2);
		$$->type = rulesNames[parameters];
		myfree((void**)&$1.op);
		myfree((void**)&$3.op);
	}
	| '(' ')'{
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		$$->type = rulesNames[parameters];
		myfree((void**)&$1.op);
		myfree((void**)&$2.op);
	}

parameters_list:
	parameter ',' parameters_list {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		myfree((void**)&$2.op);
		add_child($$, $3);
		$$->type = (void*)-1;
	}
	| parameter {
		$$ = $1;
		root = $$;
	}

parameter:
	type_identifier Id {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[parameter];
		$$->op = $2.op;
		
		Symbol *onTable = find_symbol($2.op, scopeStack->val);
		if(onTable){
			sprintf(wError + strlen(wError),"Error line %d: variable %s redeclared, first occurrence on line %d\n", $1->line, $2.op, onTable->line);
		}
		else{
			add_symbol(getDtype($1->op), $2.op, $2.line, $2.pos, 0, scopeStack->val);
			add_parameter(find_symbol(funcScope, 0), getDtype($1->op));
		}
	}
	| type_identifier Id '[' ']' {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		$$->type = rulesNames[parameter];
		$$->op = $2.op;

		Symbol *onTable = find_symbol($2.op, scopeStack->val);
		if(onTable){
			sprintf(wError + strlen(wError),"Error line %d: variable %s redeclared, first occurrence on line %d\n", $1->line, $2.op, onTable->line);
		}
		else{
			add_symbol(getDtype($1->op) + (getDtype($1->op) <= dFloatArray) * 2, $2.op, $2.line, $2.pos, 0, scopeStack->val);
			add_parameter(find_symbol(funcScope, 0), getDtype($1->op) + (getDtype($1->op) <= dFloatArray) * 2);
		}

		add_tchild($$, $3.op, $3.line);
		add_tchild($$, $4.op, $4.line);
	}

type_identifier:
	ArrayOp ArrayType {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		$$->type = rulesNames[type_identifier];
		char *aux = malloc(sizeof(char) * (strlen($1.op) + strlen($2.op) + 1));
		strcpy(aux, $1.op);
		strcat(aux, $2.op);
		myfree((void**)&$1.op);
		myfree((void**)&$2.op);
		$$->op = aux;
		needSize = 1;
	}
	| Type {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		$$->type = rulesNames[type_identifier];
		$$->op = $1.op;
		needSize = 0;
	}

statments:
	statment statments {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		add_child($$, $2);
		$$->type = (void*)-1;
	}
	| '{' statments '}' {
		$$ = $2;
		root = $$;
		myfree((void**)&$1.op);
		myfree((void**)&$3.op);
	}
	| statment {
		$$ = $1;
		root = $$;
	}

statment:
	variables_declaration {
		$$ = $1;
		root = $$;
	} 
	| retrn {
		$$ = $1;
		root = $$;
	} 
	| conditional {
		$$ = $1;
		root = $$;
	}
	| loop {
		$$ = $1;
		root = $$;
	}
	| expression ';' {
		$$ = $1;
		root = $$;
		myfree((void**)&$2.op);
	}
	| read {
		$$ = $1;
		root = $$;
	}
	| write {
		$$ = $1;
		root = $$;
	}

read:
	Read Id ';' {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		$$->type = rulesNames[readi];
		$$->op = $2.op;
		myfree((void**)&$1.op);
		myfree((void**)&$3.op);
	}

write:
	Write Id ';' {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		$$->type = rulesNames[writi];
		$$->op = $2.op;
		myfree((void**)&$1.op);
		myfree((void**)&$3.op);
	}

function_call:
	Id { argumentStack = intStackPush(argumentStack, -1); } '(' arguments ')'  {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		$$->op = $1.op;
		myfree((void**)&$3.op);
		add_child($$, $4);
		myfree((void**)&$5.op);
		$$->type = rulesNames[function_call];

		Symbol *onTable = find_symbol($1.op, 0);
		if(!onTable){
			sprintf(wError + strlen(wError),"Error line %d: function %s not declared\n", $1.line, $1.op);
			lastType = 0;
			$$->dType = 0;
		}
		else{
			if(!check_arguments(onTable->parameters, argumentStack, onTable, $1.line)){
				sprintf(wError + strlen(wError),"Error line %d: function %s used with wrong number of arguments\n", $1.line, $1.op);
			}
			lastType = onTable->type;
			$$->dType = onTable->type;
		}
		argumentStack = popAllIntStackm1(argumentStack);
	}

arguments:
	arguments_list {
		$$ = $1;
		root = $$;
	}
	| {
		$$ = new_node();
		root = $$;
		$$->type = (void*)-1;
	}

arguments_list:
	arguments_list ',' expression  {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		myfree((void**)&$2.op);
		add_child($$, $3);
		$$->type = (void*)-1;
		argumentStack = intStackPush(argumentStack, lastType);
	}
	| expression {
		$$ = $1;
		root = $$;

		argumentStack = intStackPush(argumentStack, lastType);
	}

conditional:
	if '{' statments '}' else_if {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		myfree((void**)&$2.op);
		add_child($$, $3);
		myfree((void**)&$4.op);
		add_child($$, $5);
		$$->type = rulesNames[conditional];
	}
	| if '{' statments '}' {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		myfree((void**)&$2.op);
		add_child($$, $3);
		myfree((void**)&$4.op);
		$$->type = rulesNames[conditional];
	}

if:
	If '(' expression ')' {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		myfree((void**)&$1.op);
		myfree((void**)&$2.op);
		add_child($$, $3);
		myfree((void**)&$4.op);
		$$->type = rulesNames[ife];
		scopeStack = intStackPush(scopeStack, $1.pos);
	}

else_if:
	Else conditional {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		myfree((void**)&$1.op);
		add_child($$, $2);
		$$->type = rulesNames[else_if];
	}
	| Else { scopeStack = intStackPush(scopeStack, $1.pos); } '{' statments '}' {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		myfree((void**)&$1.op);
		myfree((void**)&$3.op);
		add_child($$, $4);
		myfree((void**)&$5.op);
		$$->type = rulesNames[else_if];
	}

loop:
	While '(' expression ')' '{' statments '}' {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		$$->op = $1.op;
		myfree((void**)&$2.op);
		add_child($$, $3);
		myfree((void**)&$4.op);
		myfree((void**)&$5.op);
		add_child($$, $6);
		myfree((void**)&$7.op);
		$$->type = rulesNames[loop];
	}

retrn:
	Return expression ';' {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		add_tchild($$, $1.op, $1.line);
		if($2->dType != funcType){
			Node *newNode = new_node();
			newNode->type = rulesNames[toBasicType(funcType) == dInt ? to_int : to_float];
			add_child($$, newNode);
			add_child(newNode, $2);
			$$->dType = toBasicType(funcType);
		}
		else{
			add_child($$, $2);
		}
		myfree((void**)&$3.op);
		$$->type = rulesNames[retrn];
	}

value:
	Id {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		$$->type = rulesNames[value];
		$$->op = $1.op;

		Symbol *onTable = stack_find($1.op, scopeStack);
		if(!onTable){
			sprintf(wError + strlen(wError),"Error line %d: variable %s used but not declared\n", $1.line, $1.op);
			lastType = 0;
			$$->dType = 0;
		}
		else{
			lastType = onTable->type;
			$$->dType = onTable->type;
		}
	}
	| number {
		$$ = $1;
		root = $$;
		$$->dType = $1->dType;
	}
	| array_access {
		$$ = $1;
		root = $$;
		$$->dType = $1->dType;
	}
	| function_call {
		$$ = $1;
		root = $$;
		$$->dType = $1->dType;
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
			$$->dType = 0;
		}
		else{
			if(onTable->type <= dFloat){
				sprintf(wError + strlen(wError),"Error line %d: variable %s is not an array\n", $1.line, $1.op);
			}
			lastType = onTable->type;
			$$->dType = onTable->type;
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
			$$->dType = 0;
		}
		else{
			if(onTable->type <= dFloatArray){
				sprintf(wError + strlen(wError),"Error line %d: variable %s is not an operation array\n", $1.line, $1.op);
			}
			lastType = onTable->type;
			$$->dType = onTable->type;
		}
	}

variables_declaration:
	type_identifier identifiers_list ';' {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		add_child($$, $2);
		myfree((void**)&$3.op);
		$$->type = rulesNames[variables_declaration];
		DataType dType = getDtype($1->op);
		while(idList.first){
			Symbol *onTable = find_symbol(idList.first->id->op, scopeStack->val);
			if(onTable){
				sprintf(wError + strlen(wError),"Error line %d: variable %s redeclared, first occurrence on line %d\n", $1->line, idList.first->id->op, onTable->line);
			}
			else{
				add_symbol(dType + (dType <= dFloatArray) *  idList.first->id->dType, idList.first->id->op, $1->line, $2->pos, 0, scopeStack->val);
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
		Node *id = add_tchild($$, $1.op, $1.line);
		myfree((void**)&$2.op);
		add_child($$, $3);
		$$->type = (void*)-1;
		$$->pos = $1.pos;
		id->dType = 0;
		addIdItem(id);
		if(needSize){
			sprintf(wError + strlen(wError),"Error line %d: variable %s should be declared as %s[#]\n", $1.line, $1.op, $1.op);
		}
	}
	| Id '[' Integer ']' ',' identifiers_list {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		Node *id = add_tchild($$, $1.op, $1.line);
		add_tchild($$, $2.op, $2.line);
		add_tchild($$, $3.op, $3.line);
		add_tchild($$, $4.op, $4.line);
		myfree((void**)&$5.op);
		add_child($$, $6);
		$$->type = (void*)-1;
		$$->pos = $1.pos;
		id->dType = 2;
		addIdItem(id);
	}
	| Id '[' Integer ']' {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		$$->type = (void*)-1;
		Node *id = add_tchild($$, $1.op, $1.line);
		add_tchild($$, $2.op, $2.line);
		add_tchild($$, $3.op, $3.line);
		add_tchild($$, $4.op, $4.line);
		$$->pos = $1.pos;
		id->dType = 2;
		addIdItem(id);
	}
	| Id {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		Node *id = add_tchild($$, $1.op, $1.line);
		$$->type = (void*)-1;
		$$->pos = $1.pos;
		id->dType = 0;
		addIdItem(id);
		if(needSize){
			sprintf(wError + strlen(wError),"Error line %d: variable %s should be declared as %s[#]\n", $1.line, $1.op, $1.op);
		}
	}

expression: 
	Id assignment expression {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		$$->type = rulesNames[expression];
		add_tchild($$, $1.op, $1.line);
		add_child($$, $2);
		
		Symbol *onTable = stack_find($1.op, scopeStack);
		if(!onTable){
			sprintf(wError + strlen(wError),"Error line %d: variable %s used but not declared\n", $1.line, $1.op);
			add_child($$, $3);
		}
		else{
			if(toBasicType(onTable->type) != toBasicType($3->dType)){
				Node *newNode = new_node();
				newNode->type = rulesNames[toBasicType(onTable->type) == dInt ? to_int : to_float];
				add_child($$, newNode);
				add_child(newNode, $3);
				$$->dType = toBasicType(onTable->type);
			}
			else{
				add_child($$, $3);
			}
		}
		lastType = $$->dType;
	}
	| array_access assignment expression {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		add_child($$, $2);
		if(toBasicType($1->dType) != toBasicType($3->dType)){
			Node *newNode = new_node();
			newNode->type = rulesNames[toBasicType($1->dType) == dInt ? to_int : to_float];
			add_child($$, newNode);
			add_child(newNode, $3);
			$$->dType = toBasicType($1->dType);
		}
		else{
			add_child($$, $3);
		}
		$$->type = rulesNames[expression];
		lastType = $$->dType;
	}
	| expression_1 {
		$$ = $1;
		root = $$;
		if($$->type == 0){
			$$->type = rulesNames[expression];
		}
		lastType = $$->dType;
	}

expression_1:
	expression_2 Op1 expression_1 {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		convertChildrenFloat($$, $1, $2, $3);
		$$->type = (void*)-1;
	}
	| expression_2 {
		$$ = $1;
		root = $$;
	}

expression_2:
	expression_3 Op2 expression_2 {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		convertChildrenFloat($$, $1, $2, $3);
		$$->type = (void*)-1;
	}
	| expression_3 {
		$$ = $1;
		root = $$;
	}

expression_3:
	value Op3 expression_3 {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		convertChildrenFloat($$, $1, $2, $3);
		$$->type = (void*)-1;		
	}
	| UOp value {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		add_tchild($$, $1.op, $1.line);
		add_child($$, $2);
		$$->type = (void*)-1;
		$$->dType = $2->dType;
	}
	| UOp '(' expression ')' {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		add_tchild($$, $1.op, $1.line);
		myfree((void**)&$2.op);
		add_child($$, $3);	
		myfree((void**)&$4.op);
		$$->type = (void*)-1;
		$$->dType = $3->dType;
	}
	| value {
		$$ = $1;
		root = $$;
		$$->dType = $1->dType;
	}
	| '(' expression ')' {
		$$ = $2;
		root = $$;
		$$->type = (void*)-1;
		myfree((void**)&$1.op);
		myfree((void**)&$3.op);
		$$->dType = $2->dType;
	}

assignment:
	'=' {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		$$->op = $1.op;
		$$->type = rulesNames[assignment];
	}

number:
	Integer {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		$$->type = rulesNames[number];
		$$->op = $1.op;
		lastType = getDtype("int");
		$$->dType = dInt;
	}
	| Float {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		$$->type = rulesNames[number];
		$$->op = $1.op;
		lastType = getDtype("float");
		$$->dType = dFloat;
	}

%%

int main (void) {
	scopeStack = intStackPush(scopeStack, 0);
	argumentStack = 0;
	idList.first = idList.last = idList.firstOut = 0;
	root = 0;
	yyparse();
	yylex_destroy();
	if(root){
		show_tree(root, 1);
	}
	show_symbol();
	
	destroy_tree(root);
	destroy_symbol();
	popAllIntStack(argumentStack);
	popAllIntStack(scopeStack);

	printf("\n");
	printf("%s\n",wError );
}
