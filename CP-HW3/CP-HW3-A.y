%{
	#include <stdio.h>

	int yylex();
	void yyerror(const char *message);
%}
%union {
	int int_val;
}
/* Terminal */
%token LOAD
%token ADD
%token SUB
%token MUL
%token MOD
%token INC
%token DEC
%token<int_val> NUMBER
/* Non-terminal */
%type<int_val> expr
%%
stmts   : call { return 0; }
        ;
call    : expr { printf("%d\n", $1); }
        ;
expr    : LOAD NUMBER       { $$ = $2; /*printf("LOAD => %d\n", $2);*/ }
        | expr expr ADD     { $$ = $2 + $1; /*printf("ADD => %d\n", $$);*/ }
        | expr ADD          { printf("Invalid format\n"); return 0; }
        | expr expr SUB     { $$ = $2 - $1; /*printf("SUB => %d\n", $$);*/ }
        | expr SUB          { printf("Invalid format\n"); return 0; }
        | expr expr MUL     { $$ = $2 * $1; /*printf("MUL => %d\n", $$);*/ }
        | expr MUL          { printf("Invalid format\n"); return 0; }
        | expr expr MOD     { $$ = $2 % $1; /*printf("MOD => %d\n", $$);*/ }
        | expr MOD          { printf("Invalid format\n"); return 0; }
        | expr INC          { $$ = $1 + 1; /*printf("INC => %d\n", $$);*/ }
        | expr DEC          { $$ = $1 - 1; /*printf("DEC => %d\n", $$);*/ }
        | expr              { printf("Invalid format\n"); return 0; }
        ;
%%
void yyerror(const char *message) {
	printf("Invalid format\n");
}
int main(int argc, char *argv[]) {
	yyparse();
	return 0;
}
