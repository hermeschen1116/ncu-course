%{
	#include <string.h>
	#include "CP-HW3-A.tab.h"
%}
load        0|([1-9][0-9]*)
operator    add|sub|mul|mod|inc|dec
%%
{load}      {
				ECHO;
				yylval.int_val = atoi(yytext);
				return (INTEGER);
			}
{operator}  {
				ECHO;
				strcpy(yylval.operand, yytext);
				return (OPERAND);
			}
%%
