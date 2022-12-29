%option noyywrap
%{
	#include "CP-HW3-B.tab.h"
	int loc = 0;
%}
%%
\n                  {}
[ \t]+	            { loc += yyleng; }
0|([1-9][0-9]*)	    {
						loc += yyleng;
						yylval.int_val = atoi(yytext);
						return DIM;
					}
"+"|"-"             {
						loc += yyleng;
						yylval.loc = loc;
						return ADD_SUB;
					}
"*"                 {
						loc += yyleng;
						yylval.loc = loc;
						return MUL;
					}
"("|")"|"["|"]"|"," {
						loc += yyleng;
						return *yytext;
					}
"^T"                {
						loc += yyleng;
						yylval.loc = loc;
						return TRS;
					}
.	                { loc += yyleng; }
%%
