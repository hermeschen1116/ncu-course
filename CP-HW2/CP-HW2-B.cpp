#include <iostream>
#include <sstream>
#include <algorithm>
#include <vector>
#include <set>
#include <map>

using namespace std;

vector<string> string_split(const string &str, const char &sep);

string string_union(const string &str_1, const string &str_2);

void string_remove_all(string &str, const char &target);

bool vector_contain(const string &str, const vector<string> &source);

string rule(const string &rule, map<char, string> &first_set, map<char, vector<string> > grammars);

string first(const vector<string> &rules, map<char, string> &first_set, const map<char, vector<string> > &grammars);

map<char, string> first_set(const map<char, vector<string> > &grammars);

void show_first_set(const map<char, string> &first_set);

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

    sort(split_string.begin(), split_string.end());

    return split_string;
}

string string_union(const string &str_1, const string &str_2) {
    set<char> buffer_1(str_1.begin(), str_1.end());
    set<char> buffer_2(str_2.begin(), str_2.end());
    string union_string;

    set_union(buffer_1.begin(), buffer_1.end(), buffer_2.begin(), buffer_2.end(), inserter(union_string, union_string.begin()));

    return union_string;
}

void string_remove_all(string &str, const char &target) {
    str.erase(remove(str.begin(), str.end(), target), str.end());
}

bool vector_contain(const string &str, const vector<string> &source) {
    return find(source.begin(), source.end(), str) != source.end();
}

string rule(const string &rule, map<char, string> &first_set, map<char, vector<string> > grammars) {
    string rule_buffer, first_buffer;

    if (rule == ";" || rule == "$" || (rule.length() == 1 && islower(rule[0]))) return rule;
    for (char symbol: rule) {
        if (isupper(symbol)) {
            // non-terminal
            // if first set of this symbol not exists, build one
            if (first_set.find(symbol) == first_set.end()) {
                first_set[symbol] = first(grammars[symbol], first_set, grammars);
            }
            // if return first set is null, append empty string
            if (first_set[symbol] == ";" || first_set[symbol] == "$") rule_buffer = "";
            else rule_buffer = first_set[symbol];
            first_buffer = string_union(first_buffer, rule_buffer);
            // if non-terminal not nullable, remove all EOS then return
            if (first_set[symbol].find(';') || vector_contain("$", grammars[symbol])) {
                string_remove_all(first_buffer, ';');
                return first_buffer;
            }
        } else {
            // terminal, EOS(;), and EOF($)
            first_buffer = string_union(first_buffer, {symbol});
            // when symbol is terminal or EOF, remove all EOS
            if (symbol != ';') string_remove_all(first_buffer, ';');
            return first_buffer;
        }
    }

    return first_buffer;
}

string first(const vector<string> &rules, map<char, string> &first_set, const map<char, vector<string> > &grammars) {
    string rule_buffer, first_buffer;

    for (const string &r: rules) {
        first_buffer = string_union(first_buffer, rule(r, first_set, grammars));
    }

    if ((int) first_buffer.find('$') != -1) string_remove_all(first_buffer, ';');

    return first_buffer;
}

map<char, string> first_set(const map<char, vector<string> > &grammars) {
    map<char, string> first_set;

    for (const auto &grammar: grammars) {
        if (first_set.find(grammar.first) == first_set.end()) {
            first_set[grammar.first] = first(grammar.second, first_set, grammars);
        }
    }

    return first_set;
}

void show_first_set(const map<char, string> &first_set) {
    for (const auto &item: first_set) {
        cout << item.first << ' ' << item.second << endl;
    }
    cout << "END_OF_FIRST" << endl;
}
