%{
	#include <stdio.h>

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
%token END_OF_FILE
%token<int_val> NUMBER
%type<int_val> expr
%%
stmts   : call { return 0; }
        ;
call    : expr { printf("%d\n", $1); }
        ;
expr    : LOAD NUMBER       { $$ = $2; printf("LOAD => %d\n", $2); }
        | expr expr ADD     { $$ = $2 + $1; printf("ADD => %d\n", $$); }
        | expr expr SUB     { $$ = $2 - $1; printf("SUB => %d\n", $$); }
        | expr expr MUL     { $$ = $2 * $1; printf("MUL => %d\n", $$); }
        | expr expr MOD     { $$ = $2 % $1; printf("MOD => %d\n", $$); }
        | expr INC          { $$ = $1 + 1; printf("INC => %d\n", $$); }
        | expr DEC          { $$ = $1 - 1; printf("DEC => %d\n", $$); }
        ;
%%
void yyerror(const char *message) {
	printf("Invalid format\n");
}
int main(int argc, char *argv[]) {
	yyparse();
	return 0;
}
