#include <iostream>
#include <vector>
#include <algorithm>

using namespace std;

vector<string> scanner(const string &source_text_arg);

vector<string> vector_split(vector<string> vector_arg, int start_arg, int end_arg);

void parser(vector<string> tokens_arg);

bool stmts(vector<string> tokens_arg);

bool stmt(vector<string> tokens_arg);

bool primary(vector<string> tokens_arg);

bool primary_tail(vector<string> tokens_arg);

bool ID_validator(const string &text_arg);

bool STRLIT_validator(const string &text_arg);

bool letter_validator(const char &char_arg);

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
    int source_text_len = (int) source_text_arg.size(), target_pos = 0;
    string text_buffer;
    vector<string> token_ret;

    for (int i = 0; i < source_text_len; i++) {
        switch (source_text_arg[i]) {
            case ' ':
                break;
            case '(':
                token_ret.push_back("LBR (");
                break;
            case ')':
                token_ret.push_back("RBR )");
                break;
            case '.':
                token_ret.push_back("DOT .");
                break;
            case '"':
                target_pos = (int) source_text_arg.find('"', i + 1);
                if (target_pos == -1) {
                    token_ret.clear();
                    token_ret.push_back("invalid input");
                    return token_ret;
                }
                text_buffer = source_text_arg.substr(i, target_pos - i + 1);
                if (!STRLIT_validator(text_buffer)) {
                    token_ret.clear();
                    token_ret.push_back("invalid input");
                    return token_ret;
                }
                token_ret.push_back("STRLIT " + text_buffer);
                i = target_pos;
                break;
            default:
                for (int j = i; j < source_text_len; j++) {
                    if (source_text_arg[j + 1] == '(' || source_text_arg[j + 1] == ')' ||
                        source_text_arg[j + 1] == '.' || source_text_arg[j + 1] == '"' ||
                        source_text_arg[j + 1] == ' ' || j + 1 == source_text_len) {
                        target_pos = j;
                        break;
                    }
                }
                text_buffer = source_text_arg.substr(i, target_pos - i + 1);
                if (!ID_validator(text_buffer)) {
                    token_ret.clear();
                    token_ret.push_back("invalid input");
                    return token_ret;
                }
                token_ret.push_back("ID " + text_buffer);
                i = target_pos;
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
    if (!tokens_arg.empty() && tokens_arg[0] == "invalid input") cout << "invalid input" << endl;
    else {
        if (stmts(tokens_arg)) {
            for (int i = 0; i < tokens_arg.size(); i++) cout << tokens_arg[i] << endl;
        } else cout << "invalid input" << endl;
    }
}

bool stmts(vector<string> tokens_arg) {
    vector<string> vector_buffer;
    int target_pos = -1;

    if (tokens_arg.empty()) return true;
    if (tokens_arg[0].find("ID") != -1 || tokens_arg[0].find("STRLIT") != -1) {
        if (stmt(tokens_arg)) return true;
        for (int i = 0; i < tokens_arg.size()-1; i++) {
            vector_buffer = vector_split(tokens_arg, 0, i+1);
            if (!stmt(vector_buffer)) continue;
            vector_buffer = vector_split(tokens_arg, i + 1, (int) tokens_arg.size()-1);
            if (stmts(vector_buffer)) return true;
        }
        return false;
    }

    return false;
}

bool stmt(vector<string> tokens_arg) {
    if (tokens_arg.empty()) return true;
    if (tokens_arg[0].find("ID") != -1) return primary(tokens_arg);
    if (tokens_arg[0].find("STRLIT") != -1) return tokens_arg.size() == 1;

    return false;
}

bool primary(vector<string> tokens_arg) {
    vector<string> vector_buffer;

    if (tokens_arg[0].find("ID") != -1) {
        vector_buffer = vector_split(tokens_arg, 1, -1);
        return primary_tail(vector_buffer);
    }
    return false;
}

bool primary_tail(vector<string> tokens_arg) {
    vector<string> vector_buffer;
    int target_index;

    if (tokens_arg.empty()) return true;
    if (tokens_arg[0].find("DOT .") != -1) {
        if (tokens_arg[1].find("ID") == -1) return false;
        vector_buffer = vector_split(tokens_arg, 2, -1);
        return primary_tail(vector_buffer);
    }
    if (tokens_arg[0].find("LBR (") != -1) {
        vector<string>::iterator target_pos = find(tokens_arg.begin() + 1, tokens_arg.end(),
                                                   "RBR )");
        if (target_pos == tokens_arg.end()) return false;
        target_index = (int) distance(tokens_arg.begin(), target_pos);
        vector_buffer = vector_split(tokens_arg, 1, target_index);
        if (!stmt(vector_buffer)) return false;
        vector_buffer = vector_split(tokens_arg, target_index + 1, -1);
        return primary_tail(vector_buffer);
    }
    return false;
}

bool ID_validator(const string &text_arg) {
    if (number_validator(text_arg[0]) || !letter_validator(text_arg[0])) return false;
    for (int i = 1; i < text_arg.size(); i++) {
        if (!number_validator(text_arg[i]) && !letter_validator(text_arg[i])) return false;
    }
    return true;
}

bool STRLIT_validator(const string &text_arg) {
    for (int i = 1; i < text_arg.size() - 1; i++) {
        if (text_arg[i] == '"') return false;
    }
    return true;
}

bool letter_validator(const char &char_arg) {
    return (char_arg >= 'a' && char_arg <= 'z') || (char_arg >= 'A' && char_arg <= 'Z') ||
           char_arg == '_';
}

bool number_validator(const char &char_arg) {
    return char_arg >= '0' && char_arg <= '9';
}
