%option noyywrap
%{
	#include "CP-BA3-A.tab.h"
%}
%%
\n                  {}
[ \t]+	            {}
"+"|"-"             { return *yytext; }
p|P                 { return 'P'; }
c|C                 { return 'C'; }
0|([1-9][0-9]*)     {
						yylval.int_val = atoi(yytext);
						return NUMBER;
					}
.                   {}
%%
