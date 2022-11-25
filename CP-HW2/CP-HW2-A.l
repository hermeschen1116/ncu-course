%{
	#define TAB fprintf(yyout, "\t");
	unsigned int indent_count = 0;
%}
tab		\t*
eos		\n
char	[^\t\n\{\}]*
left	\{
right	\}
%%
{tab}		{
				\\ do nothing
			}
{eos}		{
				ECHO;
				for (int i = 0; i < indent_count; i++) TAB;
			}
{char}		{
				ECHO;
			}
{left}		{
				++indent_count;
				ECHO;
			}
{right}		{
				--indent_count;
               	ECHO;
			}
%%
int main(int argc, char *argv[]) {
	yylex();
	return 0;
}
