#!/usr/local/bin/zsh
g++ CP-HW2-B.cpp -o tmp
for FILE in CP-HW2-B/*.in; do echo $FILE && ./tmp < $FILE ; done
rm ./tmp
