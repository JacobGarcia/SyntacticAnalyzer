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
/* Usage:   The scanner was written considering to be used with Bison.   */
/*          Since that's the case, the program is not designed to run    */
/*          as a standalone.                                             */
/*                                                                       */
/* References:                                                           */
/*          The material that describes regular expressions and Lex/Flex */
/*          usage covered in the class notes for TC2006 & TC3048.        */
/*          The manual for Flex 2.5.37 for syntactical references,       */
/*          patterns, start conditions, usage and simple examples. Can   */
/*          be found in:                                                 */
/*              http://flex.sourceforge.net/manual/                      */
/*                                                                       */
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
/*          Sep 09 09:14 2015 - File created                             */
/*                                                                       */
/*          Sep 09 20:10 2015 - The scanner recognizes all the           */
/*                              specified tokens                         */
/*                                                                       */
/*          Oct 11 14:12 2015 - The program was modified to return       */
/*                              tokens for Bison usage instead of        */
/*                              printing them                            */
/*                                                                       */
/*          Feb 21 19:58     - The scanner now implements a symbols      */
/*                             table from a GLib hash table              */
/* Error handling:                                                       */
/*          When unknown tokens are found, the program indicates an      */
/*          error on the line where the token was found and shows the    */
/*          actual unknown token. Then, the program exits.               */
/*                                                                       */
/*************************************************************************/

/*************************************************************************/
/*                         Declaration Section                           */
/*************************************************************************/
/*************************************************************************/
/*                                                                       */
/*  (int)numberLines: This is a simple counter of newlines. It is used   */
/*                    whenever an error occurs, showing the user the     */
/*                    line where the error has arise                     */
/*                                                                       */
/*************************************************************************/
%{
    #include <stdlib.h> /* Used for the exit() function when an error is
                        discovered */
    #include <string.h> /* Used for strdup() function */
    #include "y.tab.h" /* Inclusion of Bison reference tokens */
    #include "table.h" /* Symbols table */
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
/*  RELATIONAL: Tokens used when comparing two elements                  */
/*                                                                       */
/*  ASSIGNMENT: Used when assigning a value to an identifier. Consider   */
/*              that the operator does not follows the ANSI C '='        */
/*                                                                       */
/*  COMMENT: A routine declaration used to handle comments. It takes     */
/*           account all the possible types of comments in ANSI C.       */
/*           Considering single-line comments and multi-line ones        */
/*                                                                       */
/*************************************************************************/
DIGIT		[0-9]|[1-9][0-9]*
EXPONENTIAL [0-9]*"."[0-9]+[e|E][-|+]?[0-9]+
HEX			0(x|X)[0-9A-Fa-f]+
OCTAL		0(c|C)[0-7]+
ID       	[A-Za-z_][A-Za-z0-9_]*
RELATIONAL 	<|<=|>|>=|!=|==
ASSIGNMENT	:=
%x COMMENT

/*************************************************************************/
/*                              Rules Section                            */
/*************************************************************************/
%%
"/*"              BEGIN(COMMENT); /* In case a comment is discovered, begin the
                                    routine to handle comments */

<COMMENT>{
     "*/"      BEGIN(INITIAL); /* This identifies when the comment actually ends.
                                Go to the default routine when its discovered */
     [^*\n]+   /* Eat the comment between asterisks */
     "*"       /* Ignore the asterisk itself (for multi-line comments) */
     \n        numberLines++; /* Keep record of the current line */
}

"//".* /* Ignore single-line comments of this type */

{DIGIT} {return INT_NUM; }

{DIGIT}"."{DIGIT}+ {    /* This expression is used to differentiate floating
                        point numbers from integer ones */
            return FLOAT_NUM;
}

{HEX} { return INT_NUM; } /* Hex numbers are defined as integers */

{OCTAL} { return INT_NUM; } /* Octal numbers are defined as integers */


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

"," /* Ignore the comma. Since it is a token of the language, but not used in the grammar */


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

{EXPONENTIAL} { return FLOAT_NUM; } /* Exponential numbers are only floats for this language */

{ID} {
  yylval.string = yytext; /* Assign the string value for the ID's */
  return ID;
}


[ \t]+          /* Eat up the whitespace */

\n             numberLines++;  /* When a newline is found, add 1 to the global
                                counter to track the line numbers */

. {             /* When an unknown token is found, indicate an error and exit */
             printf("Unknown token %s found in line %d \n\n", yytext, numberLines);
             exit(-1);
}
%%
