#ifndef MISC
#define MISC

void myfree(void**);

typedef struct IntList IntList;

struct IntList {
	int val;
	IntList *next;
};

typedef struct StringList StringList;

struct StringList {
	char *val;
	StringList *next;
}; 

typedef struct IntStack IntStack;

struct IntStack {
	int val;
	IntStack *prev;
}; 

IntStack* intStackPop(IntStack*);
IntStack* intStackPush(IntStack* ,int);
void popAllIntStack(IntStack*);
IntStack* popAllIntStackm1(IntStack*);

typedef enum DataType {
		dInt = 0
		,dFloat
		,dIntArray
		,dFloatArray
		,dMaxArrayI
		,dMinArrayI
		,dSumArrayI
		,dMaxArrayF
		,dMinArrayF
		,dSumArrayF
} DataType;

char dTypeName[10][20];

DataType getDtype(char*);
char wError[200000];

#endif