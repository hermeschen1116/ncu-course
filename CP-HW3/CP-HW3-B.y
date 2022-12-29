%{
	#include <stdio.h>
	#include <stdlib.h>

	int yylex();
	void yyerror(const char *message);
	void semantic_error(int num_column);
%}
%union {
	int int_val, loc;
    struct def {
        int row, column;
    } matrix;
}
%type<matrix> expr
%token<int_val> DIM
%token<loc> ADD_SUB
%token<loc> MUL
%token<loc> TRS
%left ADD_SUB
%left MUL
%left TRS
%%
stmt    : expr      {
						printf("Accepted\n");
						return 0;
					}
		;
expr    : '[' DIM ',' DIM ']'       {
										$$.row = $4;
										$$.column = $2;
									}
		| expr ADD_SUB expr         {
	                                    if ($1.row == $3.row && $1.column == $3.column) {
											$$.row = $1.row;
											$$.column = $1.column;
										} else {
											semantic_error($2);
	                                        return 0;
	                                    }
	                                }
		| expr MUL expr             {
	                                    if ($1.row == $3.column) {
	                                        $$.row = $3.row;
	                                        $$.column = $1.column;
	                                    } else {
	                                        semantic_error($2);
	                                        return 0;
	                                    }
	                                }
		| expr TRS                  {
	                                    $$.row = $1.column;
	                                    $$.column = $1.row;
	                                }
		| '(' expr ')'              {
	                                    $$.row = $2.row;
	                                    $$.column = $2.column;
	                                }
		;
%%
void semantic_error(int num_column) {
    printf("Semantic error on col %d\n", num_column);
}
void yyerror(const char *message) {
	printf("Syntax Error\n");
}
int main(int argc, char *argv[]) {
	yyparse();
	return 0;
}
