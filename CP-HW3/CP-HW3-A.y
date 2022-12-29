%{
	#include <stdio.h>
	#include <stdlib.h>

	int yylex();
	void yyerror(const char *message);

	int pointer = 0, error_flag = 0;
	int stack[1024];
%}
%union {
	int int_val;
	char* op, line;
}
/* Terminal */
%token<op> LOAD
%token<op> ADD
%token<op> SUB
%token<op> MUL
%token<op> MOD
%token<op> INC
%token<op> DEC
%token<int_val> NUMBER
/* Non-terminal */
%type<line> call
%%
stmts   : stmts call
		|
		;
call    : LOAD NUMBER   { stack[pointer++] = $2; }
		| ADD           {
							if (pointer >= 2) {
								stack[pointer-2] = stack[pointer-1] + stack[pointer-2];
								pointer--;
							} else {
								error_flag = 1;
								YYABORT;
							}
						}
		| SUB           {
							if (pointer >= 2) {
                                stack[pointer-2] = stack[pointer-1] - stack[pointer-2];
                                pointer--;
                            } else {
                                error_flag = 1;
                                YYABORT;
                            }
						}
		| MUL           {
							if (pointer >= 2) {
                                stack[pointer-2] = stack[pointer-1] * stack[pointer-2];
                                pointer--;
                            } else {
                                error_flag = 1;
                                YYABORT;
                            }
						}
		| MOD           {
							if (pointer >= 2) {
                                stack[pointer-2] = stack[pointer-1] % stack[pointer-2];
                                pointer--;
                            } else {
                                error_flag = 1;
                                YYABORT;
                            }
						}
		| INC           {
							if (pointer >= 1) ++stack[pointer-1];
                            else {
                                error_flag = 1;
                                YYABORT;
                            }
						}
		| DEC           {
							if (pointer >= 1) --stack[pointer-1];
                            else {
                                error_flag = 1;
                                YYABORT;
                            }
						}
		;
%%
void yyerror(const char *message) {
	printf("Invalid format\n");
}
int main(int argc, char *argv[]) {
	yyparse();
	if (pointer != 1 || error_flag == 1) printf("Invalid format\n");
	else printf("%d\n", stack[0]);

	return 0;
}
