#include <iostream>
#include <vector>

using namespace std;

vector<string> scanner(string source_text_arg);

void show_tokens(const vector<string> &tokens_arg);

// scanner
int main() {
    string source_text;
    vector<string> tokens;

    while (cin >> source_text) {
        tokens.clear();
        tokens = scanner(source_text);
        show_tokens(tokens);
    }

    return 0;
}

vector<string> scanner(string source_text_arg) {
    int source_text_size = (int) source_text_arg.size();
    vector<string> tokens_ret;
    string num_buffer;

    if (!source_text_arg.empty()) {
        for (int i = 0; i < source_text_size; i++) {
            switch (source_text_arg[i]) {
                case '+':
                    tokens_ret.push_back("PLUS");
                    break;
                case '-':
                    tokens_ret.push_back("MINUS");
                    break;
                case '*':
                    tokens_ret.push_back("MUL");
                    break;
                case '/':
                    tokens_ret.push_back("DIV");
                    break;
                case '(':
                    tokens_ret.push_back("LPR");
                    break;
                case ')':
                    tokens_ret.push_back("RPR");
                    break;
                default:
                    num_buffer = "NUM ";
                    for (int j = i; j < source_text_size; j++) {
                        num_buffer += source_text_arg[j];
                        if (source_text_arg[j + 1] < '0' ||
                            source_text_arg[j + 1] > '9') {
                            tokens_ret.push_back(num_buffer);
                            i = j;
                            break;
                        }
                    }
            }
        }
    }

    return tokens_ret;
}

void show_tokens(const vector<string> &tokens_arg) {
    for (int i = 0; i < tokens_arg.size(); i++) cout << tokens_arg[i] << endl;
}
