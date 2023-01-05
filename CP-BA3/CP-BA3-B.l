%option noyywrap
%{
	#include "CP-BA3-B.tab.h"
	int loc = 0;
%}
%%
\n          {}
[ \t]+      {}
"<true/>"   {
				yylval.val = 1;
				return BOOLEAN;
            }
"<false/>"  {
				yylval.val = 0;
				return BOOLEAN;
			}
"<not>"     { return 'N'; }
"<and>"     { return 'A'; }
"<or>"      { return 'O'; }
"</not>"    { return 'n'; }
"</and>"    { return 'a'; }
"</or>"     { return 'o'; }
.           {}
%%
