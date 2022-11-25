%{
	#define TAB fprintf(yyout, "\t");
	unsigned int indent_count = 0;
%}
sos				^\t*
left_start		\{[^\t\n\{]*
left_end		[^\t\n\{]*\{
right_start		\}[^\t\n\}]*
right_end		[^\t\n\}]*\}
eos				\n
%%
{sos}			{
					for (int i = 0; i < indent_count; i++) TAB;
				}
{left_start}	{
                	++indent_count;
                	ECHO;
                }
{left_end}		{
                	++indent_count;
                    ECHO;
                }
{right_start}	{
                	--indent_count;
                    ECHO;
                }
{right_end}		{
                	--indent_count;
                    ECHO;
                }
{eos}			{
                	ECHO;
                }
%%
int main(int argc, char *argv[]) {
	yylex();
	return 0;
}
