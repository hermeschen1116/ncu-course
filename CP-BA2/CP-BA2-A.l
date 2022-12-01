%{
	#define TAB fprintf(yyout, "\t");
    unsigned int indent_count = 0;
%}
tab                 \t+
single_comment      \/\/" "[^\/\/\n]*
multi_comments      \/\*\n(.*\n)*\*\/
print               cout" "<<" ".*" "<<" "endl;
condition           if\((true|false)\)" "
left                \{
right               \}
eos_right           \n\}
eos                 \n
%%
{tab}               {
						// do nothing
					}
{eos_right}		    {
						fprintf(yyout, "\n");
						--indent_count;
						for (int i = 0; i < indent_count; i++) TAB;
						fprintf(yyout, "}");
					}
{eos}			    {
						ECHO;
						for (int i = 0; i < indent_count; i++) TAB;
					}
{left}			    {
						++indent_count;
						fprintf(yyout, "left\n");
					}
{right}			    {
						--indent_count;
						fprintf(yyout, "right\n");
					}
{single_comment}    {
						fprintf(yyout, "single comment\n");
					}
{multi_comments}    {
                    	fprintf(yyout, "multi comments\n");
                    }
{print}             {
                    	fprintf(yyout, "print\n");
                    }
{condition}         {
                    	fprintf(yyout, "condition ");
                    }
%%
int main(int argc, char *argv[]) {
	yylex();
	return 0;
}
