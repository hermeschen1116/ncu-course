%{
	#include <stdio.h>

	int yylex();
	void yyerror(const char *message);
	void sematic_error(int num_column);
%}
%union {
	int int_val;
    int loc;
    struct def {
        int row, column;
    } mat;
}
%type<mat> matrix
%token<int_val> NUM
%token<loc> ADD_SUB
%token<loc> MUL
%token<loc> TRS
%token<loc> LRBR
%token<loc> RRBR
%token<loc> LSBR
%token<loc> RSBR
%left TRS
%left MUL
%left ADD_SUB
%%
line    : matrix    {
						printf("Accepted\n");
						return 0;
					}
		;
matrix  : LSBR NUM ',' NUM RSBR     {
										$$.row = $2,
										$$.column = $4;
									}
		| matrix ADD_SUB matrix     {
	                                    if ($1.row == $3.row && $1.column == $3.column) {
											$$.row = $1.row;
											$$.column = $1.column;
										} else {
											sematic_error($2);
	                                        return 0;
	                                    }
	                                }
		| matrix MUL matrix         {
	                                    if ($1.column == $3.row) {
	                                        $$.row = $1.row;
	                                        $$.column = $3.column;
	                                    } else {
	                                        sematic_error($2);
	                                        return 0;
	                                    }
	                                }
		| matrix TRS                {
	                                    $$.row = $1.column;
	                                    $$.column = $1.row;
	                                }
		| LRBR matrix RRBR          {
	                                    $$.row = $2.row;
	                                    $$.column = $2.column;
	                                }
		;
%%
void sematic_error(int num_column) {
    printf("Semantic error on col %d\n", num_column);
}
void yyerror(const char *message) {
	printf("Syntax Error\n");
}
int main(int argc, char *argv[]) {
	yyparse();
	return 0;
}
