// 68000 Acode compiler, finish and squasher program (for Linux)
// common declarations
// Copyright (C) 1986-1988 Level 9 Computing

// finish version string
#define finish_version \
  "Acode finish 1.1 (for Linux)\n" \
  "Copyright (C) 1986-1988 Level 9 Computing\n\n"

// all includes
#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <unistd.h>
#include <glob.h>

// RAM size
#define compramsize 0x100000 // 1M

// useful characters
#define cr 13
#define lf 10
#define eof 26

// driver function codes
#define initdcode 0
#define checksumdcode 1
#define oswrchdcode 2
#define osrdchdcode 3
#define inputlinedcode 4
#define savedcode 5
#define loaddcode 6
#define settextdcode 7
#define taskinitdcode 8
#define returntoosdcode 9

#define chainprogramdcode 11
#define randomnumberdcode 12

#define getclockdcode 14

#define clgdcode 16
#define linedcode 17
#define filldcode 18
#define chgcoldcode 19
#define finishpicturedcode 20

#define ramsavedcode 22
#define ramloaddcode 23

#define lenslokdisplaydcode 25

#define displayhirescode 32
#define preloadhirescode 33
#define testhirescode 34

// used by both comp.c and finish.c
#define sizeofpointers 44 // overall gamedata pointers

// used by both comp.c and code.c
#define smallmask 0x40 // if size bit (bit 6)=1, it is a 8 bit constant
#define relmask 0x20 // if relbit (bit 5)=1, it is a short jump

// symbol table entry structure
#define symboltextlength 27 // including 0 terminator byte
struct _symbol {
  char text[symboltextlength];
  char codestate;
  char type;
  struct _symbol *ptr;
  uint16_t value;
};
#define symbolsize sizeof(struct _symbol)
#define constanttype 1
#define vartype 2
#define tabletype 3
#define labeltype 4
#define undefinedlabeltype 5

// forward reference entry structure
struct _forwardentry {
  //  .. offset from start of table of next u/d reference to this symbol
  struct _forwardentry *next;
  //  .. line number of reference
  uint16_t linenumber;
  //  .. offset from start of code of the reference
  uint16_t ref;
  //  .. offset from start of code of the opcode
  uint16_t opcode;
  //  .. file number in which reference occured
  char filenumber;
  //  .. CodeState
  char codestate;
};
#define forwardentrysize sizeof(struct _forwardentry)

// For PC code generation (1.5 feature)
// See gamedata segment layout in pccode.c
#define PCListVector 4
#define PCvarsoffset 144

// definition of file control block
struct _fcb {
  void *start;
  void *end;
  char filename[];
};

// driver functions
extern void *endmemory;
extern bool isd0alphanumeric(char);
extern void printdecimald0(int);
extern void hexlonga0(uint32_t);
extern void driver(int, void*);
extern void openlogfile(char *);
extern void closelogfile();
extern int OutputDevice;
extern void prs(char const *, ...);
extern char osrdch();
extern char waitkey();
extern int readdecimal(char **);
extern void hexbyted0(uint8_t);
extern void returntogem();
extern void init1();
extern bool init2();
extern void autoruninit(char *);
extern char *getfilename(struct _fcb *);
extern bool output_terminal();
extern bool input_terminal();
extern void set_input_mode(bool);
extern void reset_input_mode();
