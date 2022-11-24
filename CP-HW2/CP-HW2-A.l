%{
	unsigned int indent_count = 0;
%}
tab 	^\t*
char 	[^\t]+
eos 	\n
left 	\{
right 	\}
%%
{tab}	{
			fprintf(yyout, "%s", "");
		}
{char}  ECHO;
{eos}	{
			ECHO;
			for (int i = 0; i < indent_count; i++) fprintf(yyout, "%s", "\t");
		}
{left} 	{
			indent_count++;
		}
{right} {
			indent_count--;
		}
%%
int main(int argc, char *argv[]) {
	yylex();
	return 0;
}
