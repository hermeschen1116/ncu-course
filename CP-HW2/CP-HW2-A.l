%{
	#define TAB fprintf(yyout, "\t");
	unsigned int indent_count = 0;
%}
sos			^[^\t\n\{\}]*
sos_tab		^\t+
eos			\n$
char		[^\t\n\{\}]*
left		\{
right		\}
%%
{sos}		{
				for (int i = 0; i < indent_count; i++) TAB;
				ECHO;
			}
{sos_tab}	{
				for (int i = 0; i < indent_count; i++) TAB;
			}
{eos}		{
				ECHO;
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
