Syntactic Analyzer For Tiny C
Copyright © 2014 Mario J. García
=========================================
=========================================
+               IMPORTANT               +
=========================================
The implementation using a dynamic
structure can be found in:
github.com/JacobGarcia/SyntacticAnalyzer
(branch DEV). Consider that the DEV 
version does not print the type of 
variable in the symbols table
=========================================
+             USEFUL NOTES              +
=========================================
The source code, version changes, and
more information about the project can
be found in: 
github.com/JacobGarcia/SyntacticAnalyzer
(branch MASTER)
=========================================
+             CONTRIBUTORS              +
=========================================
Mario Jacob García Navarro   - A01363206

=========================================
+        IMPLEMENTATION PROCESS         +
=========================================
Different grammar rules were developed 
with the purpose of simulate the 
behaviour of a syntactic analyzer for 
Tiny C, a subset of the C language

-----------------------------------------
        IMPORTANT CONSIDERATIONS        
-----------------------------------------
Take account that this only is a 
lexical and syntactic analyzer for a 
(Tiny) C program. Therefore, if the 
input program by any means is not valid 
or has invalid semantic definitions,
the analyzer will ignore them. 

=========================================
+      HOW TO BUILD THE EXECUTABLE      +
=========================================

------------------------------------------
                  make
------------------------------------------

When the build is executed, the c program 
file must be passed as an argument:
NOTE: Consider for the next command 
that the test file must be in the same 
folder. If that were not the case, then 
add the file address.
-----------------------------------------
            /.scanner < test.c
-----------------------------------------

-----------------------------------------
        	 ADDITIONAL NOTES      
-----------------------------------------
The -y flag for the Bison program 
basically overrides the file name when 
it's generated. Leaving it simple as 
"y". The -d flag instead, creates a
header file which can be included in the
Flex source file.
