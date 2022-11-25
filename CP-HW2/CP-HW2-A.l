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
{sos}		{
				for (int i = 0; i < indent_count; i++) TAB;
			}
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
				fprintf(yyout, "\}");
			}
%%
int main(int argc, char *argv[]) {
	yylex();
	return 0;
}
