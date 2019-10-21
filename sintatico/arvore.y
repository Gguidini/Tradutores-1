%define parse.error verbose
%define api.pure
%debug
%defines

%code requires {
#include <stdlib.h>
#include <stdio.h>

typedef struct Node Node;

typedef struct NodeList NodeList;
struct NodeList {
	Node *val;
	NodeList *next;
};

struct Node {
	NodeList *firstChild;
	NodeList *lastChild;
	char* type;
	char* op;
	int valueI;
	float valueF;
};

typedef enum Rules {
	program = 0,
	expression,
	expression1,
	expression2,
	expression3,
	assignment,
	number
} Rules;

char rulesNames[100][100] = {"program"
							,"expression"
							,"expression1"
							,"expression2"
							,"expression3"
							,"assignment"
							,"number"};

Node* new_node();
void add_child(Node*, Node*);
void show_tree(Node*, int);
void destroy_tree(Node*);
void yyerror (char const *);
}


%union {
	int valInt;
	float valFloat;
	char* op;
	Node *node;
}

%token <valInt> Integer "integer"
%token <valFloat> Float "float"
%token <valInt> Keyword "keyword"
%token <valInt> Write "write"
%token <valInt> Read "read"
%token <valInt> Type "type"
%token <valInt> ArrayType "arrayType"
%token <valInt> ArrayOp "arrayOp"
%token <valInt> Id "id"
%token <op> Op1 "op1"
%token <op> Op2 "op2"
%token <op> Op3 "op3"
%token <op> UOp "uop"

%type <node> program
%type <node> expression
%type <node> expression1
%type <node> expression2
%type <node> expression3
%type <node> assignment
%type <node> number

%start program

%%

program:
	expression	{
		$$ = new_node();
		add_child($$, $1);
		$$->type = rulesNames[program];
		show_tree($$, 1);
	}

expression: 
	Id assignment expression {
		$$ = new_node();
		add_child($$, $2);
		add_child($$, $3);
		$$->type = rulesNames[expression];
	}
	| expression1 {
		$$ = new_node();
		add_child($$, $1);
		$$->type = rulesNames[expression];
	}

expression1:
	expression2 Op1 expression1 {
		$$ = new_node();
		$$->op = $2;
		add_child($$, $1);
		add_child($$, $3);
		$$->type = rulesNames[expression1];
	}
	| expression2 {
		$$ = new_node();
		$$->op = ' ';
		add_child($$, $1);
		$$->type = rulesNames[expression1];
	}

expression2:
	expression3 Op2 expression2 {
		$$ = new_node();
		$$->op = $2;
		add_child($$, $1);
		add_child($$, $3);
		$$->type = rulesNames[expression2];
	}
	| expression3 {
		$$ = new_node();
		add_child($$, $1);
		$$->type = rulesNames[expression2];
	}

expression3:
	number Op3 expression3 {
		$$ = new_node();
		$$->op = $2;
		add_child($$, $1);
		add_child($$, $3);
		$$->type = rulesNames[expression3];
	}
	| number {
		$$ = new_node();
		add_child($$, $1);	
		$$->type = rulesNames[expression3];
	}

assignment:
	'=' {
		$$ = new_node();
		$$->type = rulesNames[assignment];
	}
	| UOp '=' {
		$$ = new_node();
		$$->type = rulesNames[assignment];
	}
	| Op2 '=' {
		$$ = new_node();
		$$->type = rulesNames[assignment];
	}
	| Op3 '=' {
		$$ = new_node();
		$$->type = rulesNames[assignment];
	}

number:
	Integer {
		$$ = new_node();
		$$->valueI = $1;
		$$->valueF = 0;
		$$->type = rulesNames[number];
	}
	| Float {
		$$ = new_node();
		$$->valueF = $1;
		$$->valueI = 0;
		$$->type = rulesNames[number];
	}

%%

Node* new_node() {
	Node *no = (Node*) malloc(sizeof(Node));
	no->firstChild = 0;
	no->lastChild = 0;
	return no;
}

void add_child(Node *no, Node *child) {
	if(no->firstChild == 0){
		no->firstChild = (NodeList*) malloc(sizeof(NodeList));
		no->firstChild->val = child;
		no->firstChild->next = 0;
		no->lastChild = no->firstChild;
	}
	else{
		NodeList* newNode = (NodeList*) malloc(sizeof(NodeList));
		newNode->val = child;
		newNode->next = 0;
		no->lastChild->next = newNode;
		no->lastChild = newNode;
	}
}

void show_tree(Node *root, int tabs) {
	int i;
	if(tabs == 1){
		printf("Tree\n\n");
	}
	for (i = 0; i < tabs; ++i) printf("  ");
	if (root->type) {
		printf("%s%s", root->type, root->firstChild ? "{\n" : "\n");
		NodeList *child = root->firstChild;
		while(child){
			show_tree(child->val, tabs + 1);
			child = child->next;
		}
		for (i = 0; i < tabs; ++i) printf("  ");
		printf("%s", root->firstChild ? "}\n" : "\n");
	}
	else
		printf("%d || %f\n", root->valueI, root->valueF);
}

void destroy_tree(Node *root) {
	//if (root->left) destroy_tree(root->left);
	//if (root->right) destroy_tree(root->right);
	free(root);
}

void yyerror (char const *s) {
	fprintf (stderr, "%s\n", s);
}

int main (void) {
	return yyparse();
}
