%{
	#include <stdio.h>
	#include <stdlib.h>

	int yylex();
	void yyerror(const char *message);
%}
%union {
	int val;
}
%token<val> BOOLEAN;
%type<val> expr;
%%
stmts   : expr  {
					if ($1 == 1) printf("true\n");
					else printf("false\n");
					return 0;
				}
expr    : 'N' expr 'n'      { $$ = !$1; }
		| expr BOOLEAN      { $$ = $1; }
        |                   { $$ = 1; }
		;
%%
void yyerror(const char *message) {
	printf("Syntax Error\n");
}
int main(int argc, char *argv[]) {
	yyparse();
	return 0;
}
