#include <iostream>
#include <vector>
#include <sstream>
#include <map>
#include <algorithm>

using namespace std;

vector<string> string_split(const string &str, const char &sep);

string string_union(const string &str_1, const string &str_2);

string rule_extract(const string &str);

string rule_group(const string &str);

pair<char, string> grammar_extract(const string &str);

bool is_parsed(const string &rule);

string non_terminal_extract(const char &non_terminal, map<char, string> &grammars);

vector<char> get_map_key(map<char, string> &src_map);

void non_terminal_replace(map<char, string> &grammars);

map<char, string> first_set(const vector<string> &grammars);

void show_grammar(const pair<char, string> &grammar);

void show_first_set(const map<char, string> &first_set);

int main() {
    string grammar;
    vector<string> grammars;

    while (getline(cin, grammar)) {
        if (grammar == "END_OF_GRAMMAR") break;
        grammars.push_back(grammar);
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
    string union_string = str_1;

    for (int i = 0; i < (int) str_2.size(); i++) {
        if ((int) union_string.find(str_2[i]) == -1) union_string += str_2[i];
    }

    sort(union_string.begin(), union_string.end(), less<char>());

    return union_string;
}

string rule_extract(const string &str) {
    string rule;

    for (int i = 0; i < (int) str.size(); i++) {
        rule += str[i];
        if (islower(str[i])) break;
    }

    return rule;
}

string rule_group(const string &str) {
    vector<string> rules = string_split(str, '|');
    string group_rule;

    for (int i = 0; i < (int) rules.size(); i++) {
        if (i == 0) group_rule = rule_extract(rules[i]);
        else group_rule = string_union(group_rule, rule_extract(rules[i]));
    }
    sort(group_rule.begin(), group_rule.end(), less<char>());

    return group_rule;
}

pair<char, string> grammar_extract(const string &str) {
    vector<string> buffer = string_split(str, ' ');
    pair<char, string> grammar;

    grammar.first = buffer[0][0];
    grammar.second = rule_group(buffer[1]);

    return grammar;
}

bool is_parsed(const string &rule) {
    for (int i = 0; i < (int) rule.size(); i++) {
        if (isupper(rule[i])) return false;
    }
    return true;
}

string non_terminal_extract(const char &non_terminal, map<char, string> &grammars) {
    if (grammars[non_terminal] == ";") return "";
    return grammars[non_terminal];
}

vector<char> get_map_key(map<char, string> &src_map) {
    vector<char> key;

    for (map<char, string>::iterator it = src_map.begin(); it != src_map.end(); it++) {
        key.push_back(it->first);
    }

    return key;
}

void non_terminal_replace(map<char, string> &grammars) {
    vector<char> grammar_keys = get_map_key(grammars);
    vector<char> parsed, unparsed;
    string grammar_buffer, non_terminal_buffer, parse_buffer;

    for (int i = 0; i < (int) grammar_keys.size(); i++) {
        if (!is_parsed(grammars[grammar_keys[i]])) unparsed.push_back(grammar_keys[i]);
        else parsed.push_back(grammar_keys[i]);
    }

    while (true) {
        if (unparsed.empty()) break;
//        cout << "parsed: ";
//        for (int i = 0; i < (int) parsed.size(); i++) cout << parsed[i] << ' ';
//        cout << endl;
//        cout << "unparsed: ";
//        for (int i = 0; i < (int) unparsed.size(); i++) cout << unparsed[i] << ' ';
//        cout << endl;
        for (int i = 0; i < (int) unparsed.size(); i++) {
            parse_buffer = "";
            for (int j = (int) grammars[unparsed[i]].size() - 1; j >= 0; j--) {
                if (isupper(grammars[unparsed[i]][j])) {
                    if (find(parsed.begin(), parsed.end(), grammars[unparsed[i]][j]) != parsed.end()) {
                        non_terminal_buffer = non_terminal_extract(grammars[unparsed[i]][j], grammars);
//                        cout << unparsed[i] << ": " << parse_buffer << '+' << non_terminal_buffer << '=';
                        parse_buffer = string_union(parse_buffer, non_terminal_buffer);
//                        cout << parse_buffer << endl;
                    }
                } else {
                    if ((int) parse_buffer.find(grammars[unparsed[i]][j]) == -1) parse_buffer += grammars[unparsed[i]][j];
                }
            }
            sort(parse_buffer.begin(), parse_buffer.end(), less<char>());
            grammars[unparsed[i]] = parse_buffer;
            if (is_parsed(parse_buffer)) {
                parsed.push_back(unparsed[i]);
                unparsed.erase(find(unparsed.begin(), unparsed.end(), unparsed[i]));
            }
        }
    }
}

map<char, string> first_set(const vector<string> &grammars) {
    pair<char, string> grammar_buffer, main_grammar;
    map<char, string> first_set;

    for (int i = 0; i < (int) grammars.size(); i++) {
        grammar_buffer = grammar_extract(grammars[i]);
        first_set[grammar_buffer.first] = grammar_buffer.second;
    }
    main_grammar.first = 'S';
    main_grammar.second = first_set['S'];
    first_set.erase('S');

//    show_first_set(first_set);

    non_terminal_replace(first_set);

//    cout << "=======================================" << endl;

    first_set['S'] = main_grammar.second;

    non_terminal_replace(first_set);

    if ((int) first_set['S'].find('$') != -1) {
        first_set['S'].erase(remove(first_set['S'].begin(), first_set['S'].end(), ';'), first_set['S'].end());
    }


    return first_set;
}

void show_grammar(const pair<char, string> &grammar) {
    cout << grammar.first << ' ' << grammar.second << endl;
}

void show_first_set(const map<char, string> &first_set) {
    for_each(first_set.begin(), first_set.end(), show_grammar);
    cout << "END_OF_FIRST" << endl;
}
