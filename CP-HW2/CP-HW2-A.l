%{
	#define TAB fprintf(yyout, "\t");
	unsigned int indent_count = 0;
%}
tab 	^\t*
char 	[^\t]+
eos 	\n
left 	\{
right 	\}
%%
{tab}
{char}  ECHO;
{eos}	{
			ECHO;
			for (int i = 0; i < indent_count; i++) TAB;
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
