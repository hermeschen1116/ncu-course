#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

vector<string> scanner(const string &source_text_arg);

vector<string> vector_split(vector<string> vector_arg, int start_arg, int end_arg);

void parser(vector<string> tokens_arg);

bool Stmt(const vector<string> &tokens_arg);

bool Class(vector<string> tokens_arg);

bool Func(vector<string> tokens_arg);

bool Args(const vector<string> &tokens_arg);

bool funcName_validator(const char &char_arg);

bool className_validator(const char &char_arg);

bool number_validator(const char &char_arg);

// parser
int main() {
    string source_text;
    vector<string> tokens;

    while (getline(cin, source_text)) {
        tokens = scanner(source_text);
        parser(tokens);
        tokens.clear();
    }

    return 0;
}

vector<string> scanner(const string &source_text_arg) {
    int source_text_len = (int) source_text_arg.size();
    vector<string> token_ret;
    string buffer;

    for (int i = 0; i < source_text_len; i++) {
        switch (source_text_arg[i]) {
            case ' ':
                continue;
            case '(':
                token_ret.emplace_back("leftParen (");
                break;
            case ')':
                token_ret.emplace_back("rightParen )");
                break;
            default:
                if (funcName_validator(source_text_arg[i])) buffer = "funcName ";
                else if (className_validator(source_text_arg[i])) buffer = "className ";
                else if (number_validator(source_text_arg[i])) buffer = "num ";
                else {
                    token_ret.clear();
                    return {"Invalid input"};
                }
                token_ret.emplace_back(buffer + source_text_arg[i]);
        }
    }

    return token_ret;
}

vector<string> vector_split(vector<string> vector_arg, int start_arg, int end_arg) {
    vector<string> vector_split_ret;

    if (end_arg == -1) end_arg = (int) vector_arg.size();
    if (start_arg <= end_arg && start_arg >= 0 && end_arg <= (int) vector_arg.size()) {
        for (int i = start_arg; i < end_arg; i++) vector_split_ret.push_back(vector_arg[i]);
    }
    return vector_split_ret;
}

void parser(vector<string> tokens_arg) {
    if (!tokens_arg.empty() && tokens_arg[0] == "Invalid input") cout << "Invalid input" << endl;
    else {
        if (Stmt(tokens_arg)) {
            for (auto &i: tokens_arg) cout << i << endl;
        } else cout << "Invalid input" << endl;
    }
}

bool Stmt(const vector<string> &tokens_arg) {
    if (Class(tokens_arg)) return true;
    return Func(tokens_arg);
}

bool Class(vector<string> tokens_arg) {
    if (tokens_arg.size() < 3) return false;
    if (tokens_arg[0].substr(0, 9) != "className" || tokens_arg[1] != "leftParen (" ||
        tokens_arg[2] != "rightParen )")
        return false;
    return Args(vector_split(tokens_arg, 3, -1));
}

bool Func(vector<string> tokens_arg) {
    if (tokens_arg.size() < 3) return false;
    if (tokens_arg[0] != "leftParen (" || tokens_arg[1].substr(0, 8) != "funcName" ||
        tokens_arg.back() != "rightParen )")
        return false;
    return Args(vector_split(tokens_arg, 2, (int) tokens_arg.size() - 1));
}

bool Args(const vector<string> &tokens_arg) {
    vector<string> vector_buffer;

    if (tokens_arg.empty()) return true;
    else if (tokens_arg[0].substr(0, 3) == "num") {
        if (tokens_arg.size() == 1) return true;
        vector_buffer = vector_split(tokens_arg, 1, -1);
        return Args(vector_buffer);
    } else if (tokens_arg[0].substr(0, 11) == "leftParen (") {
        for (int i = 0; i < tokens_arg.size(); i++) {
            if (tokens_arg[i] == "rightParen )") {
                vector_buffer = vector_split(tokens_arg, 0, i + 1);
                if (Func(vector_buffer)) {
                    vector_buffer = vector_split(tokens_arg, i + 1, -1);
                    if (Args(vector_buffer)) return true;
                }
            }
        }
        return false;
    } else return false;
}

bool funcName_validator(const char &char_arg) {
    return char_arg >= 'a' && char_arg <= 'z';
}

bool className_validator(const char &char_arg) {
    return char_arg >= 'A' && char_arg <= 'Z';
}

bool number_validator(const char &char_arg) {
    return char_arg >= '0' && char_arg <= '9';
}
