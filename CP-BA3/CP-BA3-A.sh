clear
bison -d -o CP-BA3-A.tab.c CP-BA3-A.y
gcc -c -g -I.. CP-BA3-A.tab.c --std=c90
flex -o lex.yy.c CP-BA3-A.l
gcc -c -g -I.. lex.yy.c
gcc -o CP-BA3-A CP-BA3-A.tab.o lex.yy.o -ll --std=c90
for FILE in testcases_A/*.in; do echo $FILE && ./CP-BA3-A < $FILE; done
rm ./CP-BA3-A
rm ./CP-BA3-A.tab.c
rm ./CP-BA3-A.tab.h
rm ./CP-BA3-A.tab.o
rm ./lex.yy.c
rm ./lex.yy.o
