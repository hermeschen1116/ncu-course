%{
	#define TAB fprintf(yyout, "\t");
	unsigned int indent_count = 0;
%}
sos			^\t*
eos			\n$
l_bracket	\{
r_bracket	\}
char		[^\n\{\}]
%%
{sos}		{
				fprintf(yyout, "%d", indent_count);
				// for (int i = 0; i < indent_count; i++) TAB;
			}
{eos}		{
				ECHO;
			}
{l_bracket}	{
				++indent_count;
				ECHO;
			}
{r_bracket}	{
				--indent_count;
				ECHO;
			}
{char}		{
				ECHO;
			}
%%
int main(int argc, char *argv[]) {
	yylex();
	return 0;
}
