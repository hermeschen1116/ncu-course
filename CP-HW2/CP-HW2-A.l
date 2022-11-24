%{
	unsigned int indent_count = 0;
%}
tab 	^\t*
char 	[^\t\{\}]+
eos 	\n
left 	\{
right 	\}
%%
{tab}	{
			fprintf(yyout, "");
		}
{char}  ECHO;
{eos}	{
			ECHO;
			for (int i = 0; i < indent_count; i++) fprintf(yyout, "\t");
		}
{left} 	{
			indent_count++;
			ECHO;
		}
{right} {
			indent_count--;
			ECHO;
		}
%%
int main(int argc, char *argv[]) {
	yylex();
	return 0;
}
