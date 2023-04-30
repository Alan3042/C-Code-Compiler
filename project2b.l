%{
#include <stdio.h>
#include <math.h>
#include "project2b.h"
#include "project2b.tab.h"
%}

%option noyywrap

IDENT [A-Z[A-Z0-9]*
NUM [1-9][0-9]*|0

%%
program return(PROGRAM);
begin   return(BEGINS);

end return(END);
do  return(DO);
var return(VAR);
as	return(AS);	
{NUM}+ { yylval.num = atoi(yytext); return(NUMBER);}	

{IDENT}+	{
		yylval.sval = malloc(strlen(yytext));
		strncpy(yylval.sval, yytext, strlen(yytext));
		return(IDENT);	
	}
false|true	return(BOOLLIT);	

writeInt	return(WRITEINT);
readInt 	return(READINT);	



if	return(IF);
then	return(THEN);
else	return(ELSE);
while return(WHILE);

int	return(INT);
bool 	return(BOOL);

"(" return(LP);
")" return(RP);
";" return(SC); 

":=" return (ASGN);

div	return(DIV);
mod	return(MOD);
"!="	return(NE);
"<="	return(LE);
">="	return(GE);
"*"|"+"|"-"|"="|"<"|">" return *yytext;	

[ \t\n]+ 

.	printf("Unrecognized character: %s\n", yytext);
%%

