all: scanner

y.tab.c y.tab.h:	SyntaxAnalyzer.y
		bison -yd SyntaxAnalyzer.y

lex.yy.c:	LexicalAnalyzer.l
		flex LexicalAnalyzer.l

scanner:	y.tab.c lex.yy.c
		gcc y.tab.c lex.yy.c -o scanner -ll

clean:
		rm scanner y.tab.c y.tab.h lex.yy.c
