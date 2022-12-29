clear
bison -d -o CP-HW3-B.tab.c CP-HW3-B.y
gcc -c -g -I.. CP-HW3-B.tab.c --std=c90
flex -o lex.yy.c CP-HW3-B.l
gcc -c -g -I.. lex.yy.c
gcc -o CP-HW3-B CP-HW3-B.tab.o lex.yy.o -ll --std=c90
for FILE in testcases_B/*.in; do echo $FILE && ./CP-HW3-B < $FILE; done
rm ./CP-HW3-B
rm ./CP-HW3-B.tab.c
rm ./CP-HW3-B.tab.h
rm ./CP-HW3-B.tab.o
rm ./lex.yy.c
rm ./lex.yy.o
