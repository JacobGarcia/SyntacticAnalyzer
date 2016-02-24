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
/*          usage covered in the class notes for TC2006 & TC3048.        */
/*          The manual for Bison 1.5 for syntactical references,       	 */
/*          symbols, Flex integration, usage and simple examples. Can    */
/*          be found in:                                                 */
/*              http://dinosaur.compilertools.net/bison/index.html       */
/*																																			 */
/*				 The official documentation for GLib 2.46.2, which can be			 */
/*				 found online at https://developer.gnome.org/glib/unstable/.	 */
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
/*          Oct 11 13:48 2015 - File created                        	   */
/*																	     																 */
/*          Sep 09 20:10 2015 - The scanner indicates success or error   */
/*								based on a syntactic analysis on the 	 								 */
/*								Tiny C grammar 							 													 */
/*																																			 */
/*				  Feb 21 19:55 2016 - Added symbols table implementation			 */
/*														 using a GLib Hash Table									 */
/*                                                                       */
/* Error handling:                                                       */
/*      When a syntactic error is found, the program exits and 		 			 */
/*			indicates the line where the actual error was found. 						 */
/*			Take account that the file is read from "top to bottom"     		 */
/* 																																			 */
/* Notes:																																 */
/*			For errors that occurs after a new line is found by Flex,	 			 */
/*			for example, semicolon errors, consider that the line where 		 */
/*			error is indicated is the next line actually. This is 		 			 */
/*			because Flex adds the newline before Bison indicates a parse 		 */
/*			error.  													 															 */
/*                                                                       */
/*************************************************************************/

/*************************************************************************/
/*                         Declaration Section                           */
/*************************************************************************/
%{
	#include "table.h"  /* Symbol table structure */
	#include <stdio.h>  /* Used for the printf function */
	#include <stdlib.h> /* Used for the exit() function when an error is
                        discovered */
	#include <string.h> /* Used for the strdup() function */

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
	char *string; /* Value of a string */
}

/*************************************************************************/
/*     			Terminal Symbols BISON Declaration Section               	 	 */
/*************************************************************************/
%token <intVal> INT_NUM
%token <floatVal> FLOAT_NUM
%token <string> ID
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

/* In order to avoid ambiguity, it's needed a precedence assignation to the rules.
This gives ELSE more precedence over NOT_ELSE simply because this is declared first. */
%nonassoc NOT_ELSE
%nonassoc ELSE

%type <string> type
/*************************************************************************/
/*                         	Grammar Rules Section                        */
/*************************************************************************/
%%
program: var_dec stmt_seq
		 ;

var_dec: var_dec single_dec
		 | epsilon
		 ;

single_dec: type ID {
						char *id = strdup($2); /* Duplicate the symbol string. If this is not done,
					                        the reference for the string will be different,
					                        causing to create another entry for the hash table */
						/* Insert the string into the symbols table */
						g_hash_table_insert(symtab, id, $1);
					} SEMICOLON
			;

type: INT {$<string>$ = "int"; }
	  | FLOAT {$<string>$ = "float"; }
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
/*  Function: yyerror                            		                 		 */
/*                                                                       */
/*  Purpose: The function will be called in case Bison finds a rule not  */
/*			 defined in the grammar                                     		 */
/*                                                                       */
/*  Parameters:                                                          */
/*            Input : A string indicating the type of error. Since it    */
/*					  is only cared about syntactic errors, the input is 				 */
/*					  basically ignored. Due to the fact that Bison      				 */
/*					  expects sending a string when calls yyerror, the   				 */
/*					  function must remain its default definition      					 */
/*                                                                       */
/*            Output:   The line where the syntax error occured (see 	 	 */
/*						notes for possible side effects)         		 							 */
/*                                                                       */
/*************************************************************************/
void yyerror(char *string){
   printf("Syntax error in line %d \n\n", numberLines);
   exit(-1); /* Finish the execution */
}

/*************************************************************************/
/*                                                                       */
/*  Function: printTypeVariable                            		           */
/*                                                                       */
/*  Purpose: Print the actual contents of the hash table. In the form,	 */
/*					 key - value. Since the tracking of the actual values is 	   */
/*					 semantic dependant, expect all the values to be zero 			 */
/*                                                                       */
/*  Parameters:																													 */
/*						Input:		3 gpointers (a.k.a void *)             			     */
/*            Output:   The actual contents of the hash table	 					 */
/*                                                                       */
/*************************************************************************/
void printTypeVariable(gpointer variable, gpointer type, gpointer userData) {
	/* Castings to its original type of data */
   char *realType = (char *)type;
   char *realVariable = (char *)variable;

	 printf("|    %5s       |   %5s       |\n", realType, realVariable);
	 printf("----------------------------------\n");
   return;
}

/*************************************************************************/
/*                                                                       */
/*  Function: printTable                            		                 */
/*                                                                       */
/*  Purpose: Syntactic sugar to call the print function									 */
/*                                                                       */
/*  Parameters:                                                          */
/*            Output:   The actual contents of the hash table	 					 */
/*                                                                       */
/*************************************************************************/
void printTable(){
	/* The g_hash_table_foreach iterates over all the values that the hash table
	contains. It recieves the actual symbols table, a pointer to a function (that
	recieves 3 gpointers, the key, the value & the user_data) which
	will be applied to each element, and finally any additional information that
	the user desires. In this case, nothing is specified. */
	g_hash_table_foreach(symtab, printTypeVariable, NULL);
}

/*************************************************************************/
/*                            Main entry point                           */
/*************************************************************************/
int main(){
	/* Symbols hash table; it converts a string (variable id) to a hash value */
	/* It compares two strings for byte-by-byte equality and returns TRUE if they are equal */
	 symtab = g_hash_table_new(g_str_hash, g_str_equal);
   yyparse();

   /* If there was no errors, add a legend to the
   output and the print the symbols table */
   printf("There is no syntax errors in the code\n\n");

	 /* Create Table Header */
	 printf("----------------------------------\n");
	 printf("|      TYPE      |     SYMBOL    |\n");
	 printf("----------------------------------\n");

	 printTable();

	 #ifndef DEBUG
		printf("There are %d keys in the symbols table\n", g_hash_table_size(symtab));
	 #endif

	 /* Destroy the hash table */
	 g_hash_table_destroy(symtab);

   return 0;
}
