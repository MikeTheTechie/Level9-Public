// 68000 Acode compiler (adapted for Linux)
//
// started 18:38 on Tuesday 29/7/86
// last change: 2/6/88
//
// started Linux version on Monday 8/12/25
// first presentable version: 21/12/25
//
// M.J.Austin. Copyright (C) 1988 Level 9 Computing
//

#include "comp.h"

// file control blocks
struct _fcb saveacodedriverblock = {
  NULL,
  NULL,
  "acode.acd"
};
//---
struct _fcb loadcommandfile = {
  NULL,
  NULL,
  "compile.bat"
};
//--
bool bugcomp = false; // if true, enable bugwards compatibility (can be set to true by providing --bugcomp)
bool oddacode = false; // if true, do not align acode (can be set to true by providing --oddacode)
bool testcomp = false; // if true, limit sizes to test overflow errors (can be set to true by providing --bugcomp)
bool i8086 = false; // if true, generate MC code for i8086 (can be set to true by providing --i8086)
bool splitdata = false; // if true, generate split acode and gamedata (can be set to true by providing --splitdata)
//---
char batchfilebuffer[500];
//---
char compinstructiontable[][instructionlen] = {
  "ADD",
  "AND",
  "ASR", // Arithmetic Shift Right (extra MC instruction introduced in 1.5)
  "BREAK",
  "CEND", // conditional assembly
  "CIF", // conditional assembly
  "CLEAR",
  "CLS",
  "CODE", // machine-code compilation
  "DATA",
  "DEBUG",
  "DRIVER",
  "EXIT",
  "GETNEXT",
  "GOSUB",
  "GOTO",
  "IF",
  "INPUT",
  "JUMP",
  "MESSAGE",
  "OR",
  "PICTURE",
  "POP",
  "PRINT",
  "PRINTINPUT",
  "PRS",
  "PUSH",
  "RANDOM",
  "RESTORE",
  "RETURN",
  "SAVE",
  "SCREEN",
  "STACK",
  "SUB",
  "XOR",
  "XYZZY" // use this to trigger a compiler bug error in test mode
};
//---
void (*CompJumpTable[])() = {
  NULL, // null entry because words numbered from 1 ..
  COMPADD,
  NotAllowedInAcode, // AND
  NotAllowedInAcode, // ASR
  COMPBREAKPT,
  compcend,
  compcif,
  COMPCLEAR,
  COMPCLS,
  CompCode,
  COMPDATA,
  compdebuggingon,
  COMPDRIVEROPCODE,
  COMPEXIT,
  COMPGETNEXT,
  compgosub,
  compgoto,
  compif,
  COMPINPUT,
  COMPJUMP,
  COMPMESSAGE,
  NotAllowedInAcode, // OR
  COMPPICTURE,
  NotAllowedInAcode, // POP
  COMPPRINT,
  COMPPRINTINPUT,
  COMPACODEPRS,
  NotAllowedInAcode, // PUSH
  COMPRANDOM,
  COMPRESTORE,
  COMPRETURN,
  COMPSAVE,
  COMPSCREEN,
  COMPSTACK,
  COMPSUB,
  NotAllowedInAcode, // XOR
  compilerbug
};
//---
void (*MCjumptable[])() = { // jump table for use in MC mode
  NULL, // null entry because words numbered from 1 ..
  MCAdd,
  MCAnd,
  MCASR,
  MCBreakPt,
  compcend,
  compcif,
  MCClear,
  MCCLS,
  CompCode,
  MCData,
  compdebuggingon,
  MCDriverOpcode,
  MCExit,
  MCGetNext,
  MCgosub,
  MCgoto,
  MCIF,
  MCInput,
  MCJump,
  MCMessage,
  MCOr,
  MCPicture,
  MCPop,
  MCPrint,
  MCPrintInput,
  MCAcodePrs,
  MCPush,
  MCRandom,
  MCRestore,
  MCReturn,
  MCSave,
  MCScreen,
  MCStack,
  MCSub,
  MCXor,
  compilerbug
};
//---
// each entry is of length tsize
// with terminatori 0 included
// MUST BE ALPHABETICALLY SORTED
char controlwords[numcontrolwords][tsize] = {
  "BEGIN",
  "CONST",
  "TABLE",
  "VAR"
};
//---
// now some vectors to the real code (probably in driver.c)....
bool compisd0alphanumeric(char c) { return isd0alphanumeric(c); }
void compprintdecimald0(int n) { printdecimald0(n); }
void comphexlonga0(uint32_t n) { hexlonga0(n); }
void compdriver(int code, void *buffer) { driver(code, buffer); }
char compwaitkey() { return waitkey(); }
int compreaddecimal(char **s) { return readdecimal(s); }
void comphexbyted0(uint8_t n) { hexbyted0(n); }
void compreturntogem() { returntogem(); }
//---
// workspace values
uint8_t *startfile = NULL;
void *endcompiler = NULL;
void *opcodeaddress = NULL;
int currentvarnumber = 0;
int complinenumber = 0;
int TotalSourceLines = 0;
struct _symbol *startsymbols = NULL; // start of symbol table area
struct _symbol *endsymbols = NULL; // end of symbol table area
struct _symbol *freesymbol = NULL; // first free symbol address
void *startsource = NULL; // start of source area
void *endsource = NULL; // end of source area
int symboltablesize = 0; // size of symbol table area
void *compacodeptr = NULL; // pointer to code to be generated
void *savedacodeptr = NULL;
void *startacode = NULL; // start of acode area
void *endacode = NULL; // end of acode area
int errorstack = 0; // stack value for when errors occur
struct _forwardentry *startforward = NULL;
struct _forwardentry *freeforwardref = NULL; // pointer within forward ref table
struct _forwardentry *endforward = NULL;
int symboladdress = 0;
void *cbatchptr = 0;

void (**CurrentJumpTable)() = NULL; // pointer to the current compiler jump table
//---
char debugginginfoon = 0;
char compterminator  = 0;
void *jumpdummyopcode = NULL; // absolute jump
void *dummyshortopcode = NULL; // must be startacode - 6 for code.c
void *dummylongopcode = NULL; // must be startacode - 5 for code.c
char forcedlongjumps = 0; // zero if off, 1 if on
char filenumber = 0;
char cexecutingcommandfile = 0;
char compilationerrors = 0; // set non-zero if any errors occur
char suppresscompilation = 0; // set to 1 for conditional assembly
bool acodeerror = false; // flag to signal acode overflow to the error subsystem
char CodeState = 0; // set to "+" to generate MC
char SixteenFlag = 0; // set to indicate 16 bit list operations
//---
char compdriverbuffer[100];
//---
void compflush() {
  fflush(stdout);
}
//-------------
void clearsymbols() {
  // acode area is immediately after comp

  // once-only init
  endcompiler = malloc(compramsize);
  endmemory = endcompiler + compramsize;

  // acode area is first section
  startacode = endcompiler + 2; // reserve space for acode length
  compacodeptr = startacode;
  endacode = startacode + (testcomp ? testsizeacodearea :
             (splitdata ? splitsizeacodearea : sizeacodearea)); // 1.5

  // allocate space for the dummy opcode addresses
  jumpdummyopcode = endacode;
  *(char *)jumpdummyopcode = 0;
  dummyshortopcode = endacode + 2;
  *(char *)dummyshortopcode = relmask;
  dummylongopcode = endacode + 4;
  *(char *)dummylongopcode = 0;

  // symbols sit between end of acode
  // and source area
  symboltablesize = (testcomp ? testsizesymbolarea : sizesymbolarea);
  // set up pointer to start of symbol table
  startsymbols = endacode + 8; // leave room for the dummies

  //  and set up pointer to first free address in symbol table
  // (immediately after the hash table)
  freesymbol = startsymbols + hashentries;

  // clear space between startsymbols and startsymbols+symboltablesize
  memset(startsymbols, 0, symboltablesize);
  endsymbols = startsymbols + (testcomp ? testsymbolentries : symbolentries);

  // forward reference table is after symbol table
  startforward = (struct _forwardentry *)endsymbols;
  // zero offset from start of f/r table
  freeforwardref = startforward;
  endforward = (struct _forwardentry *)endsymbols +
               (testcomp ? testforwardentries : forwardentries);

  // set up pointer at which source will be loaded
  startsource = endforward;
  // and some constants
  currentvarnumber = 0;

  // complete.dat will eventually be formed at the end of everything
  // to allow further compilation or symbol table actions after finishing
  startcomplete = (char *)endforward;
  startfile = (uint8_t *)startcomplete; // needed for interpreter
}
//---
void compsoftinit() {
  // undo any potential finishing already done
  *(char *)(startacode - 2) = 0;
  *(char *)(startacode - 1) = 0;
  savecompletedriverblock.start = NULL;
  savecompletedriverblock.end = NULL;

  // start again with linenumber 1
  complinenumber = 1;
}
//---
void compstart() {
  clearsymbols();

  // set acode generation to start with
  CodeState = '-';
  CurrentJumpTable = CompJumpTable;

  // with some 1.5 features hacked in
  // to be able to support the AA games (GM and BTK)
  compprs("\n");
  compprs("68000 Acode compiler 1.3 (for Linux)\n");
  compprs("Copyright (C) 1988 Level 9 Computing.\n");
  compprs("M.J.Austin 2/6/88\n");

  // is there a command file in this directory on the disk?
  compprs("\nLooking for compilation batch file - 'compile.bat'\n");
  loadcommandfile.start = &batchfilebuffer; // loading address
  compdriver(loaddcode, &loadcommandfile);
  if (*(char *)&loadcommandfile == 0) {
    int r = loadcommandfile.end - (void *)batchfilebuffer;
    if (r < 0) r = 0;
    batchfilebuffer[r++] = cr;
    batchfilebuffer[r++] = lf;
    batchfilebuffer[r++] = eof;
    batchfilebuffer[r++] = eof;
    batchfilebuffer[r++] = 0;
    cbatchptr = batchfilebuffer;
    cexecutingcommandfile = 1;
  } else return; // no, so get instructions from user
  compprs("\nExecuting instructions in file 'compile.bat'\n");
  char c;
  while ((c = *(char *)cbatchptr++) != eof) {
    if (c == '1') {
      if (!batchcompile()) break;
    } else if (!dojumptable(c)) break; // for normal functions
  }
  // end of batch file, start prompting user
}

bool batchcompile() {
  // get a filename from batch file, then compile it
  compsoftinit();
  compprs("Compiling file '");
  // copy file name into driverbuffer
  struct _fcb *fcb = (struct _fcb *)&compdriverbuffer;
  fcb->start = startsource;
  char *filename = cbatchptr;
  char c;
  while (c = *(char *)cbatchptr++, c != cr && c != lf)
    compprs("%c", c);
  // end of filename, temporarily add 0 terminator
  char *term = cbatchptr - 1;
  *term = 0;
  compprs("'. ");
  compflush();

  *fcb->filename = 0x80; // pointer to filename
  *(char **)(fcb->filename + 1) = filename;
  compdriver(loaddcode, fcb);

  if (*(char *)fcb) return false; // not found
  abscompilefile();
  *term = c; // reset line terminator
  return true;
}

//---
void compmenu() {
  cexecutingcommandfile = 0;
  while (true) {
    compprs("\n");
    compprs(" 0 .. Exit to TOS                ");
    compprs(" 1 .. Compile Source file\n");

    compprs(" 2 .. Finish acode               ");
    compprs(" 3 .. Finish gamedata.dat\n");

    compprs(" 4 .. Save Gamedata and acode    ");
    compprs(" 5 .. Run game\n");

    compprs(" 6 .. Toggle debugging info\n");

    compprs(" 7 .. Toggle forced long jumps   ");
    compprs(" 8 .. Print symbols\n");

    compprs(" 9 .. Check for unused symbols   ");
    compprs(" A .. Toggle printing (to rs232) \n");
    if (splitdata) compprs(" B .. Finish gamedata without acode \n");
    compprs("\n");
    compprs("Your choice: ");
    char c;
    while ((c = waitkey()) != lf) {
      compprs("%c  ", c); // echo character typed
      dojumptable(c);
    }
  }
}
//---
bool dojumptable(char c) {
  // call compiler function by number
  if (c < '0') return true;
  switch (c) {
    case '0': compreturntogem(); break;
    case '1': return compilefile(); break;
    case '2': finishacode(); break;
    case '3': finishgamedatainmemory(); break;
    case '4': savegamedata(); break;
    case '5': rungame(); break;
    case '6': toggledebugginginfo(); break;
    case '7': toggleforcedlongjumps(); break;
    case '8': printsymboltable(); break;
    case '9': checkunusedsymbols(); break;
    case 'A': ToggleRS232Printer(); break;
    case 'B': if (splitdata) { finishwithoutacode(); break; }
    default: return false;
  }
  return true;
}
//---
void ToggleRS232Printer() {
  if (OutputDevice == 2) { // currently to CON:?
    SetRS232();
  } else {
    OutputDevice = 2; // CON:
    closelogfile();
    compprs("\nPrinting is now off. \n");
  }
}
//---
void SetRS232() {
  OutputDevice = 1; // AUX:
  openlogfile("compile.log");
  compprs("\nPrinting is now on. \n");
}
//---
void finishgamedata(bool noacode) {
  compprs("%s", finish_version);
  // this program produces a complete.dat file in memory
  // starting from acode.acd in memory and
  // from the rest of the data on disk
  finishedptr = startcomplete;
  // (allows space for acode beneath gamedata.dat)
  // now allow space for gamedata. Startsources is where
  // the exits etc. are loaded in transiently
  // in 1.5 with split data, gamedata can be big when still using combined
  startsources = finishedptr + (splitdata ? splitsizegamedata : sizegamedata);

  finishedptr += sizeofpointers;
  processexits();
  processtables();
  if (!splitdata) savedirectory(); // with split data no subdirs are used (1.5)

  if (!splitdata) selectdirectory(); // subdirectory for computer-specific text
  processsquash();
  if (!splitdata) climb(); // and back to root for acode

  // set up ptr = start of acode
  if (noacode) { // simulate zero-sized acode for split data (1.5)
    ptr = finishedptr;
    ptr[0] = 0;
    ptr[1] = 0;
  } else copyacode();
  processacodeptr();
  finishchecksum();

  savecompletedriverblock.start = startcomplete; // start address to save
  savecompletedriverblock.end = finishedptr; // end address to save
}
void finishwithoutacode() {
  finishgamedata(true); // mimick observed behaviour
}
void finishgamedatainmemory() {
  finishgamedata(false);
}
//---
void copyacode() {
  // work out length
  int len = compacodeptr - startacode + 8; // allow plenty of space for length pointer
  // make finishedptr even and zero out skip byte
  if (!oddacode && (finishedptr - startcomplete) & 1) *finishedptr++ = 0;
  // now copy it to current position in gamedata.dat i.e. at finishedptr
  memcpy(finishedptr, startacode - 2, len); // backstep over pointer
  ptr = finishedptr; // ptr = start of data in final position
}
//---
void savegamedata() {
  compprs("Saving acode.acd\n");
  saveacode();
  if (!splitdata) descend(); // with split data no subdirs are used (1.5)
  compprs("Saving gamedata.dat\n");
  compdriver(savedcode, &savecompletedriverblock);
  if (!splitdata) climb(); // leave us back where we started
}
//---
void rungame() {
  compprs("Running game...\n");
  for (int i = 0; i < 25; i++) prs("\n"); // clear screen
  if (!splitdata) descend();
  intinit1(); // first part of initialise
  if (forcedlongjumps) autoruninit(NULL);
  // get end of gamedata file
  intinitloadpics(savecompletedriverblock.end, startacode, debugginginfoon);
  intstart2();
}
//---
void toggledebugginginfo() {
  compprs("Debugging info is");
  debugginginfoon ^= 0xff;
  togglereport(debugginginfoon);
}
//---
void compdebuggingon() {
  // as part of a program
  debugginginfoon ^= 0xff;
}
//---
void CompCode() {
  // turn machine-code generation ON/OFF
  char c = compsearch();
  if (c != '+' && c != '-') {
    PlusOrMinusExpected();
    return;
  }

  if (c == CodeState) {
    AlreadyInState();
    return;
  }
  CodeState = c;
  // c is new code state
  if (c == '+') {
    // change to MC
    CurrentJumpTable = MCjumptable;
    if (testcomp) {
      if ((compacodeptr - startacode) & 1)
        EvenError(); // for testing purposes simulate alignment error
      else compskiptoeol();
      return;
    }
    compskiptoeol();
    code(opcchangecode);
    // is current code ptr (relative to startacode) EVEN?
    if (!i8086 && (compacodeptr - startacode) & 1) {
      compacodeptr++; // not done for PC in 1.5
    }
  } else {
    // change to acode
    CurrentJumpTable = CompJumpTable;
    compskiptoeol();
    if (!testcomp) MCToAcode();
  }
}
//---
void compcif() {
  // start of a section of conditional assembly
  struct _symbol *sym = NULL;
  bool found = findsymbol(&sym);
  if (!sym) return;
  if (found) {
    int type = sym->type & 0x7f;
    sym->type |= 0x80; // set "USED" bit
    if (type != constanttype) {
      badtype();
      return;
    }
    if (suppresscompilation || !sym->value) { // always supress nested cif
      // skip over conditional assembly code
      suppresscompilation++;
    } // non-zero, so allow it to be compiled.
  } else {
    // 'cif' as a variable is handled by caller
    syntaxerror();
    return;
  }
}
//---
void compcend() {
  // prevent it going negative
  if (--suppresscompilation < 0) suppresscompilation = 0;
}
//---
void toggleforcedlongjumps() {
  compprs("Forced long jumps are");
  forcedlongjumps ^= 0xff;
  togglereport(forcedlongjumps);
}
void togglereport(int t) {
  if (t == 0) nowoff();
  else compprs(" now on\n");
}
void nowoff() {
  compprs(" now off\n");
}
//---
void finishacode() {
  compprs("\nNumber of vars=%d", currentvarnumber);
  compflush();
  compprs("\nNumber of source lines=%d", TotalSourceLines);
  compflush();
  compprs("\n");

  // check here for remaining forward references
  int missing = 0;
  struct _symbol *sym = startsymbols;
  do {
    if (*sym->text && (sym->type & 0x7f) == undefinedlabeltype) {
      missing++;
      struct _forwardentry *entry = startforward + sym->value;
      do {
        compilationerrors = 1;
        compprs("\nMissing symbol '");
        absprintsymbol(sym);

        compprs("' which was referenced at line ");
        compprintdecimald0(entry->linenumber);
        compflush(); // print buffer contents

        compprs(" in file ");
        compprintdecimald0(entry->filenumber);
        compflush(); // print buffer contents

        entry = entry->next;
      } while (entry);
    }
    sym++;
  } while (sym < endsymbols);
  compprs("\n");
  if (missing) compprs("Number of missing symbols: %d\n", missing);

  if (compilationerrors) {
    compprs("Errors in compilation - code not saved\n");
    compprs("Press a key to return to gem\n");
    compwaitkey();
    compreturntogem();
    return;
  }
  // poke in length at start
  int len = compacodeptr - startacode + 2; // give space for end pointer
  *(char *)(startacode - 2) = len & 0xff; // allow space for length pointer
  *(char *)(startacode - 1) = len >> 8;
}
//---
void saveacode () {
  saveacodedriverblock.start = startacode - 2; // allow space for length pointer
  saveacodedriverblock.end = savedacodeptr; // end address
  compdriver(savedcode, &saveacodedriverblock);
}
//---

bool compilefile() {
  // load a file, with driver prompting for filename
  compsoftinit(); // init on each and every compile
  struct _fcb *fcb = (struct _fcb *)&compdriverbuffer;
  fcb->start = startsource;
  fcb->filename[0] = 0; // filename = null, so user must enter one
  compdriver(loaddcode, fcb);
  if (*(char *)fcb) return false; // not found
  abscompilefile();
  return true;
}
void abscompilefile() {
  char c;
  filenumber++;
  // ok, now compdriverbugger.start = start address
  // and compdriverbugger.end = end address of file just loaded
  struct _fcb *fcb = (struct _fcb *)&compdriverbuffer;
  char *buf = (char *)fcb->end;
  if (!buf) buf = startsource;
  buf[0] = eof; // add terminators
  buf[1] = eof; // (not necessarily word-aligned)
  buf[2] = cr;
  buf[3] = lf;
  buf[4] = eof;
  buf[5] = eof;

  // first find out what the terminator is
  // it is assumed there will be one and only one of these per line
  // other control codes are ignored completely by the compiler
  ptr = startsource;
  while (c = *ptr++, c != cr && c != lf);
  compterminator = c;

  ptr = startsource; // remains as pointer throughout

  // now start compiling it!
  displayline();

  // start by looking for const/var definitions
  c = checkforcontrolword();
  if (!c) {
    syntaxerror();
    return;
  }
  while (true) {
    switch (c) {
      case 1: c = mainprogram(); break;
      case 2: c = constantdefinitions(); break;
      case 3: c = tabledefinitions(); break;
      case 4: c = vardefinitions(); break;
      case eof: endofcompfile(); return; break;
      default: compilerbug(); return;
    }
  }
}

//---
void endofcompfile() {
  savedacodeptr = compacodeptr;
  compprs("End of source file.\n");
}
//---
int checkforcontrolword() {
  if (compsupersearch() == eof) return eof; // skip spaces, comments etc.
  return tablecompare(controlwords, numcontrolwords);
}
//---
int constantdefinitions() {
  if (debugginginfoon) {
    compprs("\nStarting constant definitions segment at ");
    compprintdecimald0(complinenumber);
    compflush(); // print buffer contents
    compprs("\n");
  }
  while (true) {
    char c = checkforcontrolword();
    if (c) return c;
    struct _symbol *sym = addsymbol(constanttype, 0); // dummy value
    // sym = address of symbol entry
    if (!sym) continue;
    if (*ptr++ != '=') {
      equalsexpected();
      continue;
    }
    // now get a number
    sym->value = compreaddecimal(&ptr);
  }
}
//---
int vardefinitions() {
  if (debugginginfoon) {
    compprs("\nStarting variable definitions at line ");
    compprintdecimald0(complinenumber);
    compflush(); // print buffer contents
    compprs("\n");
  }
  while (true) {
    char c = checkforcontrolword();
    if (c) return c;
    currentvarnumber++;
    // In split data (1.5) vars can go higher than 256
    // for MC purposes but are flagged when
    // used in non-MC sections
    if (currentvarnumber >= (splitdata ? 1025 : 256)) {
      TooManyVars();
      continue;
    }
    struct _symbol *sym = addsymbol(vartype, currentvarnumber);
    if (!sym) continue;
  }
}
int tabledefinitions() {
  if (debugginginfoon) {
    compprs("\nStarting table definitions at line ");
    compprintdecimald0(complinenumber);
    compflush(); // print buffer contents
    compprs("\n");
  }
  while (true) {
    char c = checkforcontrolword();
    if (c) return c;
    struct _symbol *sym = addsymbol(tabletype, 0); // dummy value
    // sym = address of symbol entry
    if (!sym) continue;
    if (*ptr++ != '=') {
      equalsexpected();
      continue;
    }
    // now get a number
    sym->value = compreaddecimal(&ptr);
  }
}
//---
int mainprogram() {
  if (debugginginfoon) {
    compprs("\nStarting main program at line ");
    compprintdecimald0(complinenumber);
    compflush(); // print buffer contents
    compprs("\n");
  }
  while (true) {
    char c = checkforcontrolword();
    if (c) return c;
    // defining a label ?
    if (*ptr == '.') {
      if (suppresscompilation) {
        compskiptoeol();
        continue;
      }
      ptr++; // move on to text of label
      struct _symbol *sym = addsymbol(labeltype, compacodeptr - startacode);
      if (!sym) continue;
      sym->codestate = CodeState;
      continue;
    }

    int keyword = tablecompare(compinstructiontable, (testcomp ? numinstructions + 1 : numinstructions));
    if (keyword == 6 && *ptr == '=' ) {
      // 'cif' here is being used as a variable, not a keyword
      keyword = 0;
      ptr -= 3;
    }
    if (suppresscompilation && keyword != (bugcomp ? 4 : 6) && keyword != 5) {
      // only keyword numbers 5/6 [bug: was 3/4, adjusted for ASR to 4/5]
      // (i.e. start/end conditional assembly)
      // are assembled in the middle of conditional assembly
      compskiptoeol(); // ignore instruction
      continue;
    }

    if (keyword) { // keyword number
      CurrentJumpTable[keyword & 0x3f]();
      continue;
    }

    // only other possibility is that it is an assignment
    // to a var or table
    // check for 16 bit list access...
    c = compsearch();
    if (c == '&') {
      SixteenFlag = 1;
      ptr++;
    } else {
      SixteenFlag = 0;
    }
    int index = 0;
    int base = 0;
    int n = -1;
    struct _symbol *sym = NULL;
    bool found = findsymbol(&sym);
    if (!sym) continue;
    if (!found) {
      badinstruction();
      continue;
    }
    int type = sym->type & 0x7f;
    sym->type |= 0x80;
    if (type == vartype) {
      if (compsearch() != '=') {
        equalsexpected();
        continue;
      }
      ptr++;
      compsearch();

      struct _symbol *sym2 = NULL;
      found = findsymbol(&sym2);
      if (!sym2) continue;
      if (found) {
        type = sym2->type & 0x7f;
        sym2->type |= 0x80;
        if (type == constanttype) {
          // assigning from a manifest constant
          n = sym2->value;
        } else if (type == tabletype) {
          // var=table(c/v)
          if (CodeState == '+') {
            MCAft(sym->value, sym2->value);
            continue;
          }

          if (SixteenFlag) {
            CantDo16();
            continue;
          }

          if (compsearch() != '(') {
            bracketsexpected();
            continue;
          }
          ptr++; // skip bracket

          struct _symbol *sym3 = NULL;
          found = findsymbol(&sym3);
          if (!sym3) continue;
          if (found) {
            type = sym3->type & 0x7f;
            sym3->type |= 0x80;
            if (type == vartype) {
              // a variable
              index = sym3->value; // value of var
              base = 0xa0; // base value for var=table(v)
            } else if (type != constanttype) {
              badindex();
              continue;
            } else {
              // a manifest constant
              index = sym3->value; // value of constant
              base = 0xc0; // base value for var=table(c)
            }
          } else {
            // a numeric value?
            index = getnumberconstant(); // will print an error message if not
            base = 0xc0; // base value for var=table(c)
            if (index < 0) continue;
          }

          if (compsearch() != ')') {
            bracketsexpected();
            continue;
          }
          ptr++; // skip bracket

          // now generate the code
          // first put in opcode - base value+table number
          code(sym2->value | base);

          // and the index
          if (index >= 0x100) {
            badindex(); // single byte index only
            continue;
          }
          code(index);

          // now thing not inside the brackets
          code(sym->value); // i.e. var to assign to
          continue;
        } else if (type != vartype) {
          varexpected();
          continue;
        } else {
          // var=var
          if (CodeState == '+') {
            MCLetVV(sym->value, sym2->value); // v1, v2
          } else {
            code(opcletvv); // opc
            code(sym2->value); // v2
            code(sym->value); // v1
          }
          continue;
        }
      } else {
        // assigning from constant?
        n = getnumberconstant();
        if (n < 0) continue;
      }
      // n = constant to assign from
      if (CodeState == '+') {
        MCLetVC(sym->value, n); // var, constant
      } else if (n < 0x100) {
        code(opcletvcsmall);
        code(n); // single byte constant only
        code(sym->value); // var
      } else {
        code(opcletvcbig);
        codew(n); // two byte constant
        code(sym->value); // var
      }
      continue;
    } else if (type == tabletype) {
      // have found a table identifier at start of line
      // i.e. want to do function of form @(V/C)=V
      if (compsearch() != '(') {
        bracketsexpected();
        continue;
      }
      ptr++; // skip bracket

      struct _symbol *sym2 = NULL;
      found = findsymbol(&sym2);
      if (!sym2) continue;
      if (found) {
        type = sym2->type & 0x7f;
        sym2->type |= 0x80;
        if (type == vartype) {
          // table(var)=var
          base = 0xe0; // base value for table(var)=var operations
          index = sym2->value;
          if (CodeState == '+') {
            MCAttVar(sym->value, index); // table, index
            continue;
          }
        } else if (type != constanttype) {
          badindex();
          continue;
        } else {
          // a manifest constant index
          index = sym2->value; // value of index
          base = 0x80; // base for table(const)=var operations
        }
      } else {
        // only remaining possibility is a numeric offset?
        index = getnumberconstant(); // will print an error message if not
        base = 0x80; // base for table(const)=var operations
        if (index < 0) continue;
      }
      // have value of the constant index - generate code for table(c)=v
      if (CodeState == '+') {
        MCAttConst(sym->value, index); // table, index
        continue;
      }

      if (SixteenFlag) {
        CantDo16();
        continue;
      }

      if (compsearch() != ')') {
        bracketsexpected();
        continue;
      }
      ptr++; // skip bracket

      if (compsearch() != '=') {
        equalsexpected();
        continue;
      }
      ptr++; // skip equals

      // now generate the code
      // first put in opcode - base value+table number
      code(sym->value | base);

      // and the index
      if (index >= 0x100) {
        badindex(); // single byte index only
        continue;
      }
      code(index);

      // and finally the var not inside the brackets
      int v = compgetvar();
      if (v) code(v);
      continue;
    } else {
      syntaxerror();
      continue;
    }
  } // back to mainprogloop
}
int getnumberconstant() {
  // a real number
  char c = compsearch();
  if (c < '0' || c > '9') {
    syntaxerror();
    return -1;
  }
  // yup, so generate the code
  return compreaddecimal(&ptr); // pointer immediately after number
}
//---
void compif() {
  // handle if v = <> < > then label
  opcodeaddress = compacodeptr;
  int value = 0;
  int opcode = 0;

  int v1 = compgetvar();
  if (!v1) return;
  int op = evaloperator(); // op = operator type
  if (op < 0) return;
  struct _symbol *sym = NULL;
  bool found = findsymbol(&sym);
  if (!sym) return;
  if (!found) {
    // only other possibility is a number
    value = getnumberconstant();
    if (value < 0) return;
  } else {
    int type = sym->type & 0x7f;
    sym->type |= 0x80; // set "USED" bit
    if (type == vartype) {
      code(op | 0x10);
      code(v1); // first var number
      code(sym->value); // second var number
      thenjump();
      return;
    } else if (type != constanttype) {
      badtype();
      return;
    } else {
      value = sym->value;
    }
  }

  opcode = op | 0x18;
  // now set up size bit
  if (value < 0x100) {
    opcode |= smallmask; // set sizebit - small constant
    code(opcode);
    code(v1); // first var number
    code(value); // single byte constant
  } else {
    code(opcode);
    code(v1); // first var number
    codew(value); // double byte constant
  }
  thenjump();
}
void thenjump() {
  // skip over "THEN" if present, then evaluate jump address
  compsearch();
  stringcompare("THEN");
  // stringcompare automatically skips string if matched
  jumpstuff();
}
int evaloperator() {
  // return code corresponding to operator
  char c = compsearch();
  ptr++; // skip operator
  if (c == '=') return eqop;
  if (c == '>') return gtop;
  if (c != '<') {
    badoperator();
    return -1;
  }
  c = *ptr;
  if (c != '>') return ltop;
  ptr++; // and skip > of <>
  return neop; // must have been <>
}
//---
void compgoto() {
  opcodeaddress = compacodeptr;
  code(opcgoto);
  jumpstuff();
}
void compgosub() {
  opcodeaddress = compacodeptr;
  code(opcgosub);
  jumpstuff();
}
bool jumpstuff() {
  // insert code for a jump to the label (ptr)
  // the address of the opcode for this jump is at opcodeaddress
  char c = compsearch();
  if (c == '@') ptr++; // skip @
  else if (!forcedlongjumps) {
    // relative jump, so set relbit in opcode
    *(char *)opcodeaddress |= relmask; // set relbit
  }

  struct _symbol *sym = NULL;
  int label = getlabel(&sym);
  if (label < 0) return false;
  if (!sym) return false;
  if (sym->codestate && sym->codestate != CodeState) {
    WrongCodeState();
    return false;
  }

  if (c == '@' || forcedlongjumps) {
    // absolute jump
    // getlabel gives value of label relative to start of acode
    // which is just what we want!
    codew(label);
  } else {
    // label is value of label relative to start of acode
    // find current address relative to start
    int delta = label - (compacodeptr - startacode);
    if (delta < 128 && delta >= -128) code(delta);
    else {
      reljumpoutofrange();
      return false;
    }
  }

  return true;
}
//---
int getlabel(struct _symbol **sym) {
  // return value of label relative to start of acode area
  // set up forward reference if label is not yet defined
  struct _forwardentry *entry = NULL;
  bool found = findsymbol(sym);
  if (!*sym) return -1;
  if (!found) {
    // freeforwardref = value of symbol - offset of first entry in chain in f/r table
    *sym = addsymbol(undefinedlabeltype, freeforwardref - startforward);
    if (!*sym) return -1;
    (*sym)->type |= 0x80; // set "USED" bit
  } else {
    int type = (*sym)->type & 0x7f;
    (*sym)->type |= 0x80; // set "USED" bit
    if (type == undefinedlabeltype) {
      // add a forward reference to a label which already
      // has some references to it, sym is entry in symbol table
      // scan through existing list
      // start with first forward reference entry
      entry = startforward + (*sym)->value;
      // then find end of list and link free entry
      while (entry->next) entry = entry->next;
      entry->next = freeforwardref;
    } else if (type != labeltype) {
      wronglabeltype();
      return -1;
    } else return (*sym)->value;
  }

  // and set up the new entry in the forward reference table
  // structure is:
  //  .. offset from start of table of next u/d reference to this symbol
  //  .. line number of reference
  //  .. offset from start of code of the reference
  //  .. offset from start of code of the opcode
  //  .. file number in which reference occured
  //  .. CodeState
  entry = freeforwardref;
  entry->next = NULL; // offset of next entry
  entry->linenumber = complinenumber;
  entry->ref = compacodeptr - startacode; // current pos relative to start of acode
  entry->opcode = opcodeaddress - startacode;
  entry->filenumber = filenumber;
  entry->codestate = CodeState;

  freeforwardref++; // and set up free space pointer
  if (freeforwardref >= endforward) {
    freeforwardref--;
    forwardrefoverflow();
    return -1;
  }
  // returning offset relative to acode start of opcode.
  // This is wrong for MC compilation because DummyOpcode used
  // for MC, return current acode position
  return (CodeState == '+') ? entry->ref : entry->opcode;
}
//---
void resolveforwardref(struct _symbol *sym) {
  // have just defined encountered ".label" which
  // is in the symbol table as type undefinedlabeltype
  // so zip through setting up all the jumps correctly
  // symbol table entry is sym
  // mark label as defined
  sym->type = labeltype | 0x80;
  struct _forwardentry *entry = startforward + sym->value;

  do {
    if (entry->codestate != CodeState) {
      ForwardWrongCodeState(sym, entry);
      return;
    }

    if (CodeState == '+')
      MCrfr(sym, entry);
    else {
      int label = compacodeptr - startacode;
      char *ref = (char *)(startacode + entry->ref);
      char opcode = *(char *)(startacode + entry->opcode);
      if (!(opcode & relmask)) {
        // poke back in address for a long jump
        // poke back two-byte reference
        *ref++ = label & 0xff; // low byte
        *ref   = label >> 8; // high byte
      } else {
        // poke back in address for short jump
        // make it relative to address of reference
        int delta = label - entry->ref;
        if (delta >= 128) { // >>was 0x100!
          forwardoutofrange(sym, entry); // note special line number treatment
          return;
        }
        *ref = delta; // poke in single byte reference
      }
    }

    // any more forward references?
    // at present, no garbage collection on forward
    // reference area. If this is needed (which I doubt)
    // then the easiest way is probably to have a free-space
    // linked list to which space is added. When space is
    // needed, it can be taken off the start of this list
    entry = entry->next; // next chained entry
  } while (entry);
}
//---
void addsub() {
  int v1 = compgetvar();
  if (!v1) return;
  if (compsearch() != ',') {
    commaexpected();
    return;
  }
  ptr++; // skip over comma
  int v2 = compgetvar();
  if (!v2) return;
  code(v2);
  code(v1);
}
void COMPADD() {
  code(opcaddvv);
  addsub();
}
void COMPSUB() {
  code(opcsubvv);
  addsub();
}
//---
void COMPACODEPRS() {
  // Compile a function call for acode prs - for acode debugging
  if (compsearch() != '"') {
    missingquote();
    return;
  }
  code(opcfunction);
  code(fncprs);
  ptr++; // skip over leading quote

  while (*ptr != '"') {
   if (*(uint8_t *)ptr == 0x9c) {
     poundsignnotallowed(); // pound sign is invisible + messes up capitalization
     return;
   }
   code(*ptr++);
  }
  ptr++; // skip over closing quote

  code(0); // add 0 to terminate
}
//---
void COMPCLEAR() {
  code(opcfunction);
  code(fncclear);
}
//---
void COMPCLS() {
  code(opcclear);
  compsearch();
  char c = toupper(*ptr++);
  if (c == 'T') {
    code(0);
  } else if (c == 'G') {
    code(1);
  } else {
    badarg();
  }
}
//---
void COMPDATA() {
  char c = 0;
  do {
    // should it be reset to zero?
    // since (in non-MC) '@' is always used
    // in DATA, this is not a problem?
    opcodeaddress = jumpdummyopcode;
    if (!jumpstuff()) return;
    c = compsearch();
    ptr++; // skip over comma
  } while (c == ',');
  if (c == ';') compssskiptoeol();
}
//---
void COMPDRIVEROPCODE() {
  code(opcfunction);
  code(fncacodedriver);
}
//---
void fourargs(char c) {
  code(c);
  for (int i = 0; i < 4; i++) {
    int v = compgetvar();
    if (!v) return;
    code(v);
  }
}
//---
void COMPEXIT() {
  fourargs(opcexit);
}
//---
void COMPINPUT() {
  fourargs(opcinput);
}
//---
void COMPGETNEXT() {
  code(opcgetnext);
  for (int i = 0; i < 6; i++) {
    int v = compgetvar();
    if (!v) return;
    code(v);
  }
}
//---
void COMPJUMP() {
  char longjumps = forcedlongjumps;
  forcedlongjumps = 1;

  opcodeaddress = compacodeptr;
  code(opccall);
  if (jumpstuff()) {
    int v = compgetvar();
    if (!v) return;
    code(v);
  }

  // and restore original value in forcedlongjumps
  forcedlongjumps = longjumps;
}
//---
void COMPMESSAGE() {
  int message = 0;
  struct _symbol *sym = NULL;
  bool found = findsymbol(&sym);
  if (!sym) return;
  if (found) {
    int type = sym->type & 0x7f;
    sym->type |= 0x80; // set "USED" bit
    if (type == constanttype) {
      // manifest constant
      message = sym->value;
    } else if (type != vartype) {
      badtype();
      return;
    } else {
      // message v
      code(opcmessagev); // opcode
      code(sym->value); // var number
      return;
    }
  } else {
    // numerical constant
    message = getnumberconstant();
    if (message < 0) return;
  }
  // message c
  if (message < 0x100) {
    code(opcmessagecsmall);
    code(message); // single byte constant
  } else {
    code(opcmessagecbig);
    codew(message); // double byte constant
  }
}
//---
void COMPPICTURE() {
  code(opcpicture);
  int v = compgetvar();
  if (!v) return;
  code(v);
}
//---
void COMPPRINT() {
  code(opcprint);
  int v = compgetvar();
  if (!v) return;
  code(v);
}
//---
void COMPPRINTINPUT() {
  code(opcprintinput);
}
//---
void COMPBREAKPT() {
  code(opcfunction);
  code(fncbreakpt);
}
//---
void COMPRANDOM() {
  code(opcfunction);
  code(fncrandom);
  int v = compgetvar();
  if (!v) return;
  code(v);
}
//---
void COMPRESTORE() {
  code(opcfunction);
  code(fncrestore);
}
//---
void COMPRETURN() {
  code(opcreturn);
}
//---
void COMPSAVE() {
  code(opcfunction);
  code(fncsave);
}
//---
void COMPSCREEN() {
  code(opcscreen);
  compsearch();
  char c = toupper(*ptr++);
  if (c == 'T') {
    code(0);
  } else if (c == 'G') {
    code(1);
    int v = compgetvar(); // dummy var for screeng g
    if (!v) return;
    code(v);
  } else {
    badarg();
  }
}
//---
void COMPSTACK() {
  code(opcfunction);
  code(fncstack);
}
//---
// now some general code generation subroutines
void codew(uint16_t w) {
  code(w & 0xff);
  code(w >> 8);
}
void code(uint8_t c) {
  // add code to current position in code
  *(uint8_t *)compacodeptr++ = c & 0xff;
  if (compacodeptr == endacode) {
    acodeoverflow();
    compacodeptr--;
  }
}
//---
int compgetvar() {
  // return value of var (ptr) in sym
  struct _symbol *sym = NULL;
  bool found = findsymbol(&sym);
  if (!sym) return 0;
  if (!found) {
    varnotdefined();
    return 0;
  }
  if ((sym->type & 0x7f) != vartype) {
    varexpected();
    return 0;
  }
  sym->type |= 0x80;
  return sym->value;
}
//---
void checkunusedsymbols() {
  compprs("Unused symbols... \n");

  int unused = 0;
  int total = 0;
  struct _symbol *sym = startsymbols;
  while (sym < endsymbols) {
    if (*sym->text) {
      total++;
      if (!(sym->type & 0x80)) {
        unused++;
        printsymbol(sym);
      }
    }
    sym++;
  }
  if (unused) compprs("Number of unused symbols: %d out of %d\n", unused, total);
  compprs("\n");
}
//---
void printsymboltable() {
  compprs("Symbol table...\n");
  // display all symbols
  int total = 0; // total number of symbols
  int hashed = 0; // symbols within hash table
  compprs("\n");

  struct _symbol *sym = startsymbols;
  // end of hash table
  struct _symbol *endhash = startsymbols + hashentries;

  while (sym < endsymbols) {
    if (*sym->text) {
      total++; // number of symbols
      printsymbol(sym);
    }
    sym++;

    if (sym == endhash) {
      compprs("-----------------\n");
      compprs("End of hash table\n");
      compprs("-----------------\n");
      hashed = total; // save number of symbols in hash table
    }
  }
  compprs("Total number of symbols = ");
  compprintdecimald0(total);
  compflush(); // print buffer contents
  compprs("\nOf which number in hash table = ");
  compprintdecimald0(hashed);
  compflush(); // print buffer contents
  compprs("\n\n");
}
//---
void printsymbol(struct _symbol *sym) {
  // print symbol (sym)
  // first print value
  compprintdecimald0(sym->value);
  compflush(); // print buffer contents
  compprs(" \t"); // tab

  absprintsymbol(sym);
  compprs("\n");
}
//---
void absprintsymbol(struct _symbol *sym) {
  // print symbol
  compprs("%s", sym->text);
}
//---

struct _symbol *addsymbol(char type, int value) {
  // add symbol (ptr) of alphanumeric characters
  // with type and value
  // return = address of symbol
  struct _symbol *sym = NULL;
  bool found = findsymbol(&sym);
  if (!sym) return NULL;
  if (found) {
    // only one type of symbol can be redefined
    // - where a "undefinedlabeltype" is to be replaced
    // by a "labeltype"
    if ((sym->type & 0x7f) != undefinedlabeltype || type != labeltype) {
      cantredefinesymbol();
      return NULL;
    }
    resolveforwardref(sym); // ok!
  } else {
    // sym = address of last symbol in chain found
    if (*sym->text) { // anything there?
      // yes, find the first free address and add a symbol in it
      // then chain on ptr at sym->ptr
      sym->ptr = freesymbol;
      sym = freesymbol;
      // and adjust free symbol pointer accordingly
      freesymbol++;
      if (freesymbol == endsymbols) {
        freesymbol--;
        symboltableoverflow();
        return NULL;
      }
      // no, fall through - first entry with this hash value
    }
    // there is space to add a symbol so do so
    int offset = 0;
    do {
      sym->text[offset++] = *ptr++;
    } while (compisd0alphanumeric(*ptr) && offset < symboltextlength);
    if (offset == symboltextlength) {
      sym->text[offset - 1] = 0;
      symboltoolong();
      return NULL;
    }
  }
  // set up type, value
  sym->type = (sym->type & 0x80) | type;
  sym->value = value;
  return sym;
}
//---
bool findsymbol(struct _symbol **sym) {
  // find symbol (ptr) of alphanumeric characters
  // return: *sym = address of symbol if found and int = 0
  // else int <> 0 and *sym = address of last symbol in chain

  // first do hash calculation on the symbol
  // to find the offset from the start of the symbol area
  compsearch();
  // offset from start of symbol area
  int hash = hashcalc();
  if (hash < 0) return false;
  *sym = startsymbols + hash;
  struct _symbol *current = *sym;
  // is there an entry there already?
  if (*current->text) {
    while (stringcompare(current->text) != 0) {
     // not found - any chained entries?
     current = current->ptr;
     if (!current) return false;
     *sym = current;
    }
    // In split data (1.5) only checked when used in non-MC
    if (splitdata && CodeState == '-' &&
        (*sym)->type == vartype && (*sym)->value >= 256) {
      *sym = NULL;
      TooManyVars();
      return false;
    }
    return true;
  } else return false;
}
//---
int hashcalc() {
  // from symbol at (ptr), return the offset from the
  // start of the hash table
  uint8_t hash = 0;
  int offset = 0;
  if (!compisd0alphanumeric(*ptr)) {
    badsymbol();
    return -1;
  }

  do {
    hash += toupper(*(ptr + offset)) - '0';
    offset++;
  } while (compisd0alphanumeric(*(ptr + offset)));

  // modulo hashentries
  return hash % hashentries;
}
//--- 
void displayline() {
  // display the line after the current pointer if debugging info is on
  if (!debugginginfoon) return;
  // display the previous 8 bytes
  compprs("\n");
  // display address relative to start of acode
  void *prev = compacodeptr - 8;
  comphexlonga0(prev - startacode);
  compprs(": ");
  for ( ; prev < compacodeptr; prev++) {
    comphexbyted0((prev < startacode) ? 0xff : *(char *)prev);
    compprs(" ");
  }
  compprs(" - ");
  // first give line number
  compprintdecimald0(complinenumber);
  compflush(); // print buffer contents
  compprs(": ");
  uint8_t *p = (uint8_t *)ptr;
  while (*p >= 32) compprs("%c", *p++);
  compflush(); // print buffer contents
}
//---
int tablecompare(char table[][tsize], int nentries) {
  // compare a word of alphanumerics at (ptr)
  // with table starting at table, which has nentries entries
  // each of length tsize
  // return keyword number or 0 if not found
  int lentry = -1;
  int uentry = nentries;
  while (true) {
    // get mid-point between lower and nentries as next comparison string
    int entry = (lentry + uentry) / 2;
    // do a single string compare
    int cmp = stringcompare(table[entry]);
    // have we finished?
    if (cmp == 0) return entry + 1; // found
    else if (uentry - lentry <= 2) return 0; // not found
    else if (cmp < 0) uentry = entry;
    else lentry = entry;
  }
}
//---
int stringcompare(char *text) {
  char *p = ptr;
  while (compisd0alphanumeric(*p)) p++;
  char orig = *p; // save original char

  *p = 0; // temporarily terminate string
  int cmp = strcasecmp(ptr, text);
  *p = orig; // restore original char

  if (cmp == 0) ptr = p; // advance ptr if match
  return cmp;
}
//---
void compssskiptoeol() {
  compskiptoeol();
  compsupersearch(); // on new line as well!
}
void compskiptoeol() {
  if (*ptr == eof) return;
  while (*ptr++ != compterminator);
  do {
    TotalSourceLines++;
    complinenumber++;
    // skip control characters (including false eol)
    uint8_t c = eof;
    while (c = *ptr++, c < 32 && c != compterminator && c != eof);
    ptr--;
    displayline();
  } while (*ptr++ == compterminator);
  ptr--;
}
int compsearch() {
  // search, skipping spaces
  while (*ptr == ' ') ptr++;
  return *ptr;
}
int compsupersearch() {
  // search, skipping over comments if present
  while (true) {
    uint8_t c = compsearch();
    if (c == eof) break;
    if (c == '*' || c == ';' || c == compterminator || c < 32) {
      compskiptoeol();
    } else break;
  }
  return *ptr;
}
//---
void forwardoutofrange(struct _symbol *sym, struct _forwardentry *entry) {
  compprs("\nForward reference to '");
  absprintsymbol(sym);

  compprs("' out of range at line ");
  FROREnd(entry);
}
void FROREnd(struct _forwardentry *entry) {
  // line number in which error occured
  compprintdecimald0(entry->linenumber);
  compflush(); // print buffer contents
  compprs(" in file ");
  // file number in which error occured
  compprintdecimald0(entry->filenumber);
  compflush(); // print buffer contents
  compprs("\n");
  comperror1();
}
//--- 
void varexpected() {
  compprs("\nVariable expected");
  comperror();
}
//---
void acodeoverflow() {
  compprs("\nAcode overflow");
  acodeerror = true;
  comperror();
  acodeerror = false;
}
//---
void symboltableoverflow() {
  compprs("\nSymbol table overflow");
  comperror();
}
//---
void symboltoolong() {
  compprs("\nSymbol too long");
  comperror();
}
//---
void varnotdefined() {
  compprs("\nVariable not defined");
  comperror();
}
//---
void compilerbug() {
  compprs("\nFatal compiler bug");
  comperror();
}
void comperror() {
  compprs(" at line ");
  compprintdecimald0(complinenumber);
  compflush(); // print buffer contents

  compprs(" in file '");
  compprintfilename();
  compprs("'\n");
  comperror1();
}
void comperror1() {
  // all errors come here
  compilationerrors = 1; // prevent saving of code
  if (!acodeerror) compssskiptoeol();
}
//---
void compprintfilename() {
  struct _fcb *fcb = (struct _fcb *)&compdriverbuffer;
  compprs("%s", getfilename(fcb));
}
//---
void chartoprinter(char c) {
  // now send it to the printer
// move.l a0,-(sp)
// move.w d0,-(sp) // this is argument for routine as well as preservation
// call_bdos c_auxout // send to printer - call_bdos c_conout
// addq.l 2,sp // remove function call number etc.
// move.w (sp)+,d0
// move.l (sp)+,a0
// rts
}
//---
void TooManyVars() {
  compprs("\nToo many variables");
  comperror();
}
//---
void forwardrefoverflow() {
  compprs("\nThe forward reference table overflowed");
  comperror();
}
//---
void cantredefinesymbol() {
  compprs("\nCan't redefine symbol");
  comperror();
}
//---
void badsymbol() {
  compprs("\nBad symbol");
  comperror();
}
//---
void equalsexpected() {
  compprs("\nEquals expected");
  comperror();
}
//---
void commaexpected() {
  compprs("\nComma expected");
  comperror();
}
//---
void bracketsexpected() {
  compprs("\nBracket expected");
  comperror();
}
//----
void MCTooFar() { // Introduced in 1.5
  compprs("\nLong jump out of range");
  comperror();
}
//----
void reljumpoutofrange() {
  compprs("\nRelative jump out of range");
  comperror();
}
//---
void badindex() {
  compprs("\nBad table index");
  comperror();
}
//---
void badtype() {
  compprs("\nBad type");
  comperror();
}
//---
void badoperator() {
  compprs("\nBad operator");
  comperror();
}
//---
void poundsignnotallowed() {
  compprs("\nPound sign is not allowed in prs");
  comperror();
}
//---
void missingquote() {
  compprs("\nMissing quote");
  comperror();
}
//---
void badarg() {
  compprs("\nBad argument");
  comperror();
}
//---
void badinstruction() {
  compprs("\nInstruction not recognized");
  comperror();
}
//---
void wronglabeltype() {
  compprs("\nSymbol redefined as different type");
  comperror();
}
//---
void compnotimp() {
  compprs("\nSomething not implemented");
  comperror();
}
//---
void syntaxerror() {
  compprs("\nSyntax error");
  comperror();
}
//---
void PlusOrMinusExpected() {
  compprs("\nPlus or minus expected");
  comperror();
}
//---
void AlreadyInState() {
  compprs("\nAlready in specified code state");
  comperror();
}
//---
void NotAllowedInAcode() {
  compprs("\nInstruction not allowed in interpreted acode");
  comperror();
}
//---
void NotAllowedInMC() {
  compprs("\nInstruction not allowed in machine code");
  comperror();
}
//---
void EvenError() {
  compprs("\nMC must be even-aligned");
  comperror();
}
//---
void CantDo16() {
  compprs("\nCan't do 16 bit tables in interpreted mode");
  comperror();
}
//---
void WrongCodeState() {
  compprs("\nCan't jump into area of different code state");
  comperror();
}
//---
void ForwardWrongCodeState(struct _symbol *sym, struct _forwardentry *entry) {
  compprs("\nForward reference to '");
  absprintsymbol(sym);
  compprs("' changes code state at line ");
  FROREnd(entry);
}
//---
void usage(char *progname) {
  printf("Usage: %s [options]\n\n", progname);
  printf("Options:\n");
  printf("--help: print this usage message\n");
  printf("--bugcomp: enable bugwards compatibility (e.g. for conditional compilation)\n");
  printf("--oddacode: do not align acode in gamedata.dat\n");
  printf("--testcomp: limit sizes to test overflow errors\n");
  printf("--i8086: generate MC code for i8086\n");
  printf("--splitdata: generate split acode and gamedata\n");
  printf("\n");
  exit(0);
}
int main(int argc, char **argv) {
  int arg = 0;
  while (++arg < argc) {
    if (strcmp(argv[arg], "--help") == 0) usage(argv[0]);
    if (strcmp(argv[arg], "--bugcomp") == 0) { bugcomp = true; continue; }
    if (strcmp(argv[arg], "--oddacode") == 0) { oddacode = true; continue; };
    if (strcmp(argv[arg], "--testcomp") == 0) { testcomp = true; continue; };
    if (strcmp(argv[arg], "--i8086") == 0) { i8086 = true; Mc8086(); continue; };
    if (strcmp(argv[arg], "--splitdata") == 0) { splitdata = true; continue; };
    printf("Unrecognized argument: '%s'\n\n", argv[arg]);
    usage(argv[0]);
  }
  compstart();
  compmenu();
  return 0;
}
