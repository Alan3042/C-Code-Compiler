%{
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <stdbool.h>
#include "uthash.h"
#include "project2b.h"
Factor *factor(int type, int numb, char *ident, int boollit, Expr *expr);
Term *term(int type, int oper,  Factor *factor1, Factor *factor2);
SimpleExpr *simpleExpr(int type, int oper,  Term *term1, Term *term2);
Expr *expr(int type, int oper, SimpleExpr *simpleExpr1, SimpleExpr *simpleExpr2);
WriteInt *writeInt(Expr *expr);
WhileStmt *whileStmt(Expr *expr, StatementSeq *statementSeq);
ElseClause *elseClause(int oper, StatementSeq *statementSeq);
IfStmt *ifStmt(int oper, Expr *expr, StatementSeq *statementSeq, ElseClause *elseClause);
Assignment *assignment(char *ident, Expr *expr, int readInt);
Statements *statements(Assignment *assignment, IfStmt *ifStmt, WhileStmt *whileStmt, WriteInt *writeInt);
StatementSeq *statementSeq(Statements *statements, StatementSeq *statementSeq);
Type *type(int intType, int boolType);
Declaration *declaration(char *ident, Type *type, Declaration *declaration);


int yylex(void);
int yyerror(char *);


%}

%union
{
	int num;
	char *sval;
    Declaration *declPtr;
    Type *typePtr;
    StatementSeq *ssPtr;
    Statements *sPtr;
    Assignment *asgnPtr;
    IfStmt *ifPtr;
    ElseClause *elsePtr;
    WhileStmt *whilePtr;
    WriteInt *writePtr;
    Expr    *exPtr;
    SimpleExpr *sePtr;
    Term    *termPtr;
    Factor  *factPtr;
};
%token <sval> IDENT
%token BOOLLIT
%token <num> NUMBER
%token END
%token DO
%token VAR
%token AS
%token WRITEINT
%token READINT
%token PROGRAM
%token LP
%token RP
%token SC
%token ASGN
%token INT
%token BOOL 
%token OP2
%token OP3
%token OP4
%token IF
%token THEN
%token ELSE
%token WHILE
%token PROCEDURE 
%token BEGINS

%left '=' NE '<' '>' LE GE 
%left '+' '-'
%left '*' DIV MOD 

%type <factPtr> Factor
%type <termPtr> Term
%type <sePtr> SimpleExpr
%type <exPtr> Expr
%type <writePtr> WriteInt
%type <whilePtr> WhileStmt
%type <elsePtr> ElseClause 
%type <ifPtr> IfStmt
%type <asgnPtr> Assignment
%type <sPtr> Statements 
%type <ssPtr> StatementSeq
%type <typePtr> Type
%type <declPtr> Declaration

%start Program 
%%

Program:
	PROGRAM Declaration BEGINS StatementSeq END { genCode($2, $4); }
	;
Assignment:
	IDENT ASGN Expr		{$$ = assignment($1, $3, 0);}
	| IDENT ASGN READINT	{$$ = assignment($1, NULL, 1);} 
	;

Declaration:
        VAR IDENT AS Type SC Declaration {
                                       // printf("%s\n", $2); 
                                        $$ = declaration($2, $4, $6);}
	| {$$ = NULL;} 
	;
Type:
    	INT {
               // printf("int\n"); 
                $$ = type(1, 0);} 
        | BOOL {
                //printf("bool\n"); 
                $$ = type(0, 1);}
	;

StatementSeq:
	Statements SC StatementSeq {$$ = statementSeq($1, $3);}
	| {$$ = NULL;}
	;

Statements:
	Assignment {$$ = statements($1, NULL, NULL, NULL);}
	| IfStmt    {$$ = statements(NULL, $1, NULL, NULL);}
	| WhileStmt {$$ = statements(NULL, NULL, $1, NULL);}
	| WriteInt {$$ = statements(NULL, NULL, NULL, $1);}
	;
IfStmt:
	IF Expr THEN StatementSeq ElseClause END{$$ = ifStmt(IF, $2, $4, $5);} 
	;
ElseClause:
    	ELSE StatementSeq {$$ = elseClause(ELSE, $2);} 
	| {$$ = NULL;}
	;

WhileStmt:
	WHILE Expr DO StatementSeq END {$$ = whileStmt($2, $4);} 
	;

WriteInt:
	WRITEINT Expr {$$ = writeInt($2);}
	;

Expr:
	SimpleExpr '='  SimpleExpr {$$ = expr(2, '=', $1, $3);}
	| SimpleExpr NE  SimpleExpr {$$ = expr(2, NE, $1, $3);}
	| SimpleExpr '<'  SimpleExpr {$$ = expr(2, '<', $1, $3);}
	| SimpleExpr '>'  SimpleExpr {$$ = expr(2, '>', $1, $3);}
	| SimpleExpr LE  SimpleExpr {$$ = expr(2, LE, $1, $3);}
	| SimpleExpr GE SimpleExpr {$$ = expr(2, GE, $1, $3);}
	| SimpleExpr {$$ = expr(1, ' ', $1, NULL);}
	;
SimpleExpr:
   	Term '+' Term {$$ = simpleExpr(2, '+', $1, $3);} 
	| Term '-' Term {$$ = simpleExpr(2, '-', $1, $3);} 
	| Term {$$ = simpleExpr(1, ' ', $1, NULL);}
	;
Term:
   	Factor '*' Factor {$$ = term(2, '*', $1, $3);} 
	| Factor DIV Factor {$$ = term(2, DIV, $1, $3);} 
	| Factor MOD Factor {$$ = term(2, MOD, $1, $3);} 
	| Factor {$$ = term(1, ' ', $1, NULL);}
	;
Factor:
      	IDENT	{$$ = factor(0, 0, $1, 0, NULL);}
  	| NUMBER {$$ = factor(1, $1, "", 0, NULL);}
	| BOOLLIT {$$ = factor(2, 0, "", BOOLLIT, NULL);}
	| LP Expr RP {$$ = factor(3, 0, "", 0, $2);}
	;
%%

Factor *factor(int type, int numb, char *ident, int boollit, Expr *expr) {
	Factor *p;
	if ((p = malloc(sizeof(Factor))) == NULL)
		yyerror("out of memory");
    //printf("Factor size: %ld\n", sizeof(p));
    //printf("Type: %d\n", type);
    //printf("Numb: %d\n", numb);
    //printf("Ident: %s\n", ident);
    //printf("Boollit: %d\n", boollit);
	p->type = type;
	p->ident = ident;   
    //printf("%s\n", p->ident);
	p->boollit = boollit;
	p->numb = numb;
    //printf("%d\n", p->numb);
	p->expr = expr;
	
	return p;
}
Term *term(int type, int oper,  Factor *factor1, Factor *factor2) {
    Term *p;
	if ((p = malloc(sizeof(Term))) == NULL)
		yyerror("out of memory");
    //printf("Type: %d\n", type);
    //printf("Oper: %d\n", oper);
    p->type = type;	
    p->oper = oper;
	p->factor1 = factor1;
    p->factor2 = factor2;
  

	return p;
}
SimpleExpr *simpleExpr(int type, int oper,  Term *term1, Term *term2){
	SimpleExpr *p;
	if ((p = malloc(sizeof(SimpleExpr))) == NULL)
		yyerror("out of memory");
    //printf("Type: %d\n", type);
    //printf("Oper: %d\n", oper);
    p->type = type;
	p->oper = oper;
  	p->term1 = term1;
    p->term2 = term2;

	return p;
}
Expr *expr(int type, int oper, SimpleExpr *simpleExpr1, SimpleExpr *simpleExpr2) {
   Expr *p;
	if ((p = malloc(sizeof(Expr))) == NULL)
		yyerror("out of memory");
    //printf("Type: %d\n", type);
    //printf("Oper: %d\n", oper);
    p->type = type;
	p->oper = oper;
    //printf("%d\n", p->oper);
    //printf("%c\n", (char)p->oper);
  	p->simpleExpr1 = simpleExpr1;
    p->simpleExpr2 = simpleExpr2;

	return p;

}
WriteInt *writeInt(Expr *expr){
	WriteInt *p;
	if ((p = malloc(sizeof(WriteInt))) == NULL)
		yyerror("out of memory");
	p->expr = expr;

	return p;
}
WhileStmt *whileStmt(Expr *expr, StatementSeq *statementSeq){
	WhileStmt *p;
	if ((p = malloc(sizeof(WhileStmt))) == NULL)
		yyerror("out of memory");
	p->expr = expr;
	p->statementSeq = statementSeq;

	return p;
}
ElseClause *elseClause(int oper, StatementSeq *statementSeq){
	ElseClause *p;
	if ((p = malloc(sizeof(ElseClause))) == NULL)
		yyerror("out of memory");
	p->oper = oper;
	p->statementSeq = statementSeq;

	return p;
}
IfStmt *ifStmt(int oper, Expr *expr, StatementSeq *statementSeq, ElseClause *elseClause){
	IfStmt *p;
	if ((p = malloc(sizeof(IfStmt))) == NULL)
		yyerror("out of memory");
	p->oper = oper;
	p->expr = expr;
	p->statementSeq = statementSeq;
	p->elseClause = elseClause;

	return p;
}

Assignment *assignment(char *ident, Expr *expr, int readInt){
	Assignment *p;
	if ((p = malloc(sizeof(Assignment))) == NULL)
		yyerror("out of memory");
    //printf("Asgn Ident: %s\n", ident);
	p->ident = ident;
    //printf("%s\n", p->ident);
	p->expr= expr;
    p->readInt = readInt;

	return p;
}
Statements *statements(Assignment *assignment, IfStmt *ifStmt, WhileStmt *whileStmt, WriteInt *writeInt){
	Statements *p;
	if ((p = malloc(sizeof(Statements))) == NULL)
		yyerror("out of memory");
	p->assignment = assignment;
	p->ifStmt = ifStmt;
	p->whileStmt = whileStmt;
	p->writeInt = writeInt;

	return p;
}
StatementSeq *statementSeq(Statements *statements, StatementSeq *statementSeq){
	StatementSeq *p;
   // printf("Size of StmtSeq: %ld\n", sizeof(StatementSeq));
	if ((p = malloc(sizeof(StatementSeq))) == NULL)
		yyerror("out of memory");
	p->statements = statements;
	p->statementSeq = statementSeq;

	return p;
}
Type *type(int intType, int boolType){
	Type *p;
    //printf("Size of type: %ld\n", sizeof(Type));
	if ((p = malloc(sizeof(Type))) == NULL)
		yyerror("out of memory");
	p->intType = intType;
	p->boolType = boolType;

	return p;
}
Declaration *declaration(char *ident, Type *type, Declaration *declaration){
	Declaration *p;
    //printf("Size of Declaration: %ld\n", sizeof(Declaration));
	if ((p = malloc(sizeof(Declaration))) == NULL)
		yyerror("out of memory");
	p->ident= ident;
	p->type = type;
	p->declaration = declaration;

	return p;
}


int yyerror(char *s) {
	printf("yyerror: %s\n", s);
}
int main(void) {
	yyparse();
	printf("SUCCESS\n");
}


