%option noyywrap
%{
	#include "CP-HW3-A.tab.h"
%}
%%
\n|([ \t]+)	        {}
0|([1-9][0-9]*)     {
						yylval.int_val = atoi(yytext);
						return NUMBER;
					}
"load"              { return LOAD; }
"add"               { return ADD; }
"sub"               { return SUB; }
"mul"               { return MUL; }
"mod"               { return MOD; }
"inc"               { return INC; }
"dec"               { return DEC; }
.                   {}
%%
