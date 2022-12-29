bison -d -o CP-HW3-A.tab.c CP-HW3-A.y
gcc -c -g -I.. CP-HW3-A.tab.c --std=c90
flex -o lex.yy.c CP-HW3-A.l
gcc -c -g -I.. lex.yy.c
gcc -o CP-HW3-A CP-HW3-A.tab.o lex.yy.o -ll --std=c90
for FILE in testcases_A/*.in; do echo $FILE && ./CP-HW3-A < $FILE; done
rm ./CP-HW3-A
rm ./CP-HW3-A.tab.c
rm ./CP-HW3-A.tab.h
rm ./CP-HW3-A.tab.o
rm ./lex.yy.c
rm ./lex.yy.o
