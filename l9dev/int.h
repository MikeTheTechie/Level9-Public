// 68000 Acode interpreter (adapted for Linux)
//
// Copyright (C) 1986 Level 9 Computing

#include "common.h"

#define listareasize 2048
#define hugevars 1025
struct _workspace {
  uint16_t vartable[256];
  uint8_t listarea[listareasize];
};
extern struct _workspace workspace;
#define workspacestart (&workspace)
#define workspaceend (workspacestart + 1)
extern uint16_t *vartable;
#define listarea workspace.listarea

extern uint8_t *absdatablock[12];
#define exitsptr absdatablock[0]
#define listtbl (absdatablock + 1)
// commandsptr also allows space for list0ptr
#define list0ptr absdatablock[1]
#define commandsptr list0ptr
#define list1ptr absdatablock[2]
#define list2ptr absdatablock[3]
#define list3ptr absdatablock[4]
#define list4ptr absdatablock[5]
#define list5ptr absdatablock[6]
#define list6ptr absdatablock[7]
#define list7ptr absdatablock[8]
#define list8ptr absdatablock[9]
#define list9startptr absdatablock[10]
#define acodeptr absdatablock[11]

// constants for interpreter
#define relativemask 0x20
#define sizemask 0x40
#define numberofvars 255
#define controlc 3
#define formfeed 12
#define flushcode 126 // tilda on BBC
#define runmodecode 0
#define stepmodecode 'S'
#define tracemodecode 'T'

extern uint8_t *pc;
extern uint8_t *hugesystemstart;
extern uint8_t *hugesystemend;
extern uint8_t *hugevbl;
extern int16_t popvar;
extern bool mc;
extern bool retins;
extern bool popins;
extern bool resetins;
extern uint16_t breakpointaddress;
extern char debuggingstatus;
extern char intdriverbuffer[500];

// function declarations needed for forward references in int.c
void checksumgamedata();
void wrapreset();
void instructionloop();
void executeinstruction(uint8_t);
void traceinstruction();
uint32_t getmaxind(uint8_t *);
uint8_t *gettable(uint8_t);
uint16_t readtable16(void *, uint16_t);
void writetable16(void *, uint16_t, uint16_t);
void listhandler(uint8_t);
uint16_t getcon(uint8_t);
uint8_t *getaddr(uint8_t);
uint16_t *getvar();
void ilins(uint8_t);
void intgoto(uint8_t);
void intgosub(uint8_t);
void intreturn(uint8_t);
void printnumber(uint8_t);
void messagev(uint8_t);
void messagec(uint8_t);
void printmessage(uint16_t);
void absprintmessage(int16_t);
bool printmessagedebugging();
void function(uint8_t);
void input(uint8_t);
void varcon(uint8_t);
void varvar(uint8_t);
void varvar1(uint16_t);
void intadd(uint8_t);
void intsub(uint8_t);
void ToMC(uint8_t);
void intjump(uint8_t);
void intexit(uint8_t);
void ifeqvt(uint8_t);
void ifnevt(uint8_t);
void ifltvt(uint8_t);
void ifgtvt(uint8_t);
void screen(uint8_t);
void cleartg(uint8_t);
void picture(uint8_t);
void getnextobject(uint8_t);
void ifeqct(uint8_t);
void ifnect(uint8_t);
void ifltct(uint8_t);
void ifgtct(uint8_t);
void printinput(uint8_t);
void intram(uint8_t, uint8_t *);
void chainprog(uint8_t *);
void save();
void restore();
void calldriver();
void intrandom();
void clearworkspace();
void resetstack();
void corruptinginput();
void flush();
void printchar(char);
void printchar1(char);
uint16_t exit1(uint8_t, uint8_t);
bool partword(uint8_t);
void initunpack(uint16_t);
void initdict(uint16_t);
bool unpackword();
void findmsgequiv(uint16_t);
uint8_t getdictionarycode();
char getdictionary(uint8_t);
char getlongcode(uint8_t);
uint16_t getmdlength(uint8_t **);
void displaywordref(uint16_t);
void printautocase(char, uint8_t);
void absprintautocase(char, uint8_t);
void wrapoutput(char);
void absprintchar(char);
void initgetobjsp();
void gnopop();
void initgetobj();
void gnoreturnargs();
bool gnoabs();
void intdisplayinstruction(uint8_t);
void displayvariables();
void displaymemorya1(uint16_t *, int);
void debugging();
void startrunning(char);
void getdebuggingoption();
void displaymemory();
int getaddress();
void generatebreakpoint();
void setbreakpoint();
void checkbreakpoint();
void debuggingHelp();

// defined in comp.c, int.c, menu.c or driver.c
extern uint8_t *startfile;
extern uint16_t randomseed;
extern uint16_t setrandomseed;
extern bool inputnoecho;
extern bool debug;
extern bool splitdata;
extern bool i8086;
extern bool autorun;
extern bool demo;
extern bool executingcommandfile;
extern bool nextpart;

// defined in stint.c
void initsthuge();
void executestmc(uint8_t);
void systemcall();

// defined in pcint.c
void initpchuge();
void executepcmc(uint8_t);
