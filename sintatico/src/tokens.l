%{
	#include "sintatic.tab.h"

    int lines = 1, errors = 0;
%}

%option noyywrap
%option bison-bridge


DIGIT    [0-9]

ID       [a-zA-Z_][a-z0-9A-Z]*

KEYWORD  if|else|while|return

OP1 >|<|"=="|">="|"<="

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
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
	yylval->tok.line = lines;
    return Integer;
}

{DIGIT}+"."{DIGIT}+ {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
	yylval->tok.line = lines;
    return Float;
}

"return" {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    return Return;
}

"if" {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    return If;
}

"else" {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    return Else;
}

"while" {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    return While;
}

{OUT} {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    return Writi;
}

{IN} {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    return Readi;
}

{BASIC_TYPE} {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    return Type;
}

"<"{BASIC_TYPE}">" {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    return ArrayType;
}

{ARRAY_OPERATION} {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    return ArrayOp;
}

{ID} {
    if(yyleng >= 33) {
        printf("Warning! Line %d. The idenfier %s is too long, it was truncated to the first 33 characters\n", lines, yytext);
        yytext[33] = 0;
    }
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    return Id;
}

{OP1} {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    return Op1;
}

{OP2} {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    return Op2;
}

{OP3} {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    return Op3;
}

{UOP} {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    return UOp;
}

"="|{OP2}"="|{OP3}"="|{UOP}"=" {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
	yylval->tok.line = lines;
    return '=';
}

"[" {
    yylval->tok.line = lines;
    return '[';
}

"]" {
    yylval->tok.line = lines;
    return ']';
}

";" {
    yylval->tok.line = lines;
    return ';';
}

"{" {
    yylval->tok.line = lines;
    return '{';
}

"}" {
    yylval->tok.line = lines;
    return '}';
}

"(" {
    yylval->tok.line = lines;
    return '(';
}

")" {
    yylval->tok.line = lines;
    return ')';
}

"," {
    yylval->tok.line = lines;
    return ',';
}

[ \t]+

\n {
    lines++;
}

. {
    errors++;
    printf("ERROR! line %d! Unrecognized character: %s\n", lines, yytext);
}

{DIGIT}+[^+*<>=~&|/^\n\t ;,)\]-]+ {
    errors++;
    printf("ERROR! line %d! Unrecognized token: %s\n", lines, yytext);
}

%%