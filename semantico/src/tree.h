#ifndef TREE
#define TREE

#include "misc.h"

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
	int line, pos;
	DataType dType;
};

Node* new_node();

void add_child(Node*, Node*);

Node* add_tchild(Node*, char*, int);

void show_tree(Node*, int);

void destroy_tree(Node*);

void yyerror (char const *);

#endif