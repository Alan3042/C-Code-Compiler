Compiler project for CS 4386.

Instructions for compiling and running (Linux)
------------------------------------------------
Note: Be sure Flex and Bison are installed on your machine. Instructions to compile must be in BNF.

1. Compile the lexer using command "lex project2b.l"
2. Compile the parser by running command "yacc project2b.y -d"
3. Rename "y.tab.c" and "y.tab.h" to "project2b.tab.c" and "project2b.tab.h"
3. Run command "gcc project2b.c lex.yy.c project2b.tab.c"
4. Run "./a.out<instructions.txt"
5. Copy output to .c file and compile.
