%{
    #include<stdio.h>
    #include<string.h>
    #include<stdlib.h>
    int lines = 1, errors = 0;
%}

DIGIT    [0-9]

ID       [a-zA-Z_][a-z0-9A-Z]*

KEYWORD  if|else|while|return

OPERATOR [+^*/><!~|&-]

BASIC_TYPE int|float

ARRAY_OPERATION SumArray|MaxArray|MinArray

OUT outInt|outFloat

IN inInt|inFloat

int lines = 0, errors = 0;

%%

{DIGIT}+ {
    printf("Integer: %s\n", yytext);
}

{DIGIT}+"."{DIGIT}+ {
    printf("Float: %s\n", yytext);
}

{KEYWORD} {
    printf("Keyword: %s\n", yytext );
}

{OUT} {
    printf("Write: %s\n", yytext);
}

{IN} {
    printf("Read: %s\n", yytext);
}

{BASIC_TYPE} {
    printf("Basic type: %s\n", yytext);
}

"<"{BASIC_TYPE}">" {
    printf("Array type: %s\n", yytext);
}

{ARRAY_OPERATION} {
    printf("Range operation array: %s\n", yytext);
}

{ID} {
    if(yyleng >= 33) {
        printf("The idenfier length is too long, the idenfier was truncated to the first 33 characters\n");
        yytext[33] = 0;
    }
    printf("Identifier: %s\n", yytext);
}

{OPERATOR}|">="|"<="|"=="|"&&"|"||" {
    printf("Operator: %s\n", yytext);
}

{OPERATOR}?"=" {
    printf("Assignment: %s\n", yytext);
}

"["|"]" {
    printf("Array declaration/access: %s\n", yytext);
}

";" {
    printf("Command separator: %s\n", yytext);
}

"{"|"}" {
    printf("Block delimiter: %s\n", yytext);
}

"("|")" {
    printf("Expression delimiter: %s\n", yytext);
}

"," {
    printf("Variable/Range separator: %s\n", yytext);
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

int main(int argc, char ** argv) {
    ++argv, --argc;
    if(argc > 0) {
        yyin = fopen(argv[0], "r");
    }
    else {
        yyin = stdin;
    }
    yylex();
    printf("\n");
    if(errors > 0){
        printf("Incorrect program!\nLexical analysis terminated with %d error%s\n", errors, errors > 1 ? "s" : "");
    }
    else{
        printf("Correct program.\n");
    }
    return 0;
}
