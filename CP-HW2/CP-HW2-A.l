%{
	#define TAB fprintf(yyout, "\t");
	unsigned int indent_count = 0;
%}
sos 		^\t*
char 		[^\{\}]
left 		\{
right_e 	\}$
right_s		^\t+\}
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
%%
int main(int argc, char *argv[]) {
	yylex();
	return 0;
}
