%{
	#define TAB fprintf(yyout, "\t");
	unsigned int indent_count = 0;
%}
sos			^\t*
char		[^\t\{\}]
l_bracket	\{
r_bracket	\}
%%
{}
{sos}			{
					// do nothing
					fprintf(yyout, "%d", indent_count);
				}
{char}			{
					ECHO;
				}
{l_bracket}		{
					++indent_count;
					ECHO;
				}
{r_bracket}		{
					--indent_count;
					ECHO;
				}
%%
int main(int argc, char *argv[]) {
	yylex();
	return 0;
}
