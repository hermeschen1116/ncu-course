#include<iostream>
#include<string>
#include<list>

using namespace std;

list<string> nTml[26];
list<char> result[26];

void first(char current) {
    if (nTml[current - 'A'].empty()) {
        return;
    }
    for (list<string>::iterator it = nTml[current - 'A'].begin(); it != nTml[current - 'A'].end(); it++) {
        bool thenext = true;
        for (string::iterator sit = (*it).begin(); sit != (*it).end() && thenext; sit++) {
            thenext = false;
            if (*sit >= 'A' && *sit <= 'Z') {
                if (result[*sit - 'A'].empty()) {
                    first(*sit);
                }
                for (list<char>::iterator cit = result[*sit - 'A'].begin(); cit != result[*sit - 'A'].end(); cit++) {
                    if (*cit == ';') {
                        if (sit == (*it).end() - 1) {
                            result[current - 'A'].push_back(*cit);
                        }
                        thenext = true;
                    } else {
                        result[current - 'A'].push_back(*cit);
                    }
                }
            } else if ((*sit >= 'a' && *sit <= 'z') || *sit == '$') {
                result[current - 'A'].push_back(*sit);
            } else if (*sit == ';') {
                thenext = true;
                result[current - 'A'].push_back(*sit);
            }
        }
    }
    result[current - 'A'].sort();
    result[current - 'A'].unique();
}

int main(void) {
    while (!cin.eof()) {
        char lToken;
        string rToken;
        cin >> lToken >> rToken;
        nTml[lToken - 'A'].push_back(rToken);
    }

    for (char i = 'A'; i <= 'Z'; i++) {
        first(i); //look every non-terminal rules
    }

    for (char i = 'A'; i <= 'Z'; i++) {
        if (result[i - 'A'].empty()) {
            continue;
        }
        cout << i << " ";
        for (list<char>::iterator it = result[i - 'A'].begin(); it != result[i - 'A'].end(); it++) {
            cout << *it;
        }
        cout << endl;
    }

    return 0;
}
