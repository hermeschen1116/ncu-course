#include <iostream>
#include <vector>

using namespace std;

bool isNumber (const char &char_arg);

bool isAlphabet (const char &char_arg);

vector<string> scanner(string source_text_arg);

void show_tokens(const vector<string> &tokens_arg);

// scanner
int main() {
    string source_text;
    vector<string> tokens;

    while (getline(cin, source_text)) {
        tokens.clear();
        tokens = scanner(source_text);
        show_tokens(tokens);
    }

    return 0;
}

bool isNumber (const char &char_arg) {
    return char_arg >= '0' && char_arg <= '9';
}

bool isAlphabet (const char &char_arg) {
    return char_arg >= 'a' && char_arg <= 'z' ||
           char_arg >= 'A' && char_arg <= 'Z';
}

vector<string> scanner(string source_text_arg) {
    int source_text_size = (int) source_text_arg.size();
    vector<string> tokens_ret;
    string buffer;

    if (!source_text_arg.empty()) {
        for (int i = 0; i < source_text_size; i++) {
            switch (source_text_arg[i]) {
                case ' ':
                    continue;
                case '+':
                    tokens_ret.emplace_back("OP +");
                    break;
                case '-':
                    tokens_ret.emplace_back("OP -");
                    break;
                case '*':
                    tokens_ret.emplace_back("OP *");
                    break;
                case '/':
                    tokens_ret.emplace_back("OP /");
                    break;
                case '=':
                    tokens_ret.emplace_back("OP =");
                    break;
                case '(':
                    tokens_ret.emplace_back("LPR");
                    break;
                case ')':
                    tokens_ret.emplace_back("RPR");
                    break;
                case '0':
                    tokens_ret.emplace_back("NUM 0");
                    break;
                default:
                    if (source_text_arg[i] >= '1' && source_text_arg[i] <= '9') {
                        buffer = "NUM ";
                        for (int j = i; j < source_text_size; j++) {
                            buffer += source_text_arg[j];
                            if (!isNumber(source_text_arg[j + 1])) {
                                tokens_ret.emplace_back(buffer);
                                i = j;
                                break;
                            }
                        }
                    } else if (isAlphabet(source_text_arg[i])) {
                        buffer = "ID ";
                        for (int j = i; j < source_text_size; j++) {
                            buffer += source_text_arg[j];
                            if (!isAlphabet(source_text_arg[j+1])) {
                                tokens_ret.emplace_back(buffer);
                                i = j;
                                break;
                            }
                        }
                    } else {
                        tokens_ret.clear();
                        return tokens_ret;
                    }
            }
        }
    }

    return tokens_ret;
}

void show_tokens(const vector<string> &tokens_arg) {
    if (!tokens_arg.empty()) {
        for (const auto &i: tokens_arg) cout << i << endl;
    } else {
        cout << "invalid output" << endl;
    }
}
