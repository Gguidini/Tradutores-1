%{
	#include "sintatic.tab.h"

    int lines = 1, errors = 0;
%}

%option noyywrap
%option bison-bridge


DIGIT    [0-9]

ID       [a-zA-Z_][a-z0-9A-Z]*

KEYWORD  if|else|while|return

OP1 >|<|==|>=|<=

OP2 "+"|"-"|'^'|'|'|&|&&|"||"

OP3 "*"|"/"

UOP !|~

BASIC_TYPE int|float

ARRAY_OPERATION SumArray|MaxArray|MinArray

OUT outInt|outFloat

IN inInt|inFloat

int lines = 0, errors = 0;

%%

{DIGIT}+ {
    yylval->op = (char*) malloc(sizeof(char) * strlen(yytext));
    strcpy(yylval->op, yytext);
	return Integer;
}

{DIGIT}+"."{DIGIT}+ {
    yylval->op = (char*) malloc(sizeof(char) * strlen(yytext));
    strcpy(yylval->op, yytext);
	return Float;
}

{KEYWORD} {
    yylval->op = (char*) malloc(sizeof(char) * strlen(yytext));
    strcpy(yylval->op, yytext);
    return Keyword;
}

{OUT} {
    yylval->op = (char*) malloc(sizeof(char) * strlen(yytext));
    strcpy(yylval->op, yytext);
    return Write;
}

{IN} {
    yylval->op = (char*) malloc(sizeof(char) * strlen(yytext));
    strcpy(yylval->op, yytext);
    return Read;
}

{BASIC_TYPE} {
    yylval->op = (char*) malloc(sizeof(char) * strlen(yytext));
    strcpy(yylval->op, yytext);
    return Type;
}

"<"{BASIC_TYPE}">" {
    yylval->op = (char*) malloc(sizeof(char) * strlen(yytext));
    strcpy(yylval->op, yytext);
    return ArrayType;
}

{ARRAY_OPERATION} {
    yylval->op = (char*) malloc(sizeof(char) * strlen(yytext));
    strcpy(yylval->op, yytext);
    return ArrayOp;
}

{ID} {
    if(yyleng >= 33) {
        printf("The idenfier length is too long, the idenfier was truncated to the first 33 characters\n");
        yytext[33] = 0;
    }
    yylval->op = (char*) malloc(sizeof(char) * strlen(yytext));
    strcpy(yylval->op, yytext);
    return Id;
}

{OP1} {
    yylval->op = (char*) malloc(sizeof(char) * strlen(yytext));
    strcpy(yylval->op, yytext);
    return Op1;
}

{OP2} {
    yylval->op = (char*) malloc(sizeof(char) * strlen(yytext));
    strcpy(yylval->op, yytext);
    return Op2;
}

{OP3} {
    yylval->op = (char*) malloc(sizeof(char) * strlen(yytext));
    strcpy(yylval->op, yytext);
    return Op3;
}

{UOP} {
    yylval->op = (char*) malloc(sizeof(char) * strlen(yytext));
    strcpy(yylval->op, yytext);
    return UOp;
}

"=" {
    yylval->op = (char*) malloc(sizeof(char) * strlen(yytext));
    strcpy(yylval->op, yytext);
	return '=';
}

"[" {
    yylval->op = (char*) malloc(sizeof(char) * strlen(yytext));
    strcpy(yylval->op, yytext);
    return '[';
}

"]" {
    yylval->op = (char*) malloc(sizeof(char) * strlen(yytext));
    strcpy(yylval->op, yytext);
    return ']';
}

";" {
    yylval->op = (char*) malloc(sizeof(char) * strlen(yytext));
    strcpy(yylval->op, yytext);
    return ';';
}

"{" {
    yylval->op = (char*) malloc(sizeof(char) * strlen(yytext));
    strcpy(yylval->op, yytext);
    return '{';
}

"}" {
    yylval->op = (char*) malloc(sizeof(char) * strlen(yytext));
    strcpy(yylval->op, yytext);
    return '}';
}

"(" {
    yylval->op = (char*) malloc(sizeof(char) * strlen(yytext));
    strcpy(yylval->op, yytext);
    return '(';
}

")" {
    yylval->op = (char*) malloc(sizeof(char) * strlen(yytext));
    strcpy(yylval->op, yytext);
    return ')';
}

"," {
    yylval->op = (char*) malloc(sizeof(char) * strlen(yytext));
    strcpy(yylval->op, yytext);
    return ',';
}

[ \t]+

\n {
    lines++;
}

. {
    errors++;
    printf("ERROR line %d! Unrecognized character: %s\n", lines, yytext);
}

{DIGIT}+[^+*<>=~&|/^\n\t ;,)\]-]+ {
    errors++;
    printf("ERROR line %d! Unrecognized token: %s\n", lines, yytext);
}

%%