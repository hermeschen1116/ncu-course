clear
bison -d -o CP-BA3-B.tab.c CP-BA3-B.y
gcc -c -g -I.. CP-BA3-B.tab.c --std=c90
flex -o lex.yy.c CP-BA3-B.l
gcc -c -g -I.. lex.yy.c
gcc -o CP-BA3-B CP-BA3-B.tab.o lex.yy.o -ll --std=c90
for FILE in testcases_B/*.in; do echo $FILE && ./CP-BA3-B < $FILE; done
rm ./CP-BA3-B
rm ./CP-BA3-B.tab.c
rm ./CP-BA3-B.tab.h
rm ./CP-BA3-B.tab.o
rm ./lex.yy.c
rm ./lex.yy.o
