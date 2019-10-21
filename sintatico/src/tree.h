#ifndef TREE
#define TREE

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
	char op[100];
	int valueI;
	float valueF;
	int line;
};

Node* new_node();

void add_child(Node*, Node*);

void show_tree(Node*, int);

void destroy_tree(Node*);

void yyerror (char const *);

#endif