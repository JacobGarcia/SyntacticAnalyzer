/*************************************************************************/
/*                         Declaration Section                           */
/*************************************************************************/
%{
	#include <stdio.h>  
	#include <stdlib.h>
	#include <string.h>

	/* Function definitions */
	void yyerror (char *string);

	extern int yylex(void); /* Function from Flex that Bison needs to know about */
	extern int numberLines; /* Counter of newlines. Defined in Flex */
	extern char *yytext;
%}

%union{
	int intVal;
	float floatVal;
}

/*************************************************************************/
/*     			Terminal Symbols BISON Declaration Section               */
/*************************************************************************/
%token <intVal> INT_NUM
%token <floatVal> FLOAT_NUM
%token ID
%token LBRACE
%token RBRACE
%token LPAREN
%token RPAREN
%token SEMICOLON
%token IF
%token THEN
%token ELSE
%token INT
%token FLOAT
%token WHILE
%token DO
%token READ
%token WRITE
%token PLUS
%token MINUS
%token TIMES
%token DIV
%token ASSIGNMENT
%token RELATIONAL

%nonassoc NOT_ELSE
%nonassoc ELSE

/*************************************************************************/
/*                         	Grammar Rules Section                        */
/*************************************************************************/
%%
program: var_dec stmt_seq
		 ;

var_dec: var_dec single_dec 
		 | epsilon 
		 ;

single_dec: type ID SEMICOLON 
			;

type: INT 
	  | FLOAT 
	  ;

stmt_seq: stmt_seq stmt
		  | epsilon 
		  ;

stmt: IF exp THEN stmt %prec NOT_ELSE
	  | IF exp THEN stmt ELSE stmt
	  | WHILE exp DO stmt  
	  | variable ASSIGNMENT exp SEMICOLON
	  | READ LPAREN variable RPAREN SEMICOLON
	  | WRITE LPAREN exp RPAREN SEMICOLON
	  | block
	  ;

block: LBRACE stmt_seq RBRACE
	   ;

exp: simple_exp RELATIONAL simple_exp
	 | simple_exp
	 ;

simple_exp: simple_exp PLUS term 
			| simple_exp MINUS term 
			| term
			;

term: term TIMES factor
	  | term DIV factor  
	  | factor
	  ;

factor: LPAREN exp RPAREN 
		| INT_NUM 
		| FLOAT_NUM  
		| variable
		;

variable: ID
		;

epsilon: ;
%%

/* Bison does NOT implement yyerror, so define it here */
void yyerror(char *string){
   printf("Syntax error in line %d \n\n", numberLines);
   exit(-1);
}

/* Bison does NOT define the main entry point so define it here */
int main(){
   yyparse();
   printf("There is no syntax errors in the code\n\n");
   return 0;
}