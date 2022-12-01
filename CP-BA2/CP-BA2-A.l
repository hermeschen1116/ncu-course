%{

%}
single_comment  ^\t*\/\/ .*
multi_comments  ^\t*\/*\n.*\n\/\t*\/
print           ^cout << ".*" << endl;
condition       ^if\((true|false)\) \{\n.+\n\}
%%
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
                    	fprintf(yyout, "condition\n");
                    }
%%
int main(int argc, char *argv[]) {
	yylex();
	return 0;
}
