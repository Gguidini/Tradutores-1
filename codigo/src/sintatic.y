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
	char *code, *table;
	int codeSz, tableSz;
	int codeOc, tableOc;

    IntStack *scopeStack;
    IntStack *argumentStack;
    IntStack *argTempStack;
    IntStack *tempStack;
    IntStack *labelStack;
    IntStack *ifEndStack;
    int labelId, ifEndId;

    char* funcScope;
    DataType lastType;
    int needSize = 0;
    DataType funcType = 0;
    Node *root;
    int hasturn, paramNum;

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
    	if(t1 != f1->dType || t2 != f2->dType){
			sprintf(wError + strlen(wError),"Error line %d: no conversion from %s to %s exists\n", pai->line, dTypeName[f1->dType], dTypeName[f2->dType]);
			add_child(pai, f1);
			add_tchild(pai, op.op, op.line);
			add_child(pai, f2);
			pai->dType = 0;
			return;
    	}
    	if(t1 < t2){
			Node *newNode = new_node();
			newNode->type = rulesNames[to_float];
			add_child(pai, newNode);
			add_child(newNode, f1);
			add_tchild(pai, op.op, op.line);
			add_child(pai, f2);
			allocString(&code, &codeSz, codeOc);
			codeOc += sprintf(code + codeOc, "inttofl $%d, $%d\n", f1->temp, f1->temp);
		}
		else if(t1 > t2){
			Node *newNode = new_node();
			newNode->type = rulesNames[to_float];
			add_child(pai, f1);
			add_tchild(pai, op.op, op.line);
			add_child(pai, newNode);
			add_child(newNode, f2);
			allocString(&code, &codeSz, codeOc);
			codeOc += sprintf(code + codeOc, "inttofl $%d, $%d\n", f2->temp, f2->temp);
		}
		else{
			add_child(pai, f1);
			add_tchild(pai, op.op, op.line);
			add_child(pai, f2);
		}
		pai->dType = t1 >= t2 ? t1 : t2;
    }

    int check_arguments(IntStack *parameters, IntStack *arguments, IntStack* argTemp, Symbol *func, int line){
		if(parameters == 0 && (arguments == 0 || arguments->val == -1)){
			return 1;
		}
		if(parameters == 0 || arguments == 0 || arguments->val == -1){
			return 0;
		}
		if(!check_arguments(parameters->prev, arguments->prev, argTemp->prev, func, line)){
			return 0;
		}

		if(parameters->val != arguments->val){
			if(toBasicType(arguments->val) != arguments->val || toBasicType(parameters->val) != parameters->val){
				sprintf(wError + strlen(wError),"Error line %d: no conversion from %s to %s exists\n", line, dTypeName[arguments->val], dTypeName[parameters->val]);
			}
			else{
				sprintf(wError + strlen(wError),"Warning line %d: converting %s to %s on call to %s\n", line, dTypeName[arguments->val], dTypeName[parameters->val], func->name );
				allocString(&code, &codeSz, codeOc);
				codeOc += sprintf(code + codeOc, "%s $%d, $%d\n", parameters->val == dFloat ? "inttofl" : "fltoint", argTemp->val, argTemp->val);
			}
		}
		allocString(&code, &codeSz, codeOc);
		codeOc += sprintf(code + codeOc, "param $%d\n", argTemp->val);
		tempStack = intStackPush(tempStack, argTemp->val);
		paramNum++;
		return 1;
	}


	void yyerror (char const *s) {
		sprintf(wError + strlen(wError), "Error line %d: %s\n", root != 0 ? root->line : 1, s);
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
	| error {
		scopeStack = intStackPush(scopeStack, -2);
		funcScope = 0;
		hasturn = 0;
		paramNum = 0;
		
		popAllIntStack(&tempStack);
		for(int i = 1023; i >= 0; i--){
			tempStack = intStackPush(tempStack, i);
		}
	} parameters function_body {
		$$ = new_node();
		root = $$;
		$$->line = $3->line;

		add_child($$, $3);
		add_child($$, $4);

		$$->type = rulesNames[function_definition];

		scopeStack = intStackPop(scopeStack);

		sprintf(wError + strlen(wError),"Error line %d: sintatic error on function declaration\n", $3->line);
	}
	| function_declaration error function_body {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;

		add_child($$, $1);
		add_child($$, $3);

		$$->type = rulesNames[function_definition];

		scopeStack = intStackPop(scopeStack);

		sprintf(wError + strlen(wError),"Error line %d: sintatic error on function %s parameters\n", $1->line, $1->op);
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
			add_symbol(getDtype($1->op), $2.op, $2.line, $2.pos, 1, 0, 0);
			funcType = getDtype($1->op);
		}
		allocString(&code, &codeSz, codeOc);
		codeOc += sprintf(code + codeOc, "%s:\n", $2.op);

		$$->type = rulesNames[function_declaration];

		scopeStack = intStackPush(scopeStack, $2.pos);
		funcScope = $2.op;
		hasturn = 0;
		paramNum = 0;
		
		popAllIntStack(&tempStack);
		for(int i = 1023; i >= 0; i--){
			tempStack = intStackPush(tempStack, i);
		}
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

		if(hasturn == 0 && strcmp(funcScope, "main")){
			allocString(&code, &codeSz, codeOc);
			codeOc += sprintf(code + codeOc, "return %s\n", funcType == dFloat ? "0.0" : "0");
		}
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
			add_symbol(getDtype($1->op), $2.op, $2.line, $2.pos, 0, scopeStack->val, tempStack->val);
			allocString(&code, &codeSz, codeOc);
			codeOc += sprintf(code + codeOc, "mov $%d, #%d\n", tempStack->val, paramNum);
			tempStack = intStackPop(tempStack);
			add_parameter(find_symbol(funcScope, 0), getDtype($1->op));
		}
		paramNum++;
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
			add_symbol(getDtype($1->op) + (getDtype($1->op) <= dFloatArray) * 2, $2.op, $2.line, $2.pos, 0, scopeStack->val, tempStack->val);
			allocString(&code, &codeSz, codeOc);
			codeOc += sprintf(code + codeOc, "mov $%d, #%d\n", tempStack->val, paramNum);
			tempStack = intStackPop(tempStack);
			add_parameter(find_symbol(funcScope, 0), getDtype($1->op) + (getDtype($1->op) <= dFloatArray) * 2);
		}
		add_tchild($$, $3.op, $3.line);
		add_tchild($$, $4.op, $4.line);

		paramNum++;
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
	| '{' { scopeStack = intStackPush(scopeStack, $1.pos); } statments '}' {
		$$ = $3;
		root = $$;
		myfree((void**)&$1.op);
		myfree((void**)&$4.op);
		scopeStack = intStackPop(scopeStack);
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
	| { ifEndStack = intStackPush(ifEndStack, ifEndId++); } conditional {
		$$ = $2;
		root = $$;
		allocString(&code, &codeSz, codeOc);
		codeOc += sprintf(code + codeOc, "__end%d:\n", ifEndStack->val);
		ifEndStack = intStackPop(ifEndStack);
	}
	| loop {
		$$ = $1;
		root = $$;
	}
	| expression ';' {
		$$ = $1;
		root = $$;
		myfree((void**)&$2.op);
		tempStack = intStackPush(tempStack, $1->temp);
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
		myfree((void**)&$3.op);
		Symbol *onTable = stack_find($2.op, scopeStack);
		if(!onTable){
			sprintf(wError + strlen(wError),"Error line %d: variable %s used but not declared\n", $1.line, $1.op);
		}
		else{
			int temp = onTable->temp;
			if((onTable->type != dInt && $1.op[2] == 'I') || (onTable->type != dFloat && $1.op[2] == 'F')){
				sprintf(wError + strlen(wError),"Error line %d: no incorrect variable type on read, expecting %s\n", $1.line, $1.op[2] == 'I' ? "int" : "float");
			}
			else{
				allocString(&code, &codeSz, codeOc);
				if(temp != -1){
					codeOc += sprintf(code + codeOc, "%s $%d\n", $1.op[2] == 'I' ? "scani" : "scanf", temp);
				}
				else{
					codeOc += sprintf(code + codeOc, "%s %s\n", $1.op[2] == 'I' ? "scani" : "scanf", onTable->name);
				}
			}
		}
		myfree((void**)&$1.op);
	}

write:
	Write Id ';' {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		$$->type = rulesNames[writi];
		$$->op = $1.op;
		myfree((void**)&$3.op);

		Symbol *onTable = stack_find($2.op, scopeStack);
		if(!onTable){
			sprintf(wError + strlen(wError),"Error line %d: variable %s used but not declared\n", $1.line, $1.op);
		}
		else{
			int temp = onTable->temp;
			if(onTable->type != toBasicType(onTable->type)){
				sprintf(wError + strlen(wError),"Error line %d: no conversion from %s to %s exists\n", $1.line, dTypeName[onTable->type], $1.op[3] == 'I' ? "int" : "float");
			}
			else if(($1.op[3] == 'I' && onTable->type != dInt) || ($1.op[3] != 'I' && onTable->type == dInt)){
				Node *newNode = new_node();
				newNode->type = rulesNames[($1.op[3] == 'I' && onTable->type != dInt) ? to_int : to_float];
				add_child($$, newNode);
				add_tchild(newNode, $2.op, $2.line);
				allocString(&code, &codeSz, codeOc);
				if(temp != -1){
					codeOc += sprintf(code + codeOc, "%s $%d, $%d\n", ($1.op[3] == 'I' && onTable->type != dInt) ? "fltoint" : "inttofl", tempStack->val, temp);
				}
				else{
					codeOc += sprintf(code + codeOc, "%s $%d, %s\n", ($1.op[3] == 'I' && onTable->type != dInt) ? "fltoint" : "inttofl", tempStack->val, onTable->name);
				}
				temp = tempStack->val;
			}
			else{
				add_tchild($$, $2.op, $2.line);
			}
			allocString(&code, &codeSz, codeOc);
			if(temp != -1){
				codeOc += sprintf(code + codeOc, "println $%d\n", temp);
			}
			else{
				codeOc += sprintf(code + codeOc, "println %s\n", onTable->name);
			}
		}
	}

function_call:
	Id { argumentStack = intStackPush(argumentStack, -1); argTempStack = intStackPush(argTempStack, -1); } '(' arguments ')'  {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		$$->op = $1.op;
		myfree((void**)&$3.op);
		add_child($$, $4);
		myfree((void**)&$5.op);
		$$->type = rulesNames[function_call];
		paramNum = 0;

		Symbol *onTable = find_symbol($1.op, 0);
		if(!onTable){
			sprintf(wError + strlen(wError),"Error line %d: function %s not declared\n", $1.line, $1.op);
			lastType = 0;
			$$->dType = 0;
		}
		else{
			if(!check_arguments(onTable->parameters, argumentStack, argTempStack, onTable, $1.line)){
				sprintf(wError + strlen(wError),"Error line %d: function %s used with wrong number of arguments\n", $1.line, $1.op);
			}
			else{
				allocString(&code, &codeSz, codeOc);
				codeOc += sprintf(code + codeOc, "call %s, %d\n", $1.op, paramNum);
			}
			lastType = onTable->type;
			$$->dType = onTable->type;
		}
		argumentStack = popAllIntStackm1(argumentStack);
		argTempStack = popAllIntStackm1(argTempStack);
		
		$$->temp = tempStack->val;
		tempStack = intStackPop(tempStack);

		allocString(&code, &codeSz, codeOc);
		codeOc += sprintf(code + codeOc, "pop $%d\n", $$->temp);
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
		argTempStack = intStackPush(argTempStack, $3->temp);
	}
	| expression {
		$$ = $1;
		root = $$;

		argumentStack = intStackPush(argumentStack, lastType);
		argTempStack = intStackPush(argTempStack, $1->temp);
	}

conditional:
	if '{' statments '}' {
		scopeStack = intStackPop(scopeStack);
		allocString(&code, &codeSz, codeOc);
		codeOc += sprintf(code + codeOc, "jump __end%d\n", ifEndStack->val);
		allocString(&code, &codeSz, codeOc);
		codeOc += sprintf(code + codeOc, "__%d:\n", labelStack->val);
		labelStack = intStackPop(labelStack);
	} else_if {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		myfree((void**)&$2.op);
		add_child($$, $3);
		myfree((void**)&$4.op);
		add_child($$, $6);
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
		scopeStack = intStackPop(scopeStack);
		
		allocString(&code, &codeSz, codeOc);
		codeOc += sprintf(code + codeOc, "__%d:\n", labelStack->val);
		labelStack = intStackPop(labelStack);
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

		allocString(&code, &codeSz, codeOc);
		codeOc += sprintf(code + codeOc, "brz __%d, $%d\n", labelId, $3->temp);
		tempStack = intStackPush(tempStack, $3->temp);
		labelStack = intStackPush(labelStack, labelId++);
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
		scopeStack = intStackPop(scopeStack);
	}

loop:
	While {
		scopeStack = intStackPush(scopeStack, $1.pos);
		allocString(&code, &codeSz, codeOc);
		codeOc += sprintf(code + codeOc, "__%d:\n", labelId);
		labelStack = intStackPush(labelStack, labelId++);
	} '(' expression ')' {
		allocString(&code, &codeSz, codeOc);
		codeOc += sprintf(code + codeOc, "brz __%d, $%d\n", labelId, $4->temp);
		labelStack = intStackPush(labelStack, labelId++);
		tempStack = intStackPush(tempStack, $4->temp);
	}
	'{' statments '}' {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		$$->op = $1.op;
		myfree((void**)&$3.op);
		add_child($$, $4);
		myfree((void**)&$5.op);
		myfree((void**)&$7.op);
		add_child($$, $8);
		myfree((void**)&$9.op);
		$$->type = rulesNames[loop];
		scopeStack = intStackPop(scopeStack);

		int endLabel = labelStack->val;
		labelStack = intStackPop(labelStack);
		allocString(&code, &codeSz, codeOc);
		codeOc += sprintf(code + codeOc, "jump __%d\n", labelStack->val);
		labelStack = intStackPop(labelStack);
		allocString(&code, &codeSz, codeOc);
		codeOc += sprintf(code + codeOc, "__%d:\n", endLabel);
	}

retrn:
	Return expression ';' {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		add_tchild($$, $1.op, $1.line);
		if($2->dType != funcType){
			if(toBasicType(funcType) != funcType || $2->dType != toBasicType($2->dType)){
				sprintf(wError + strlen(wError),"Error line %d: no conversion from %s to %s exists\n", $1.line, dTypeName[$2->dType], dTypeName[funcType]);
				add_child($$, $2);
			}
			else{
				Node *newNode = new_node();
				newNode->type = rulesNames[funcType == dInt ? to_int : to_float];
				add_child($$, newNode);
				add_child(newNode, $2);
				$$->dType = toBasicType(funcType);
				if(strcmp(funcScope, "main")){
					allocString(&code, &codeSz, codeOc);
					codeOc += sprintf(code + codeOc, "%s $%d, $%d\n", funcType == dInt ? "fltoint" : "inttofl", $2->temp, $2->temp);
				}
			}
		}
		else{
			add_child($$, $2);
		}
		myfree((void**)&$3.op);
		$$->type = rulesNames[retrn];
		if(strcmp(funcScope, "main")){
			allocString(&code, &codeSz, codeOc);
			codeOc += sprintf(code + codeOc, "return $%d\n", $2->temp);
		}
		tempStack = intStackPush(tempStack, $2->temp);
		hasturn |= find_symbol(funcScope, 0)->scope == scopeStack->val;
	}

value:
	Id {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		$$->type = rulesNames[value];
		$$->op = $1.op;
		$$->temp = tempStack->val;
		tempStack = intStackPop(tempStack);

		Symbol *onTable = stack_find($1.op, scopeStack);
		if(!onTable){
			sprintf(wError + strlen(wError),"Error line %d: variable %s used but not declared\n", $1.line, $1.op);
			lastType = 0;
			$$->dType = 0;
		}
		else{
			lastType = onTable->type;
			$$->dType = onTable->type;
			allocString(&code, &codeSz, codeOc);
			if(onTable->temp != -1){
				codeOc += sprintf(code + codeOc, "mov $%d, $%d\n", $$->temp, onTable->temp);
			}
			else{
				codeOc += sprintf(code + codeOc, "mov $%d, %s\n", $$->temp, onTable->name);
			}
		}
	}
	| number {
		$$ = $1;
		root = $$;
		$$->dType = $1->dType;
		$$->temp = tempStack->val;
		tempStack = intStackPop(tempStack);
		allocString(&code, &codeSz, codeOc);
		codeOc += sprintf(code + codeOc, "mov $%d, %s\n", $$->temp, $1->op);
	}
	| array_access {
		$$ = $1;
		root = $$;
		allocString(&code, &codeSz, codeOc);
		int oldTemp = $1->temp;
		$$->temp = tempStack->val;
		tempStack = intStackPop(tempStack);

		if(oldTemp >= (1 << 11)){
			codeOc += sprintf(code + codeOc, "mov $%d, $%d[$%d]\n", $$->temp, (oldTemp >> 11) - 1, oldTemp & ((1 << 11) - 1));
		}
		else{
			codeOc += sprintf(code + codeOc, "mov $%d, &%s\n", tempStack->val, $1->op);
			codeOc += sprintf(code + codeOc, "mov $%d, $%d[$%d]\n", $$->temp, tempStack->val, oldTemp);
		}
	}
	| function_call {
		$$ = $1;
		root = $$;
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
	| '(' expression ')' {
		$$ = $2;
		root = $$;
		$$->type = (void*)-1;
		myfree((void**)&$1.op);
		myfree((void**)&$3.op);
	}

array_access:
	Id '[' expression ']'  {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		$$->type = rulesNames[array_access];
		$$->op = $1.op;
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
			if(onTable->type <= dFloat || onTable->type > dFloatArray){
				sprintf(wError + strlen(wError),"Error line %d: variable %s is not an array\n", $1.line, $1.op);
			}
			lastType = onTable->type;
			$$->dType = toBasicType(onTable->type);
			$$->temp = ((onTable->temp + 1) << 11) + $3->temp;
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
			$$->dType = toBasicType(onTable->type);
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
			Node *newSymbol = idList.first->id;
			Symbol *onTable = find_symbol(newSymbol->op, scopeStack->val);
			if(onTable){
				sprintf(wError + strlen(wError),"Error line %d: variable %s redeclared, first occurrence on line %d\n", $1->line, newSymbol->op, onTable->line);
			}
			else{
				add_symbol(dType + (dType <= dFloatArray) *  newSymbol->dType, newSymbol->op, $1->line, $2->pos, 0, scopeStack->val, scopeStack->val != 0 ? tempStack->val : -1);
				if(scopeStack->val != 0){
					if(newSymbol->dType == 2){
						allocString(&code, &codeSz, codeOc);
						codeOc += sprintf(code + codeOc, "mema $%d, %d\n", tempStack->val, newSymbol->aux);
					}
					tempStack = intStackPop(tempStack);
				}
				else{
					allocString(&table, &tableSz, tableOc);
					tableOc += sprintf(table + tableOc, "%s %s", dTypeName[toBasicType(dType)], newSymbol->op);
					if(newSymbol->dType == 2){
						tableOc += sprintf(table + tableOc, "[%d]", newSymbol->aux);
					}
					tableOc += sprintf(table + tableOc, "\n");
				}
			}
			IdItem *aux = idList.first->next;
			myfree((void**)&idList.first);
			idList.first = aux;
		}
	}
	| type_identifier error ';' {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		myfree((void**)&$3.op);
		sprintf(wError + strlen(wError),"Error line %d: sintatic error on variables declaration\n", $1->line);
	}
	| error identifiers_list ';' {
		$$ = new_node();
		root = $$;
		$$->line = $2->line;
		add_child($$, $2);
		myfree((void**)&$3.op);
		sprintf(wError + strlen(wError),"Error line %d: sintatic error on variables declaration\n", $2->line);
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
		id->aux = atoi($3.op);
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
		id->aux = atoi($3.op);
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
	Id '=' expression {
		$$ = new_node();
		root = $$;
		$$->line = $1.line;
		$$->type = rulesNames[expression];
		add_tchild($$, $1.op, $1.line);
		add_tchild($$, $2.op, $2.line);
		$$->temp = tempStack->val;
		tempStack = intStackPop(tempStack);

		Symbol *onTable = stack_find($1.op, scopeStack);
		if(!onTable){
			sprintf(wError + strlen(wError),"Error line %d: variable %s used but not declared\n", $1.line, $1.op);
			add_child($$, $3);
		}
		else{
			if(onTable->type != $3->dType){
				if(toBasicType(onTable->type) != onTable->type || toBasicType($3->dType) != $3->dType){
					sprintf(wError + strlen(wError),"Error line %d: no conversion from %s to %s exists\n", $1.line, dTypeName[$3->dType], dTypeName[onTable->type]);
					add_child($$, $3);
					$$->dType = onTable->type;
				}
				else{
					Node *newNode = new_node();
					newNode->type = rulesNames[toBasicType(onTable->type) == dInt ? to_int : to_float];
					add_child($$, newNode);
					add_child(newNode, $3);
					$$->dType = onTable->type;
				}
			}
			else{
				add_child($$, $3);
				$$->dType = 0;
			}
			switch($2.op[0]){
				case '=':
					tempStack = intStackPush(tempStack, $$->temp);
					$$->temp = $3->temp;
					allocString(&code, &codeSz, codeOc);
					if(onTable->temp != -1){
						codeOc += sprintf(code + codeOc, "mov $%d, $%d\n", onTable->temp, $3->temp);
					}
					else{
						codeOc += sprintf(code + codeOc, "mov %s, $%d\n", onTable->name, $3->temp);
					}
					break;
				default:
					allocString(&code, &codeSz, codeOc);
					char opString[6];
					char op = $2.op[0];
					strcpy(opString, op == '+' ? "add" :
									op == '-' ? "sub" :
									op == '^' ? "bxor" :
									op == '|' ? "bor" :
									op == '&' ? "band" :
									op == '*' ? "mul" :
									"div");
					if(onTable->temp != -1){
						codeOc += sprintf(code + codeOc, "%s $%d, $%d, $%d\n", opString, $$->temp, onTable->temp, $3->temp);
					}
					else{
						codeOc += sprintf(code + codeOc, "%s $%d, %s, $%d\n", opString, $$->temp, onTable->name, $3->temp);
					}
					break;
			}
		}
		if($2.op[0] != '='){
			allocString(&code, &codeSz, codeOc);
			if(onTable->temp != -1){
				codeOc += sprintf(code + codeOc, "mov $%d, $%d\n", onTable->temp, $$->temp);
			}
			else{
				codeOc += sprintf(code + codeOc, "mov %s, $%d\n", onTable->name, $$->temp);
			}
			tempStack = intStackPush(tempStack, $3->temp);
		}
		lastType = $$->dType;
	}
	| array_access '=' expression {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		add_child($$, $1);
		add_tchild($$, $2.op, $2.line);
		$$->temp = tempStack->val;
		tempStack = intStackPop(tempStack);

		if($1->dType != $3->dType){
			if(toBasicType($1->dType) != $1->dType || toBasicType($3->dType) != $3->dType){
				sprintf(wError + strlen(wError),"Error line %d: no conversion from %s to %s exists\n", $1->line, dTypeName[$3->dType], dTypeName[$1->dType]);
				add_child($$, $3);
			}
			else{
				Node *newNode = new_node();
				newNode->type = rulesNames[toBasicType($1->dType) == dInt ? to_int : to_float];
				add_child($$, newNode);
				add_child(newNode, $3);
				$$->dType = toBasicType($1->dType);
			}
		}
		else{
			add_child($$, $3);
		}

		switch($2.op[0]){
			case '=':
				$$->temp = $3->temp;
				allocString(&code, &codeSz, codeOc);
				if($1->temp >= (1 << 11)){
					codeOc += sprintf(code + codeOc, "mov $%d[$%d], $%d\n", ($1->temp >> 11) - 1, $1->temp & ((1 << 11) - 1), $3->temp);
				}
				else{
					codeOc += sprintf(code + codeOc, "mov $%d, &%s\n", tempStack->val, $1->op);
					codeOc += sprintf(code + codeOc, "mov $%d[$%d], $%d\n", tempStack->val, $1->temp, $3->temp);
				}
				break;
			default:
				allocString(&code, &codeSz, codeOc);
				char opString[6];
				char op = $2.op[0];
				strcpy(opString, op == '+' ? "add" :
								op == '-' ? "sub" :
								op == '^' ? "bxor" :
								op == '|' ? "bor" :
								op == '&' ? "band" :
								op == '*' ? "mul" :
								"div");
				if($1->temp >= (1 << 11)){
					codeOc += sprintf(code + codeOc, "mov $%d, $%d[$%d]\n", $$->temp, ($1->temp >> 11) - 1, $1->temp & ((1 << 11) - 1));
				}
				else{
					codeOc += sprintf(code + codeOc, "mov $%d, &%s\n", tempStack->val, $1->op);
					codeOc += sprintf(code + codeOc, "mov $%d, $%d[$%d]\n", $$->temp, tempStack->val, $1->temp);
				}
				codeOc += sprintf(code + codeOc, "%s $%d, $%d, $%d\n", opString,$$->temp, $$->temp, $3->temp);
				break;
		}
		if($2.op[0] != '='){
			allocString(&code, &codeSz, codeOc);
			if($1->temp >= (1 << 11)){
				codeOc += sprintf(code + codeOc, "mov $%d[$%d], $%d\n", ($1->temp >> 11) - 1, $1->temp & ((1 << 11) - 1), $$->temp);
			}
			else{
				codeOc += sprintf(code + codeOc, "mov %d[$%d], $%d\n", tempStack->val, $1->temp, $$->temp);
			}
			tempStack = intStackPush(tempStack, $3->temp);
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
	expression_1 Op1 expression_2 {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		convertChildrenFloat($$, $1, $2, $3);
		$$->type = (void*)-1;
		$$->temp = tempStack->val;
		tempStack = intStackPop(tempStack);

		switch($2.op[0]){
			case '<':
				allocString(&code, &codeSz, codeOc);
				codeOc += sprintf(code + codeOc, "%s $%d, $%d, $%d\n", $2.op[1] == '=' ? "sleq" : "slt", $$->temp, $1->temp, $3->temp);
				break;
			case '>':
				allocString(&code, &codeSz, codeOc);
				codeOc += sprintf(code + codeOc, "%s $%d, $%d, $%d\n", $2.op[1] == '=' ? "sleq" : "slt", $$->temp, $3->temp, $1->temp);
				break;
			case '=':
				allocString(&code, &codeSz, codeOc);
				codeOc += sprintf(code + codeOc, "seq $%d, $%d, $%d\n", $$->temp, $1->temp, $3->temp);
				break;
			case '!':
				allocString(&code, &codeSz, codeOc);
				codeOc += sprintf(code + codeOc, "seq $%d, $%d, $%d\n", $$->temp, $1->temp, $3->temp);
				allocString(&code, &codeSz, codeOc);
				codeOc += sprintf(code + codeOc, "bxor $%d, $%d, 1\n", $$->temp, $$->temp);
				break;
			case '|':
				allocString(&code, &codeSz, codeOc);
				codeOc += sprintf(code + codeOc, "or $%d, $%d, $%d\n", $$->temp, $1->temp, $3->temp);
				break;
			case '&':
				allocString(&code, &codeSz, codeOc);
				codeOc += sprintf(code + codeOc, "and $%d, $%d, $%d\n", $$->temp, $1->temp, $3->temp);
				break;
		}
		tempStack = intStackPush(tempStack, $1->temp);
		tempStack = intStackPush(tempStack, $3->temp);
	}
	| expression_2 {
		$$ = $1;
		root = $$;
	}

expression_2:
	expression_2 Op2 expression_3 {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		convertChildrenFloat($$, $1, $2, $3);
		$$->type = (void*)-1;
		$$->temp = tempStack->val;
		tempStack = intStackPop(tempStack);
		switch($2.op[0]){
			case '+':
				allocString(&code, &codeSz, codeOc);
				codeOc += sprintf(code + codeOc, "add $%d, $%d, $%d\n", $$->temp, $1->temp, $3->temp);
				break;
			case '-':
				allocString(&code, &codeSz, codeOc);
				codeOc += sprintf(code + codeOc, "sub $%d, $%d, $%d\n", $$->temp, $1->temp, $3->temp);
				break;
			case '^':
				allocString(&code, &codeSz, codeOc);
				codeOc += sprintf(code + codeOc, "bxor $%d, $%d, $%d\n", $$->temp, $1->temp, $3->temp);
				break;
			case '|':
				allocString(&code, &codeSz, codeOc);
				codeOc += sprintf(code + codeOc, "bor $%d, $%d, $%d\n", $$->temp, $1->temp, $3->temp);
				break;
			case '&':
				allocString(&code, &codeSz, codeOc);
				codeOc += sprintf(code + codeOc, "band $%d, $%d, $%d\n", $$->temp, $1->temp, $3->temp);
				break;
		}
		tempStack = intStackPush(tempStack, $1->temp);
		tempStack = intStackPush(tempStack, $3->temp);
	}
	| expression_3 {
		$$ = $1;
		root = $$;
	}

expression_3:
	 expression_3 Op3 value {
		$$ = new_node();
		root = $$;
		$$->line = $1->line;
		convertChildrenFloat($$, $1, $2, $3);
		$$->type = (void*)-1;
		$$->temp = tempStack->val;
		tempStack = intStackPop(tempStack);
		
		switch($2.op[0]){
			case '*':
				allocString(&code, &codeSz, codeOc);
				codeOc += sprintf(code + codeOc, "mul $%d, $%d, $%d\n", $$->temp, $1->temp, $3->temp);
				break;
			case '/':
				allocString(&code, &codeSz, codeOc);
				codeOc += sprintf(code + codeOc, "div $%d, $%d, $%d\n", $$->temp, $1->temp, $3->temp);
				break;
		}
		tempStack = intStackPush(tempStack, $1->temp);
		tempStack = intStackPush(tempStack, $3->temp);
	}
	| value {
		$$ = $1;
		root = $$;
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
	code = (char*)malloc(2001 * sizeof(char));
	codeSz = 2000;
	table = (char*)malloc(201 * sizeof(char));
	tableSz = 201;
	codeOc = tableOc = 0;
	tableOc += sprintf(table + tableOc, ".table\n");
	codeOc += sprintf(code + codeOc, ".code\n");
	tempStack = labelStack = 0;
	labelId = ifEndId = 0;
	scopeStack = intStackPush(scopeStack, 0);
	argumentStack = argTempStack = 0;
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
	popAllIntStack(&tempStack);
	popAllIntStack(&argumentStack);
	popAllIntStack(&scopeStack);

	printf("\n");
	printf("%s\n", wError);

	allocString(&code, &codeSz, codeOc);
	codeOc += sprintf(code + codeOc, "nop\n");

	FILE *tac;
	tac = fopen("code.tac", "w+");
	fprintf(tac, "%s", table);
	fprintf(tac, "%s", code);
	fclose(tac);
	free(code);
	free(table);
}
