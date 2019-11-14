#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "misc.h"

void myfree(void** p){
	free(*p);
	*p = 0;
}

IntStack* intStackPush(IntStack *stack, int val){
	IntStack *newVal = (IntStack*) malloc(sizeof(IntStack));
	newVal->prev = stack;
	newVal->val = val;
	return newVal;
}

IntStack* intStackPop(IntStack *stack){
	IntStack *newVal = stack->prev;
	free(stack);
	return newVal;
}

void popAllIntStack(IntStack *stack){
	while(stack){
		stack = intStackPop(stack);
	}
}

IntStack* popAllIntStackm1(IntStack *stack){
	while(stack && stack->val != -1){
		stack = intStackPop(stack);
	}
	if(stack){
		stack = intStackPop(stack);
	}
	return stack;
}

char dTypeName[8][20] = {
	"int"
	,"float"
	,"MaxArray<int>"
	,"MinArray<int>"
	,"SumArray<int>"
	,"MaxArray<float>"
	,"MinArray<float>"
	,"SumArray<float>"
};

DataType getDtype(char *s){
	if(strcmp(s, "int") == 0){
		return dInt;
	}
	else if(strcmp(s, "float") == 0){
		return dFloat;
	}
	else if(strcmp(s, "MaxArray<int>") == 0){
		return dMaxArrayI;
	}
	else if(strcmp(s, "MinArray<int>") == 0){
		return dMinArrayI;
	}
	else if(strcmp(s, "SumArray<int>") == 0){
		return dSumArrayI;
	}
	else if(strcmp(s, "MaxArray<float>") == 0){
		return dMaxArrayF;
	}
	else if(strcmp(s, "MinArray<float>") == 0){
		return dMinArrayF;
	}
	else if(strcmp(s, "SumArray<float>") == 0){
		return dSumArrayF;
	}
	return 20;
}