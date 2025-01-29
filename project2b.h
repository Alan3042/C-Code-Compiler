typedef struct factor {
	int type;
	int numb;
	char *ident;
	int boollit;
	struct expr *expr;
} Factor;

typedef struct term {
    int type;	
    int oper;
	Factor *factor1;
    Factor *factor2;
} Term;

typedef struct simpleExpr {
    int type;	
    int oper;
	Term *term1;
    Term *term2;
} SimpleExpr;

typedef struct expr {
    int type;
	int oper;
	SimpleExpr *simpleExpr1;
    SimpleExpr *simpleExpr2;
} Expr;

typedef struct writeInt {
	Expr *expr;
} WriteInt;

typedef struct whileStmt {
	Expr *expr;
	struct statementSeq *statementSeq;
} WhileStmt;

typedef struct elseClause {
	int oper; 
	struct statementSeq *statementSeq;
} ElseClause;

typedef struct ifStmt {
	int oper;
	Expr *expr;
	struct statementSeq *statementSeq;
	ElseClause *elseClause;
} IfStmt;

typedef struct assignment {
	char * ident;
	Expr *expr;
    int readInt;
} Assignment;

typedef struct statements {
	Assignment *assignment;
	IfStmt *ifStmt;
	WhileStmt *whileStmt;
	WriteInt *writeInt;
} Statements;

typedef struct statementSeq {
    Statements *statements;
    struct statementSeq *statementSeq;
} StatementSeq;

typedef struct type {
	int type;
} Type;

typedef struct declaration {
	char *ident;
	Type *type;
	struct declaration *declaration;
} Declaration;




