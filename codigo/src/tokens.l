%{
	#include "sintatic.tab.h"

    int lines = 1, errors = 0, pos = 1;
%}

%option noyywrap
%option bison-bridge


DIGIT   [0-9]

ID      [a-zA-Z_][a-z0-9A-Z]*

OP1     ">"|"<"|"=="|">="|"<="|"&&"|"||"

OP2     "+"|"-"|"^"|"|"|"&"

OP3     "*"|"/"

UOP     "!"|"~"

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
    yylval->tok.pos = pos;
    return Integer;
}

{DIGIT}+"."{DIGIT}+ {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
	yylval->tok.line = lines;
    yylval->tok.pos = pos;
    return Float;
}

"return" {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    yylval->tok.pos = pos;
    return Return;
}

"if" {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    yylval->tok.pos = pos;
    return If;
}

"else" {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    yylval->tok.pos = pos;
    return Else;
}

"while" {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    yylval->tok.pos = pos;
    return While;
}

{OUT} {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    yylval->tok.pos = pos;
    return Write;
}

{IN} {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    yylval->tok.pos = pos;
    return Read;
}

{BASIC_TYPE} {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    yylval->tok.pos = pos;
    return Type;
}

"<"{BASIC_TYPE}">" {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    yylval->tok.pos = pos;
    return ArrayType;
}

{ARRAY_OPERATION} {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    yylval->tok.pos = pos;
    return ArrayOp;
}

{ID} {
    if(yyleng >= 33) {
        sprintf(wError + strlen(wError),"Warning line %d: the idenfier %s is too long, it was truncated to the first 33 characters\n", lines, yytext);
        yytext[33] = 0;
    }
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    yylval->tok.pos = pos;
    return Id;
}

{OP1} {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    yylval->tok.pos = pos;
    return Op1;
}

{OP2} {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    yylval->tok.pos = pos;
    return Op2;
}

{OP3} {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    yylval->tok.pos = pos;
    return Op3;
}

{UOP} {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    yylval->tok.pos = pos;
    return UOp;
}

"="|{OP2}"="|{OP3}"="|{UOP}"=" {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
	yylval->tok.line = lines;
    yylval->tok.pos = pos;
    return '=';
}

"[" {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    yylval->tok.pos = pos;
    return '[';
}

"]" {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    yylval->tok.pos = pos;
    return ']';
}

";" {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    yylval->tok.pos = pos;
    pos++;
    return ';';
}

"{" {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    yylval->tok.pos = pos;
    pos++;
    return '{';
}

"}" {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    yylval->tok.pos = pos;
    return '}';
}

"(" {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    yylval->tok.pos = pos;
    return '(';
}

")" {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    yylval->tok.pos = pos;
    return ')';
}

"," {
    yylval->tok.op = (char*) malloc(sizeof(char) * (1 + strlen(yytext)));
    strcpy(yylval->tok.op, yytext);
    yylval->tok.line = lines;
    yylval->tok.pos = pos;
    return ',';
}

[ \t]+

\n {
    lines++;
}

. {
    errors++;
    sprintf(wError + strlen(wError),"Error line %d: Unrecognized character: %s\n", lines, yytext);
}

{DIGIT}+[^+*<>=~&|/^\n\t ;,)\]-]+ {
    errors++;
    sprintf(wError + strlen(wError),"Error line %d: Unrecognized token: %s\n", lines, yytext);
}

%%