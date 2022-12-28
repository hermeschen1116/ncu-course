%option noyywrap
%{
	#include "CP-HW3-A.tab.h"
%}
%%
\n                  {}
[ \t]+	            {}
"add"               { return ADD; }
"sub"               { return SUB; }
"mul"               { return MUL; }
"mod"               { return MOD; }
"inc"               { return INC; }
"dec"               { return DEC; }
"load"              { return LOAD; }
0|([1-9][0-9]*)     {
						yylval.int_val = atoi(yytext);
						return(INUMBER);
					}
.	                { return(yytext[0]); }
<<EOF>>             { return END_OF_FILE; }
%%
