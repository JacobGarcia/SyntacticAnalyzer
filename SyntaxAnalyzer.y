/*************************************************************************/
/*                                                                       */
/* Copyright (c) 2015 Mario J. García Navarro                            */
/*                                                                       */
/* File name: SyntaxAnalyzer.l                                           */
/*                                                                       */
/* Author:                                                               */
/*          Mario J. García Navarro                                      */
/*                                                                       */
/* Purpose:                                                              */
/*          This program implements a basic syntax analyzer for Tiny C,  */
/*          a subset of the C language.                                  */
/*                                                                       */
/* Usage:   The scanner reads an input file from the command line. The   */
/*          usage form is:                                               */
/*                                                                       */
/*          scanner < file.c                                             */
/*                                                                       */
/* References:                                                           */
/*          The material that describes formal grammars and YACC/BISON   */
/*          usage covered in the class notes for TC2006.                 */
/*          The manual for Bison 1.5 for syntactical references,       	 */
/*          symbols, Flex integration, usage and simple examples. Can    */
/*          be found in:                                                 */
/*              http://dinosaur.compilertools.net/bison/index.html       */
/*                                                                       */
/* File formats:                                                         */
/*          The input file should have a "valid" C(Tiny C) program       */ 
/*                                                                       */
/* Restrictions:                                                         */
/*          Actually, any text file can be passed from the command line, */
/*          it is not necessary to have the .c extension                 */
/*                                                                       */
/* Revision history:                                                     */
/*                                                                       */
/*          Oct 11 13:48 2015 - File created                        	 */
/*																	     */
/*          Sep 09 20:10 2015 - The scanner indicates success or error   */
/*								based on a syntactic analysis based on   */
/*								the Tiny C grammar 						 */
/*                                                                       */
/* Error handling:                                                       */
/*          When a syntactic error is found, the program exits and 		 */
/*			indicates the line where the actual error was found. 		 */
/*			Take account that the file is read from "top to bottom"      */
/* 																		 */
/* Notes:																 */
/*			For errors that occurs after a new line is found by Flex	 */
/*			for example, semicolon errors, consider that the line where  */
/*			error is indicated is the next line actually. This is 		 */
/*			Flex adds the newline before Bison indicates a parse error.  */
/*                                                                       */
/*************************************************************************/

/*************************************************************************/
/*                         Declaration Section                           */
/*************************************************************************/
%{
	#include <stdio.h> /* Used for the printf function */
	#include <stdlib.h> /* Used for the exit() function when an error is 
                        discovered */

	/* Function definitions */
	void yyerror (char *string); /* Bison does NOT implement yyerror */

	extern int yylex(void); /* Function from Flex that Bison needs to know about */
	extern int numberLines; /* Counter of newlines. Defined in Flex */
%}

/* Tokens could be of any arbitrary data type. It's dealt with that in Bison by 
defining a C union holding each of the types of tokens that Flex could return */
%union{
	int intVal; /* Value of int number */
	float floatVal; /* Value of float number */
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

/* In order to avoid ambiguity, it's needed a precedence assignation to the rules 
This gives ELSE more precedence over NOT_ELSE simply because this is declared first. */
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

stmt: IF exp THEN stmt %prec NOT_ELSE /* Higher precedence is given to shifting */
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

/*************************************************************************/
/*                                                                       */
/*  Function: yyerror                            		                 */
/*                                                                       */
/*  Purpose: The function will be called in case Bison finds a rule not  */
/*			 defined in the grammar                                      */
/*                                                                       */
/*  Parameters:                                                          */
/*            Input : A string indicating the type of error. Since it    */
/*					  is only cared about syntactic errors, the input is */
/*					  basically ignored. Due to the fact that Bison      */
/*					  expects sending a string when calls yyerror, the   */
/*					  function must remain it's default definition       */
/*                                                                       */
/*            Output:   The line where the syntax error occured (see 	 */
/*						notes for possible side effects)         		 */
/*                                                                       */
/*************************************************************************/
void yyerror(char *string){
   printf("Syntax error in line %d \n\n", numberLines);
   exit(-1);
}

/*************************************************************************/
/*                            Main entry point                           */
/*************************************************************************/ 
int main(){
   yyparse();

   /* If there was no errors, finish the program and a legend to it */
   printf("There is no syntax errors in the code\n\n");
   return 0;
}