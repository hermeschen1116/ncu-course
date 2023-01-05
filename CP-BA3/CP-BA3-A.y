%{
	#include <stdio.h>
	#include <stdlib.h>

	int yylex();
	void yyerror(const char *message);

	int pointer = 0, error_flag = 0;
	int stack[1024];
%}
%union {
	long long int int_val;
}
/* Terminal */
%token<int_val> NUMBER
/* Non-terminal */
%type<int_val> formula
%type<int_val> operation
%left '+'
%left '-'
%left 'P'
%left 'C'
%%
stmt        : formula   {
							printf("%lld\n", $1);
							return 0;
						}
			;
formula     : operation '+' formula   { $$ = $1 + $3; }
			| operation '-' formula   { $$ = $1 - $3; }
			| operation             { $$ = $1; }
			;
operation   : 'P' NUMBER NUMBER     {
										int i = 1, sum_t = 1, sum_b = 1;
										if ($2 == $3) $$ = 1;
										else if ($2 > $3 && $2 <= 12 && $3 <=12) {
											for (i = 1; i <= $2; i++) sum_t *= i;
											for (i = 1; i <= ($2 - $3); i++) sum_b *= i;
											$$ = sum_t / sum_b;
										} else {
											printf("Wrong Formula\n");
											return 0;
										}
									}
			| 'C' NUMBER NUMBER     {
										int i = 1, sum_t = 1, sum_b = 1;
										if ($2 == $3) $$ = 1;
	                                    else if ($2 > $3 && $2 <= 12 && $3 <=12) {
	                                        for (i = 1; i <= $2; i++) sum_t *= i;
	                                        for (i = 1; i <= $3; i++) sum_b *= i;
	                                        for (i = 1; i <= ($2 - $3); i++) sum_b *= i;
	                                        $$ = sum_t / sum_b;
	                                    } else {
	                                        printf("Wrong Formula\n");
	                                        return 0;
	                                    }
									}
			| NUMBER                { $$ = $1; }
			;
%%
void yyerror(const char *message) {
	printf("Wrong Formula\n");
}
int main(int argc, char *argv[]) {
	yyparse();

	return 0;
}
