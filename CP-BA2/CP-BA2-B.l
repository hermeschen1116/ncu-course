%{
	#define EOS fprintf(yyout, "\n");
    #define ID fprintf(yyout, "identity number: ");
    #define EMAIL fprintf(yyout, "email: ");
    #define BIRTHDAY fprintf(yyout, "birthday: ");
    #define PHONE fprintf(yyout, "phone: ");
%}
name_head   ^[A-Z]+", "[A-Z][a-z]+-[A-Z][a-z]+
name        [A-Z]+", "[A-Z][a-z]+-[A-Z][a-z]+
birthday    [1-9][0-9]*\/((0[13578]|10|12)\/(0[1-9]|[12][0-9]|30|31)|(0[469]|11)\/(0[1-9]|[12][0-9]|30)|02\/(0[1-9]|[12][0-9]))
id_num      [A-Z](1|2)[0-9]{8}
email       [0-9]+@[a-z.]+[a-z]+
phone       \+886[0-9]{9}
%%
{name_head} {
				ECHO;
                EOS;
            }
{name}      {
				EOS;
            	ECHO;
                EOS;
			}
{birthday}  {
				BIRTHDAY;
				ECHO;
				EOS;
			}
{id_num}    {
				ID;
				ECHO;
                EOS;
			}
{email}     {
				EMAIL;
				ECHO;
                EOS;
			}
{phone}     {
				PHONE;
				ECHO;
                EOS;
			}
%%
int main(int argc, char *argv[]) {
	yylex();
	return 0;
}
