%{
	#define CLEAN fprintf(yyout, "");
	#define TAB fprintf(yyout, "%c", '\t');
	unsigned int indent_count = 0;
%}
tab 	^\t*
char 	.[^\{\}]
eos 	\n
left 	\{
right 	\}
%%
{tab}	{
			CLEAN;
		}
{char}  {
			ECHO;
		}
{eos}	{
			ECHO;
			for (int i = 0; i < indent_count; i++) TAB;
		}
{left} 	{
			indent_count += 1;
			ECHO;
		}
{right} {
			indent_count -= 1;
			ECHO;
		}
%%
int main(int argc, char *argv[]) {
	yylex();
	printf("%d", indent_count);
	return 0;
}
