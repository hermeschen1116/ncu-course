%{
	#define TAB fprintf(yyout, "\t");
	unsigned int indent_count = 0;
%}
sos		^\t*
char	[^\t]
%%
{}
{sos}		{
				// do nothing
				// for (int i = 0; i < indent_count; i++) TAB;
			}
{char}		{
				ECHO;
			}
%%
int main(int argc, char *argv[]) {
	yylex();
	return 0;
}
