%{
	#define TAB fprintf(yyout, "\t");
	unsigned int indent_count = 0;
%}
sos				^[^\t\n\{\}]
tab				^\t+
eos_right		\n\}
eos				\n
char			[^\t\n\{\}]*
left			\{
right			\}
%%
{tab}			{
					for (int i = 0; i < indent_count; i++) TAB;
				}
{eos_right}		{
					fprintf(yyout, "\n");
					--indent_count;
					for (int i = 0; i < indent_count; i++) TAB;
					fprintf(yyout, "}");
				}
{eos}			{
					ECHO;
					for (int i = 0; i < indent_count; i++) TAB;
				}
{char}			{
					ECHO;
				}
{left}			{
					++indent_count;
					ECHO;
				}
{right}			{
					--indent_count;
					ECHO;
				}
%%
int main(int argc, char *argv[]) {
	yylex();
	return 0;
}
