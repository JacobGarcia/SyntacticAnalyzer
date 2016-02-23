/*                                                              */
/*	   Header for the shared symbol table                       */
/*                                                              */

#define NSYMS 30	   /* Assume a maximum number of 20 symbols */

struct symtab {
  char *name;                    /* The name is just the string */
  int type;                      /* The type for the variable */
} symtab[NSYMS];

/* Function prototype for the symbol table look up routine */
struct symtab *symlook(char *string);
