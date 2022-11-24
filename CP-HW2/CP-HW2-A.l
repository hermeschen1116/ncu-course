%{
int indent_count = 0;
%}
left \{
right \}
eof \n
%%
{left} {indent_count++;}
{right} {indent_count--;}
%%
int main(int argc, char *argv[]) {
	yylex();
	printf("%d\n", indent_count);
	return 0;
}
