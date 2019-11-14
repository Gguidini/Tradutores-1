#include <stdio.h>
#include <stdlib.h>
#include "tree.h"
#include "misc.h"

Node* new_node() {
	Node *no = (Node*) malloc(sizeof(Node));
	no->firstChild = 0;
	no->lastChild = 0;
	no->op = 0;
	no->line = 0;
	return no;
}

void add_child(Node *no, Node *child) {
	NodeList* newNode = (NodeList*) malloc(sizeof(NodeList));
	newNode->val = child;
	newNode->next = 0;
	if(no->firstChild == 0){
		no->firstChild = newNode;
		no->lastChild = no->firstChild;
	}
	else{
		no->lastChild->next = newNode;
		no->lastChild = newNode;
	}
}

void add_tchild(Node *no, char *op, int line){
	Node *newNode = new_node();
	newNode->type = 0;
	newNode->line = line;
	newNode->op = op;
	add_child(no, newNode);
}

void show_tree(Node *root, int tabs) {
	int i;
	if(tabs == 1){
		printf("------------------------------------------------\nTree\n\n");
	}
	if(root->type != (void*)-1){
		printf("line:%3d",root->line );
		for (i = 0; i < tabs-1; ++i) printf(" |");
		printf(" ");
		printf("%s %s%s", root->type == 0 ? "Token" : root->type, root->op == 0 ? "" : root->op, root->firstChild ? "{\n" : "\n");
	}
	NodeList *child = root->firstChild;
	while(child){
		show_tree(child->val, tabs + 1 - (root->type == (void*)-1));
		child = child->next;
	}
	if(root->type != (void*)-1){
		if(root->firstChild){
			printf("line:%3d",root->line );
			for (i = 0; i < tabs-1; ++i) printf(" |");
			printf(" ");
			printf("}");
			printf("\n");
		}
	}
	if(tabs == 1){
		printf("------------------------------------------------\n");
	}
}

void destroy_tree(Node *root) {
	NodeList *child = root->firstChild;
	while(child){
		destroy_tree(child->val);
		NodeList *aux = child;
		child = child->next;
		myfree((void**)&aux);
	}
	if(root->op){
		myfree((void**)&root->op);
	}
	myfree((void**)&root);
}

void yyerror (char const *s) {
	fprintf (stderr, "%s\n", s);
}