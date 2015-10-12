/*************************************************************************/
/*                                                                       */
/* Copyright (c) 2015 Mario J. García Navarro                            */
/*                                                                       */
/* File name: LexicalAnalyzer.l                                          */
/*                                                                       */
/* Author:                                                               */
/*          Mario J. García Navarro                                      */
/*                                                                       */
/* Purpose:                                                              */
/*          This program implements a basic lexical analyzer for Tiny C, */
/*          a subset of the C language.                                  */
/*                                                                       */
/* Usage:   The scanner reads an input file from the command line. The   */
/*          usage form is:                                               */
/*                                                                       */
/*          scanner < file.c                                             */
/*                                                                       */
/* References:                                                           */
/*          The material that describes regular expressions and Lex/Flex */
/*          usage covered in the class notes for TC2006.                 */
/*          The manual for Flex 2.5.37 for syntactical references,       */
/*          patterns, start conditions, usage and simple examples. Can   */
/*          be found in:                                                 */
/*              http://flex.sourceforge.net/manual/                      */
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
/*          Sep 09 09:14 2015 - File created                             */
/*                                                                       */
/*          Sep 09 20:10 2015 - The scanner recognizes all the           */
/*                              specified tokens                         */
/*                                                                       */
/*                                                                       */
/* Error handling:                                                       */
/*          When unknown tokens are found, the program indicates an error */
/*          on the line where the token is found and shows the actual    */
/*          unknown token                                                 */
/*                                                                       */
/* Notes:                                                                */
/*          The output is in a table-like format, with 2 columns: The    */
/*          type of the token and the value for it. Since multi-line     */
/*          comments are handled, consider that the output in the table  */
/*          for those is not managed perfectly. Everything else works    */
/*          really fine in the table format                              */
/*                                                                       */
/*************************************************************************/

/*************************************************************************/
/*                         Declaration Section                           */
/*************************************************************************/
/*************************************************************************/
/*                                                                       */
/*  (int)idToDel: This variable expresses the index that is used to      */
/*                indicate that a number is octal (which is always in    */
/*                he second position of the string). This is used for    */
/*                the octal to decimal conversion                        */
/*                                                                       */
/*  (int)numberLines: This is a simple counter of newlines. It is used   */
/*                    whenever an error occurs, showing the user the     */
/*                    line where the error has arise                     */
/*                                                                       */
/*************************************************************************/
%{
    #include "y.tab.h"
    int idToDel = 1; 
    int numberLines = 1;
%}


/*************************************************************************/
/*                       User Defined MACROS Section                     */
/*************************************************************************/
/*************************************************************************/
/*                                                                       */
/*  DIGIT: A single number from 0 to 9 or a composed number starting     */
/*         from 1 to 9 followed by any number from 0 to 9                */
/*                                                                       */
/*  EXPONENTIAL: In this case, any floating point number followed by an  */
/*               e (or E), a positive or negative sign and finally, an   */
/*               integer number indicating the power                     */
/*                                                                       */
/*  HEX: An hexadecimal number                                           */
/*                                                                       */
/*  OCTAL: An octal number                                               */
/*                                                                       */
/*  ID: Identifiers that are supported in ANSI C                         */
/*                                                                       */
/*  OPERATOR: Arithmetic operator: Addition, subtraction, multiplication */
/*            and finally division                                       */
/*                                                                       */
/*  KEYWORD: A set of reserved words supported by Tiny C                 */
/*                                                                       */
/*  RELATIONAL: Tokens used when comparing two elements                  */
/*                                                                       */
/*  ASSIGNMENT: Used when assigning a value to an identifier. Consider   */
/*              that the operator does not follows the ANSI C '='        */
/*                                                                       */
/*  COMMENT: A regular expression that takes account all the possible    */
/*           types of comments in ANSI C. Considering single-line        */
/*           comments and multi-line ones                                */
/*                                                                       */
/*************************************************************************/
DIGIT		[0-9]|[1-9][0-9]* 
EXPONENTIAL [0-9]*"."[0-9]+[e|E][-|+]?[0-9]+
HEX			0(x|X)[0-9A-Fa-f]+
OCTAL		0(c|C)[0-7]+
ID       	[A-Za-z_][A-Za-z0-9_]*
RELATIONAL 	<|<=|>|>=|!=|==
ASSIGNMENT	:=
COMMENT     ("/*"([^*]|([*]+[^*/]))*[*]+"/")|"//".*

/*************************************************************************/
/*                              Rules Section                            */
/*************************************************************************/
%x COMMENT
%%


"/*"              BEGIN(COMMENT); /* Ignore comments routine */

<COMMENT>{
     "*/"      BEGIN(INITIAL);
     [^*\n]+   /* Eat the comment between asterisks */
     "*"       /* Ignore asterisk */
     \n        numberLines++; /* Keep record of the current line */
}


{DIGIT} {return INT_NUM; }

{DIGIT}"."{DIGIT}+ {    /* This expression is used to differentiate floating point numbers from integer ones */
            return FLOAT_NUM;
}

{HEX} { return INT_NUM; }

{OCTAL} { return INT_NUM; }


"if" { return IF; }

"then" { return THEN; }

"else" { return ELSE; }

"int" { return INT; }

"float" { return FLOAT; }

"while" { return WHILE; }

"do" { return DO; }

"read" { return READ; }

"write" { return WRITE; }


"{" { return LBRACE; }

"}" { return RBRACE; }

"(" { return LPAREN; }

")" { return RPAREN; }

";" { return SEMICOLON; }

"," /* Ignore comma. Since is a token of the language, but not used in the grammar */


"+" { return PLUS; }

"-" { return MINUS; }

"*" { return TIMES; }

"/" { return DIV; }


{ASSIGNMENT} {
    return ASSIGNMENT;
}

{RELATIONAL} {
    return RELATIONAL;
}

{EXPONENTIAL} { return FLOAT_NUM; }

{ID} { return ID; }


[ \t]+          /* Eat up the whitespace */    

\n             numberLines++;  /* When a newline is found, add 1 to the global 
                                counter to track the line numbers */

. {             /* When an unknown token is found, indicate an error */
             printf("|         ERROR           | %11s (Line %2d) |\n", yytext, numberLines);
             printf("--------------------------------------------------\n"); 
}        

%%
