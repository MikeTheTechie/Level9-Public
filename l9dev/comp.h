// 68000 Acode compiler (for Linux)
//
// M.J.Austin. Copyright (C) 1988 Level 9 Computing
//

#include "common.h"

// comparison operators
#define eqop 0 // =
#define neop 1 // <>
#define ltop 2 // <
#define gtop 3 // >
//--- 
// default sizes of various regions
#define hashentries 256
#define symbolentries 3500
#define testsymbolentries 464
#define sizesymbolarea symbolentries*symbolsize
#define testsizesymbolarea testsymbolentries*symbolsize
#define sizeacodearea 24500
#define splitsizeacodearea 60000 // for split data (1.5)
#define testsizeacodearea 0x1e8
#define forwardentries 4000
#define testforwardentries 4
#define sizegamedata 50000
#define splitsizegamedata 80000 // for split data (1.5)
//---
// see controlwords
#define numinstructions 35 // 34 + 1 due to ASR in 1.5
#define instructionlen 16
//---
#define opcgoto 0
#define opcgosub 1
#define opcreturn 2
#define opcprint 3
#define opcmessagev 4
#define opcmessagec 5
#define opcmessagecsmall opcmessagec+smallmask
#define opcmessagecbig opcmessagec
#define opcfunction 6
#define opcinput 7
#define opcletvcbig 8
#define opcletvcsmall opcletvcbig+smallmask
#define opcletvv 9
#define opcaddvv 10
#define opcsubvv 11
#define opcchangecode 12 // change code generation state
#define opccall 14
#define opcexit 15
#define opcscreen 20
#define opcclear 21
#define opcpicture 22
#define opcgetnext 23
#define opcprintinput 28
//
// function codes
#define fncacodedriver 1
#define fncrandom 2
#define fncsave 3
#define fncrestore 4
#define fncclear 5
#define fncstack 6
#define fncbreakpt 7
#define fncprs 250
//---
#define numcontrolwords 4
#define tsize 16
//---
// function declarations needed for forward references in comp.c
#define compprs prs
void UNIMP();
void NotAllowedInAcode();
void COMPADD();
void NotAllowedInAcode();
void COMPBREAKPT();
void compcend();
void compcif();
void COMPCLEAR();
void COMPCLS();
void CompCode();
void COMPDATA();
void compdebuggingon();
void COMPDRIVEROPCODE();
void COMPEXIT();
void COMPGETNEXT();
void compgosub();
void compgoto();
void compif();
void COMPINPUT();
void COMPJUMP();
void COMPMESSAGE();
void COMPPICTURE();
void COMPPRINT();
void COMPPRINTINPUT();
void COMPACODEPRS();
void COMPRANDOM();
void COMPRESTORE();
void COMPRETURN();
void COMPSAVE();
void COMPSCREEN();
void COMPSTACK();
void COMPSUB();
void compdriver(int, void *);
bool dojumptable(char);
void ToggleRS232Printer();
void SetRS232();
void finishwithoutacode();
void finishgamedatainmemory();
void copyacode();
void savegamedata();
void rungame();
void toggledebugginginfo();
void toggleforcedlongjumps();
void togglereport(int);
void nowoff();
void finishacode();
void saveacode ();
bool compilefile();
bool batchcompile();
void abscompilefile();
void endofcompfile();
int checkforcontrolword();
int constantdefinitions();
int vardefinitions();
int tabledefinitions();
int mainprogram();
int getnumberconstant();
void thenjump();
int evaloperator();
bool jumpstuff();
int getlabel(struct _symbol **);
void codew(uint16_t);
void code(uint8_t);
int compgetvar();
void checkunusedsymbols();
void printsymboltable();
void printsymbol(struct _symbol *);
void absprintsymbol(struct _symbol *);
struct _symbol *addsymbol(char, int);
bool findsymbol(struct _symbol **);
int hashcalc();
void displayline();
int tablecompare(char table[][tsize], int);
int stringcompare(char *);
void compssskiptoeol();
void compskiptoeol();
int compsearch();
int compsupersearch();
void forwardoutofrange(struct _symbol *, struct _forwardentry *);
void FROREnd(struct _forwardentry *);
void varexpected();
void acodeoverflow();
void symboltableoverflow();
void symboltoolong();
void varnotdefined();
void compilerbug();
void comperror();
void comperror1();
void compprintfilename();
void TooManyVars();
void forwardrefoverflow();
void cantredefinesymbol();
void badsymbol();
void equalsexpected();
void commaexpected();
void bracketsexpected();
void reljumpoutofrange();
void badindex();
void badtype();
void badoperator();
void poundsignnotallowed();
void missingquote();
void badarg();
void badinstruction();
void wronglabeltype();
void compnotimp();
void syntaxerror();
void PlusOrMinusExpected();
void AlreadyInState();
void NotAllowedInAcode();
void NotAllowedInMC();
void EvenError();
void CantDo16();
void WrongCodeState();
void ForwardWrongCodeState(struct _symbol *, struct _forwardentry *);
//---
// defined in finish.c
extern char *ptr;
extern struct _fcb savecompletedriverblock;
extern char *startcomplete;
extern char *finishedptr;
extern void *startsources;
extern void processexits();
extern void processtables();
extern void savedirectory();
extern void selectdirectory();
extern void processsquash();
extern void climb();
extern void processacodeptr();
extern void finishchecksum();
extern void descend();
//---
// defined in code.c
extern void Mc8086();
extern void MCPop();
extern void MCPush();
extern void MCToAcode();
extern void MCReturn();
extern void MCAdd();
extern void MCAnd();
extern void MCASR();
extern void MCOr();
extern void MCSub();
extern void MCXor();
extern void MCPrint();
extern void MCMessage();
extern void MCInput();
extern void MCExit();
extern void MCScreen();
extern void MCPicture();
extern void MCGetNext();
extern void MCPrintInput();
extern void MCDriverOpcode();
extern void MCRandom();
extern void MCSave();
extern void MCRestore();
extern void MCClear();
extern void MCStack();
extern void MCCLS();
extern void MCJump();
extern void MCAcodePrs();
extern void MCBreakPt();
extern void MCData();
extern void MCgosub();
extern void MCgoto();
extern void MCIF();
extern void MCLetVC(int, int);
extern void MCLetVV(int, int);
extern void MCAttVar(int, int);
extern void MCAttConst(int, int);
extern void MCAft(int, int);
extern void MCrfr(struct _symbol *, struct _forwardentry *);
//---
// defined in int.c
void intinit1();
void intinitloadpics(void *, void *, bool);
void intstart2();
