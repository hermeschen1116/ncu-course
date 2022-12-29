%option noyywrap
%{
	#include "CP-HW3-B.tab.h"
	int num_column = 0;
%}
%%
\n                  {}
[ \t]+	            { num_column += yyleng; }
"+"|"-"             { return ADD_SUB; }
"*"                 {
						num_column += yyleng;
						return MUL;
					}
"("                 {
						num_column += yyleng;
						return LRBR;
					}
")"	                {
						num_column += yyleng;
						return RRBR;
					}
"["                 {
						num_column += yyleng;
						return LSBR;
					}
"]"                 {
						num_column += yyleng;
						return RSBR;
					}
"^T"                {
						num_column += yyleng;
						return TRS;
					}
0|([1-9][0-9]*)	    {
						yylval.int_val = atoi(yytext);
						return NUM;
					}
.	                { return yytext[0]; }
%%
