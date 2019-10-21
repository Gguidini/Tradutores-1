#include <stdio.h>
#include <stdlib.h>
#include "tree.h"

Node* new_node() {
	Node *no = (Node*) malloc(sizeof(Node));
	no->firstChild = 0;
	no->lastChild = 0;
	no->op[0] = 0;
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
	printf("%s %s%s", root->type, root->op, root->firstChild ? "{\n" : "\n");
	NodeList *child = root->firstChild;
	while(child){
		show_tree(child->val, tabs + 1);
		child = child->next;
	}
	for (i = 0; i < tabs; ++i) printf("  ");
	printf("%s", root->firstChild ? "}\n" : "\n");
}

void destroy_tree(Node *root) {
	//if (root->left) destroy_tree(root->left);
	//if (root->right) destroy_tree(root->right);
	free(root);
}

void yyerror (char const *s) {
	fprintf (stderr, "%s\n", s);
}