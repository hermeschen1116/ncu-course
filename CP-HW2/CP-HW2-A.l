%{
	#define TAB fprintf(yyout, "\t");
	unsigned int indent_count = 0;
%}
sos 		^\t*
char 		[^\n\{\}]
left 		\{
right_e 	\}
right_s		^\t+\}
eos			\n$
%%
{char}  	{
				ECHO;
			}
{left} 		{
				indent_count++;
				ECHO;
			}
{right_e} 	{
				indent_count--;
				ECHO;
			}
{right_s}	{
				for (int i = 0; i < --indent_count; i++) TAB;
				fprintf(yyout, "}");
			}
{sos}		{
				for (int i = 0; i < indent_count; i++) TAB;
			}
{eos}		{
				fprintf(yyout, "%d\n", indent_count);
			}
%%
int main(int argc, char *argv[]) {
	yylex();
	return 0;
}
