#include <stdio.h>
#include <stdlib.h>
#include "project2b.h"
#include "project2b.tab.h"
#include "uthash.h"

void *genCode(Declaration *declaration, StatementSeq *stmtSeq);
void *gencodeDecl(Declaration *d);
void *gencodeType(Type *t);
void *gencodeStmtSeq(StatementSeq *s);
void *gencodeStmt(Statements *stmt);
void *gencodeAsgn(Assignment *asgn);
void *gencodeIf(IfStmt *ifStmt);
void *gencodeElse(ElseClause *e);
void *gencodeWhile(WhileStmt *w);
void *gencodeWrite(WriteInt *write);
void *gencodeExpr(Expr *exp);
void *gencodeSmplEx(SimpleExpr *smplEx);
void *gencodeTerm(Term *term);
void *gencodeFactor(Factor *fact);
void add_sym(int t, char *id);


typedef struct  {
    int type;
    char *ident; 
    UT_hash_handle hh;  
}symTabl;

symTabl *st = NULL;

int checkType = 0;


void *genCode(Declaration *declaration, StatementSeq *statementSeq){
        printf("#include <stdio.h>\n");
        printf("int main() {\n" );
        gencodeDecl(declaration);
        gencodeStmtSeq(statementSeq);
        printf("}\n");
}

void *gencodeDecl(Declaration *d) {
    while(d != NULL){
	    gencodeType(d->type);
	    printf(" ");
	    printf("%s", d->ident);
	    printf(";\n");
        if(d->type->type==1){
            //printf("int\n");
            add_sym(1, d->ident); 
        }
        if(d->type->type==2){
            //printf("bool\n");
            add_sym(2, d->ident);
        }
        d = d->declaration;
    }
    printf("\n");
    //printf("End of decl\n");
}

void *gencodeType(Type *t) {
    //printf("%d\n", t->type);
    if(t->type==1) {
        printf("\tint");
    }
    if(t->type==2)
        printf("\tbool");
}

void *gencodeStmtSeq(StatementSeq *s){
    while (s != NULL) {
        //printf("Printing statements\n");
        
	    gencodeStmt(s->statements);
        s = s->statementSeq;
    }
}


void *gencodeStmt(Statements *stmt) {
    if (stmt->assignment != NULL)
        gencodeAsgn(stmt->assignment);
    if (stmt->ifStmt != NULL)
        gencodeIf(stmt->ifStmt);
    if (stmt->whileStmt != NULL)
        gencodeWhile(stmt->whileStmt);
    if (stmt->writeInt != NULL)      
        gencodeWrite(stmt->writeInt);
}

void *gencodeAsgn(Assignment *asgn) { 

    symTabl *s;
    
 
    //printf("Print assign\n");
    if(asgn->readInt == 1) {
        HASH_FIND_STR(st, asgn->ident, s);
        if (s == NULL) {
            printf("\t%s", asgn->ident);
            printf("\nError. %s is undeclared.\n", asgn->ident);
            exit(1);
        }
        printf("\tscanf(\"%%d\", ");
        printf("&%s", asgn->ident);
        printf(");\n");
    }
    else {
        HASH_FIND_STR(st, asgn->ident, s);

        if (s == NULL) {
            printf("\t%s", asgn->ident);
            printf(" = ");
            gencodeExpr(asgn->expr);
            printf(";\n");
            printf("\nError. %s is undeclared.\n", asgn->ident);
            exit(1);
        } 
        checkType = s->type;
        printf("\t%s", asgn->ident);
        printf(" = ");
        gencodeExpr(asgn->expr);
        printf(";\n");
    }
}

void *gencodeIf(IfStmt *ifStmt) {	
	printf("\n\tif ( ");
	gencodeExpr(ifStmt->expr);
	printf(" ) {\n" );
	gencodeStmtSeq(ifStmt->statementSeq);
	printf("\t}\n");
    if (ifStmt->elseClause != NULL)
	    gencodeElse(ifStmt->elseClause);
}

void *gencodeElse(ElseClause *e) {
	 printf("\telse {\n\t");
	 gencodeStmtSeq(e->statementSeq);
	 printf("\t}\n");
}
void *gencodeWhile(WhileStmt *w) {
    printf("\n\twhile ( ");
	gencodeExpr(w->expr);
	printf(" ) {\n");
	gencodeStmtSeq(w->statementSeq);
	printf("\t}\n");	
}
void *gencodeWrite(WriteInt *write){
    printf("\tprintf(\"%%d\", ");
    gencodeExpr(write->expr);
    printf(");\n");
}
void *gencodeExpr(Expr *exp){
    //printf("Expr\n");
    gencodeSmplEx(exp->simpleExpr1);
    //printf(" ");
    //OP4
    switch(exp->oper) {
        case '=': printf(" = "); break;
        case NE: printf(" != "); break;
        case '<': printf(" < "); break;
        case '>': printf(" > "); break;
        case LE: printf(" <= "); break;
        case GE: printf(" >= "); break;        
    }
    //printf(" ");
    if (exp->simpleExpr2 != NULL)
        gencodeSmplEx(exp->simpleExpr2);
}
void *gencodeSmplEx(SimpleExpr *smplEx){
    //printf("SimpleExpr\n");
    gencodeTerm(smplEx->term1);
    //printf(" ");
    //OP3
    switch(smplEx->oper) {
        case '+': printf(" + "); break;
        case '-': printf(" - "); break;      
    }
    //printf(" ");
    if (smplEx->term2 != NULL)
        gencodeTerm(smplEx->term2);
}
void *gencodeTerm(Term *term){
    //printf("Term\n");
    gencodeFactor(term->factor1);
    //printf(" ");
    //OP2
    switch(term->oper) {
        case '*': printf(" * "); break;
        case DIV: printf(" / "); break;
        case MOD: printf(" %% "); break;      
    }
    //printf(" ");
    if(term->factor2 != NULL)
        gencodeFactor(term->factor2);
}
void *gencodeFactor(Factor *fact){
	//printf("Factor\n");
    //printf("Fact type: %d\n", fact->type);
    //printf("Fact ident: %s\n", fact->ident);
    symTabl *s;

	if(fact->type == 0) {
        HASH_FIND_STR(st, fact->ident, s);
        //printf("%d\n", s->type);
        if (s == NULL) {
            printf("%s", fact->ident);
            printf("\nError. %s is undeclared.\n", fact->ident);
            exit(1);
        }  
        printf("%s", s->ident);
    }
	if(fact->type == 1) {
        if (fact->numb < 0 || fact->numb > 2147483647) { 
            printf("%d", fact->numb);   
            printf("\nInteger overflow.\n");
            exit(1);
        }
        else if (checkType == 2) {
            printf("%d", fact->numb);
            printf("\nType mismatch. int cannot be assigned to bool.\n"); 
            exit(1);       
        }
		printf("%d", fact->numb);
    }
	if(fact->type == 2) {
        if (checkType == 1) {
            printf("%s", fact->boollit ? "true" : "false");
            printf("\nType mismatch. bool cannot be assigned to int.\n"); 
            exit(1);       
        }
		printf("%s", fact->boollit ? "true" : "false");
    }
	if(fact->type == 3){
        printf("( ");
	    gencodeExpr(fact->expr);
	    printf(" )\n");
    }   
}

void add_sym(int t, char *id){
    
    symTabl *s;
       
    //printf("Inserting\n");
    s = (symTabl *)malloc(sizeof *s);
    s->ident = id;
    s->type = t;
    //printf("Type: %d\n", s->sym.type);
    HASH_ADD_KEYPTR(hh, st, s->ident, strlen(s->ident), s);

    //printf("Ident: %s\n", st->sym.ident);
}
