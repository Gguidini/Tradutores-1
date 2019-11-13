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
IntStack* invert_m1(IntStack**);
void popAllIntStack(IntStack*);

typedef enum DataType {
		dInt = 0
		,dFloat
		,dMaxArrayI
		,dMinArrayI
		,dSumArrayI
		,dMaxArrayF
		,dMinArrayF
		,dSumArrayF
} DataType;

char dTypeName[8][20];

DataType getDtype(char*);

#endif