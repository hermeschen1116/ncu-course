%{
	#include <stdio.h>
	#include <string.h>
	void yyerror(const char *message);

	int stack[1024] = {0};
	int pointer = 0;
%}
%union {
	int int_val;
	char operand[4];
}
%token<int_val> INTEGER
%token<operand> OPERAND
%%
call :  INTEGER     {
						if (pointer < 1024) stack[pointer++] = $1;
					}
		| OPERAND   {
						if (pointer >= 2) {
							if (!strcmp($1, "add")) {
								stack[pointer-2] = stack[pointer-1] + stack[pointer-2];
								pointer -= 2;
							} else if (!strcmp($1, "sub")) {
								stack[pointer-2] = stack[pointer-1] - stack[pointer-2];
                                pointer -= 2;
                            } else if (!strcmp($1, "mul")) {
                                stack[pointer-2] = stack[pointer-1] * stack[pointer-2];
                                pointer -= 2;
                            } else if (!strcmp($1, "mod")) {
                                stack[pointer-2] = stack[pointer-1] % stack[pointer-2];
                                pointer -= 2;
                            } else if (!strcmp($1, "inc")) {
                                stack[pointer-1] += 1;
                            } else if (!strcmp($1, "dec")) {
                                stack[pointer-1] -= 1;
                            } else printf("Invalid format\n");
						}
						else printf("Invalid format\n");
				    }
		;
%%
void yyerror (const char *message) {
	fprintf (stderr, "%s\n",message);
}
int main(int argc, char *argv[]) {
	yyparse();
	if (pointer > 1) printf("Invalid format\n");
	else printf("%d\n", stack[0]);

	return 0;
}
