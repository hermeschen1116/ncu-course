/* C Definitions */
%{
	#define TAB fprintf(yyout, "\t");
	unsigned int indent_count = 0;
%}
/* LEX Definitions */
sos			^\t+
eos			\n$
l_bracket	\{
r_bracket	\}
sentence	[^\t\n\{\}]+
}
%%
/* Rules */
{sos}		{
				for (int i = 0; i < indent_count; i++) TAB;
			}
{eos}		{
				ECHO;
			}
{l_bracket}	{
				indent_count += 1;
			}
{r_bracket}	{
				indent_count -= 1;
			}
{sentence}	{
				ECHO;
			}
%%
/* Subroutine */
int main(int argc, char *argv[]) {
	yylex();
	return 0;
}
