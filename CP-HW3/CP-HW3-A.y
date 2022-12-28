%{
	#include <stdio.h>
	#include <string.h>
	#include <math.h>

	int yylex();
	void yyerror(const char *message);
%}
%union {
	int int_val;
}
%token ADD
%token SUB
%token MUL
%token MOD
%token LOAD
%token INC
%token DEC
%token END_OF_FILE;
%token<int_val> INUMBER
%type<int_val> expr
%%
stmts   : call { return 0; }
        ;
call    : expr { printf("%d\n", $1); }
        ;
expr    : LOAD INUMBER      { $$ = $2; }
        | expr expr ADD     { $$ = $2 + $1; }
        | expr expr SUB     { $$ = $2 - $1; }
        | expr expr MUL     { $$ = $2 * $1; }
        | expr expr MOD     { $$ = $2 % $1; }
        | expr INC          { $$ = $1 + 1; }
        | expr DEC          { $$ = $1 - 1; }
        ;
%%
void yyerror(const char *message) {
	printf("Invalid format\n");
}
int main(int argc, char *argv[]) {
	yyparse();
	return 0;
}
