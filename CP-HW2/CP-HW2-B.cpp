#include <iostream>
#include <vector>
#include <sstream>
#include <set>
#include <map>
#include <algorithm>

using namespace std;

vector<string> string_split(const string &str, const char &sep);

string string_union(const string &str_1, const string &str_2);

string char_to_string(char c);

string rule(const string& rule, map<char, string> first_set, map<char, vector<string> > grammars);

string first(const vector<string>& rules, const map<char, string>& first_set, const map<char, vector<string> >& grammars);

map<char, string> first_set(const map<char, vector<string> >& grammars);

void show_first_set(const map<char, string>& first_set);

int main() {
    string input;
    map<char, vector<string> > grammars;

    while (getline(cin, input)) {
        if (input == "END_OF_GRAMMAR") break;
        grammars[input[0]] = string_split(input.substr(2), '|');
    }

    show_first_set(first_set(grammars));

    return 0;
}

vector<string> string_split(const string &str, const char &sep) {
    stringstream spliter(str);
    string buffer;
    vector<string> split_string;

    while (getline(spliter, buffer, sep)) split_string.push_back(buffer);

    return split_string;
}

string string_union(const string &str_1, const string &str_2) {
    set<char> buffer_1(str_1.begin(), str_1.end());
    set<char> buffer_2(str_2.begin(), str_2.end());
    string union_string;

    set_union(buffer_1.begin(), buffer_1.end(), buffer_2.begin(), buffer_2.end(), inserter(union_string, union_string.begin()));

    return union_string;
}

string char_to_string(char c) {
    string string_buffer;

    return string_buffer + c;
}

string rule(const string& rule, map<char, string> first_set, map<char, vector<string> > grammars) {
    string first_buffer;

    for (char c: rule) {
        switch (c) {
            case ';':
            case '$':
                first_buffer = string_union(first_buffer, char_to_string(c));
                break;
            default:
                if (c >= 'a' && c <= 'z') {
                    first_buffer = string_union(first_buffer, char_to_string(c));
                    first_buffer.erase(remove(first_buffer.begin(), first_buffer.end(), ';'), first_buffer.end());
                    break;
                }
                if (c >= 'A' && c <= 'Z') {
                    if (first_set.find(c) != first_set.end()) {
                        first_buffer = string_union(first_buffer, first_set[c]);
                    } else {
                        first_set[c] = first(grammars[c], first_set, grammars);
                        first_buffer = string_union(first_buffer, first_set[c]);
                    }
                }
        }
    }

    if ((int) first_buffer.find('$') != -1) {
        first_buffer.erase(remove(first_buffer.begin(), first_buffer.end(), ';'), first_buffer.end());
    }

    return first_buffer;
}

string first(const vector<string>& rules, const map<char, string>& first_set, const map<char, vector<string> >& grammars) {
    string first_buffer;

    for (const string& r: rules) {
        first_buffer = string_union(first_buffer, rule(r, first_set, grammars));
    }

    if ((int) first_buffer.find('$') != -1) {
        first_buffer.erase(remove(first_buffer.begin(), first_buffer.end(), ';'),
                           first_buffer.end());
    }

    return first_buffer;
}

map<char, string> first_set(const map<char, vector<string> >& grammars) {
    map<char, string> first_set;

    for (const auto& grammar: grammars) {
        first_set[grammar.first] = first(grammar.second, first_set, grammars);
    }

    return first_set;
}

void show_first_set(const map<char, string>& first_set) {
    for (const auto& item: first_set) {
        cout << item.first << ' ' << item.second << endl;
    }
    cout << "END_OF_FIRST" << endl;
}
