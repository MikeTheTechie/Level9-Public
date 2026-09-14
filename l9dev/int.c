// 68000 Acode interpreter (adapted for Linux)
//
// Copyright (C) 1986 Level 9 Computing
//
// M.J.Austin 13/7/86
//
// Linux version started 30/1/26
// first presentable version: 13/2/26

#include "int.h"

//---
bool debug = false;
bool huge = false;
int16_t popvar = -1;
void *endint;
char intdriverbuffer[500];

// file control blocks
struct _fcb savedriverblock = {
  NULL,
  NULL,
  "xxxxxxxx.xxx"
};
//---
struct _fcb gamedatadriverblock = {
  // gives loading data for game data
  NULL, // used as load address
  NULL,
  "gamedat1.dat"
};
char *gamedatafilename = NULL;
//---
struct _fcb acodedriverblock = {
  // for acode in split data mode
  NULL, // used as load address
  NULL,
  "acod1.dat"
};
char *acodefilename = NULL;
char *logfilename = NULL;
//---

// workspace
uint8_t *hugelistarea = NULL;
uint8_t *LongWorkspace = NULL;
uint8_t *WordWorkspace = NULL;
uint8_t *ByteWorkspace = NULL;
uint8_t *LogicalScreenBase = NULL;
uint8_t *PhysicalScreenBase = NULL;
uint8_t *pntrs_tab = NULL;
uint8_t *FastFindObjectTable = NULL;
uint8_t *InvertFlag = NULL;
uint32_t *FreeWorkspace = NULL;
uint16_t *RasterOffset = NULL;
uint16_t *CursorXPos = NULL;
uint16_t *CursorYPos = NULL;
uint32_t *SBStart = NULL;
uint32_t *LogicalBase = NULL;
uint32_t *PhysicalBase = NULL;
uint32_t *hugelistptrs = NULL;
struct _workspace workspace = { 0, };
uint16_t *vartable = workspace.vartable;
//---

// now data block for file
uint8_t *absdatablock[12] = {
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
};
//
uint8_t *enddata = NULL;
uint8_t *acodeend = NULL;
uint8_t *pc = NULL;
uint8_t *hugesystemstart = NULL;
uint8_t *hugesystemend = NULL;
uint8_t *hugevbl = NULL;
bool mc = false;
void *startramsavearea = NULL;

//       ---

// language defines
#define jumphmask 0x80  // jump header or message header
#define parsemask 0x40  // message contains keywords
#define longmask  0x80  // short or long form reference
// special short-codes
#define longc  0x1a     // long escape code
#define endseg 0x1b     // segment end marker
#define header 0x1c     // header short code
#define screenwidth 79
#define uppercasemark 0x10

// language workspace
uint8_t *startmd = NULL; // address of start of message descriptors
uint8_t *endmd = NULL; // end address+1 of message descriptors
uint8_t *endwdp5 = NULL; // address+6 of end of word dictionary
int mdtmode = 0;
char *wrapbufferpointer = NULL;
uint8_t *list9ptr = NULL;
char *ibuffpointer = NULL;
int keywordnumber = 0;
int abrevword = 0;
uint8_t unpackbuffer[64];
char threecharacters[33]; // word expansion buffer

char wrapbuffer[32];
#define wrapbufferend (wrapbuffer + sizeof(wrapbuffer))

char obuff[33]; // lower case input buff
char ibuff[500]; // ascii input buffer
uint8_t nchars = 0;
char lastchar = 0;
uint8_t width = 0;
uint8_t lastheader = 0;
uint16_t unpackoffset = 0;
uint8_t *packedptr = NULL;
bool wordcase = false;
char pendspace = 0;
bool resetmenu = false;
//       ---

// general workspace
bool retins = false;
bool resetins = false;
bool restartins = false;
bool popins = false;
uint16_t breakpointaddress = 0;
uint8_t textmode = 0;
char debuggingstatus = 0;
int tracedinstructions = 0;

// gno workspace
uint16_t searchdepth = 0;
uint16_t hisearchpos = 0;
uint16_t searchpos = 0;
uint16_t object = 0;
uint16_t numobjectfound = 0;
uint16_t inithisearchpos = 0;
uint16_t hipos = 0;
uint16_t *hisearchposvar = NULL;
uint16_t *searchposvar = NULL;
uint8_t *gnosp = NULL;
uint16_t maxobject = 0;
uint8_t gnospbase[127]; // should give plenty of space
#define gnospinitial (gnospbase + sizeof(gnospbase))
#define nonspecific 31
uint8_t gnoscratch[nonspecific + 1];

// jump table
void (*jumptable[])(uint8_t) = {
  intgoto,
  intgosub,
  intreturn,
  printnumber,
  messagev,
  messagec,
  function,
  input,
  varcon,
  varvar,
  intadd,
  intsub,
  ToMC,
  ilins,
  intjump,
  intexit,
  ifeqvt,
  ifnevt,
  ifltvt,
  ifgtvt,
  screen,
  cleartg,
  picture,
  getnextobject,
  ifeqct,
  ifnect,
  ifltct,
  ifgtct,
  printinput,
  ilins,
  ilins,
  ilins
};

//--
void intinitloadpics(void *freememory, void *startacode, bool startdebug) {
  enddata = freememory;
  // graphics caches not needed
  // so startramsavearea comes immediately after game data
  startramsavearea = freememory; // start of memory for ram save

  // select debugging mode
  debuggingstatus = startdebug ? stepmodecode : runmodecode;
  if (startdebug) debuggingHelp();

  // now convert relative addresses supplied at start
  // of data to absolute addresses
  // data will be copied to here in absolute form
  uint8_t **adbptr = absdatablock;
  // pointer to pointer being processed
  uint8_t *address = (uint8_t *)startfile + 18;
  uint16_t val = 0;
  int nptrs = 0x0c; // no. of pointers to adjust
  while (nptrs--) { // all pointers done ?
    void *base = startfile;
    // get relative pointer (low byte first on 6502/Z80, remember)
    val  = *address++;
    val += *address++ << 8;
    // check if it was a workspace list reference
    if (nptrs && val >= 0x8000 && val < 0x9000) {
      base = listarea;
      // this pointer is now relative to listarea
      val -= 0x8000;
    } // acodeptr is always relative to startfile
    *adbptr++ = base + val;
  }
  if (splitdata) acodeptr = startacode;

  // other pointers
  address = (uint8_t *)startfile + 2;
  val  = *address++;
  val += *address++ << 8; // startmd
  startmd = (uint8_t *)startfile + val;
  val  = *address++;
  val += *address++ << 8; // md length
  endmd = startmd + val;
  val  = *address++;
  val += *address++ << 8; // wd offset
  void *wdoffset = startfile + val;
  val  = *address++;
  val += *address++ << 8; // wd length
  endwdp5 = wdoffset + val + 5;
}

void intinit1() {
  driver(initdcode, intdriverbuffer);
  driver(clgdcode, intdriverbuffer);
}

void loadingerror() {
  prs("Please restore game dir to original state and hit space!\n");
  waitkey();
}

void copyfilename(struct _fcb *fcb, char *filename) {
  *fcb->filename = 0x80; // pointer to filename
  *(char **)(fcb->filename + 1) = filename;
}

void intinitialise2() {
  bool ok = false;
  void *freememory = NULL;
  void *startacode = NULL;
  struct _fcb *gamedatafcb = &gamedatadriverblock;
  struct _fcb *acodefcb = &acodedriverblock;

  do {
    if (gamedatafilename) {
      gamedatafcb = (struct _fcb *)intdriverbuffer;
      copyfilename(gamedatafcb, gamedatafilename);
    }
    gamedatafcb->start = startfile;
    driver(loaddcode, gamedatafcb); // load in data for game
    ok = (*(char *)gamedatafcb == 0);
    if (!ok) loadingerror();
  } while (!ok);
  freememory = gamedatafcb->end;
  startacode = freememory + 2; // skip length

  if (splitdata) do {
    if (acodefilename) {
      acodefcb = (struct _fcb *)intdriverbuffer;
      copyfilename(acodefcb, acodefilename);
    }
    acodefcb->start = startacode - 2; // include length
    driver(loaddcode, acodefcb); // load in acode for game
    ok = (*(char *)acodefcb == 0);
    if (!ok) loadingerror();
    else freememory = acodefcb->end;
  } while (!ok);

  intinitloadpics(freememory, startacode, debug);
}

void intinitialise() {
  intinit1();
  intinitialise2();
}

void intstart2() {
  while (true) {
    checksumgamedata();
    pc = acodeptr; // initialise pc

    // set up random number seed
    if (setrandomseed)
      randomseed = setrandomseed;
    else {
      driver(randomnumberdcode, intdriverbuffer);
      if (autorun || demo)
        randomseed = 42; // start from predictable seed
      else
        randomseed = *(uint16_t *)intdriverbuffer;
      setrandomseed = randomseed; // save for re-init
    }

    wrapreset();
    ibuffpointer = NULL;

    uint16_t acodelen = acodeptr[-2];
    acodelen += acodeptr[-1] << 8; // acode length
    acodeend = acodeptr - 2 + acodelen;
    vartable = workspace.vartable;

    // check for HUGE games
    if (*(uint32_t *)acodeptr == 0x00040004) {
      // initialize HUGE per architecture
      huge = true; // data @Start,@Start of HUGE
      pc = acodeptr + 4; // code +
      uint16_t arch = pc[1];
      if (arch) i8086 = true;
      else i8086 = false;
      if (i8086) initpchuge();
      else initsthuge();

      // configure terminal for HUGE
      inputnoecho = true;
      set_input_mode(false);
      reset_input_mode();

      // initialize vars and lists for HUGE
      vartable = startramsavearea;
      hugelistarea = (uint8_t *)(vartable + hugevars);
      hugelistptrs = (uint32_t *)(hugelistarea + 16384);
      hugelistptrs[0] = (void *)vartable - (void *)startfile;
      for (int i = 2; i <= 11; i++) {
        uint8_t *ptr = absdatablock[i];
        uint32_t offset = 0;
        if (ptr >= startfile && ptr < enddata)
          offset = ptr - startfile;
        else
          offset = (ptr - listarea) + (hugelistarea - startfile);
        hugelistptrs[i - 1] = offset;
        absdatablock[i] = startfile + offset;
      }
      hugelistptrs[11] = (void *)hugelistptrs - (void *)startfile;

      for (int i = 12; i <= 28; i++)
        hugelistptrs[i] = (hugelistarea + 0x460 + i * 32) - startfile;

      LongWorkspace = (uint8_t *)(hugelistptrs + 32);
      hugelistptrs[29] = LongWorkspace - startfile;
      WordWorkspace = LongWorkspace + 512;
      hugelistptrs[30] = WordWorkspace - startfile;
      ByteWorkspace = WordWorkspace + 128;
      hugelistptrs[31] = ByteWorkspace - startfile;
      memset(LongWorkspace, 0, 512 + 128 + 32);

      LogicalScreenBase = ByteWorkspace + 32;
      PhysicalScreenBase = LogicalScreenBase + 65536;
      pntrs_tab = PhysicalScreenBase + 65536;
      FastFindObjectTable = pntrs_tab + 30;
      int lastsize = 4010 / 16 * 4;
      void *lastvar = FastFindObjectTable;

      FreeWorkspace = (uint32_t *)(LongWorkspace + 124);
      *FreeWorkspace = lastvar + lastsize - (void *)startfile;

      InvertFlag = (uint8_t *)(ByteWorkspace + 3);
      RasterOffset = (uint16_t *)(WordWorkspace + 56);
      CursorXPos = (uint16_t *)(WordWorkspace + 0);
      CursorYPos = (uint16_t *)(WordWorkspace + 2);
      SBStart = (uint32_t *)(LongWorkspace + 128);
      LogicalBase = (uint32_t *)(LongWorkspace + 12);
      *LogicalBase = 0xfe7f0f00;
      PhysicalBase = (uint32_t *)(LongWorkspace + 16);
      *PhysicalBase = 0x00700f00; // 0x000eeffe -> 0xfeef0e00
    }

    // get and execute instruction
    while (!retins && !restartins) {
      instructionloop();
      popins = false;
      resetins = false;
    }
    retins = false;
    restartins = false;
  }
}

void instructionloop() {
  while (pc < acodeend) {
    if (huge && mc && pc < hugesystemend) {
      systemcall();
      retins = true;
    } else {
      debugging();
      executeinstruction(*pc++);
    }
    if (retins || popins || resetins || restartins) return;
  }
  prs("\n...end of acode reached, exiting...\n");
  returntogem();
}

void executevbl() {
  static int countmc = 0;
  countmc %= 8192;
  if (countmc++) return;
  ByteWorkspace[9] = 0; // ByteFrameReadyFlag for ST
  uint8_t *retaddr = pc;
  pc = hugevbl;
  instructionloop(); // stack loops
  if (popins) {
    popins = false;
    vartable[popvar] = retaddr - acodeptr;
  } else {
    retins = false;
    pc = retaddr;
  }
}

void executemc(uint8_t code) {
  if (hugevbl) executevbl();
  if (i8086) executepcmc(code);
  else executestmc(code);
}

void executeinstruction(uint8_t code) {
  if (mc) executemc(code);
  else if (code & 0x80) listhandler(code);
  else jumptable[code & 0x1f](code);
}

void debugging() {
  if (debuggingstatus != runmodecode)
    traceinstruction();
}

// ++ CALL THIS to stop execution and give option of trace etc.
void traceinstruction() {
  bool ecf = executingcommandfile;
  executingcommandfile = false;
  // acode instruction to be executed next
  uint8_t code = *pc;
  if (debuggingstatus == tracemodecode ||
      debuggingstatus == 'I') {
    if (debuggingstatus == tracemodecode)
      intdisplayinstruction(code);
    if (debuggingstatus == 'I')
      // running in interruptible mode - check for breakpoint address
      checkbreakpoint();
    // keep tracing fast enough
    if (ecf || ++tracedinstructions == 10) {
      tracedinstructions = 0;
      driver(osrdchdcode, intdriverbuffer);
      executingcommandfile = ecf;
      if (!*intdriverbuffer) return; // no, so continue running
      executingcommandfile = false;
      debuggingstatus = stepmodecode; // select full debugging
    } else return;
  }
  displayvariables();
  // now display instruction to execute next
  prs("about to execute %sinstruction: ", mc ? "MC " : "");
  intdisplayinstruction(code);

  // get debugging option from terminal
  getdebuggingoption();
  executingcommandfile = ecf;
}

void intdisplayinstruction(uint8_t code) {
  prs("$%04X $%02X\n", pc - acodeptr, code);
}

void displayvariables() {
  prs("Variables:\n");
  displaymemorya1(vartable, 16);
}

void displaymemorya1(uint16_t *address, int n) {
  // display 16 words in hex format
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < 16; j++)
      prs("$%04X ", address[i * 16 + j]);
    prs("\n");
  }
}

//       ---

void debuggingHelp() {
  prs("\n68000 Acode debugging package 0.1\n"
      "Copyright (C) 1986 Level 9 Computing.\n"
      "M.J.Austin 17/2/86\n\n"
      "The following commands are valid:\n"
      " R .. run game from current position.\n"
      " I .. interruptible mode - runs until a key is pressed\n"
      " B .. set breakpoint at a known address\n"
      " M .. display memory (relative to acode start)\n"
      " T .. trace\n"
      " S .. or any other key to single step\n"
      " Q .. Return to Monst or GEM.\n"
      " ? .. Display this menu\n\n");
}

void getdebuggingoption() {
  while (true) {
    prs("Command: ");
    char c = waitkey();

    // now echo the selection:
    prs("%c\n", c);
    c = toupper(c);

    // now look at what the user wanted
    switch (c) {
      case '?':
      case 'H':
        debuggingHelp();
        break;

      case 'Q':
        generatebreakpoint();
        return;

      case 'I': // interruptible mode
        startrunning(c);
        return;

      case 'B':
        setbreakpoint();
        debuggingstatus = 'I';
        return;

      case 'S':
        debuggingstatus = stepmodecode; // full debugging mode
        return;

      case 'R':
        startrunning(runmodecode);
        return;

      case 'T':
        debuggingstatus = c;
        return;

      case 'M':
        debuggingstatus = c;
        displaymemory();
        break;

      default:
        // key not recognized - put into step mode to avoid damage
        debuggingstatus = stepmodecode;
        return;
    }
  }
}

void startrunning(char c) {
  prs("Running ... \n");
  debuggingstatus = c;
}

void displaymemory() {
  // prompt for address and display a small block of memory
  prs("Enter address relative to acode start to display: ");
  displaymemorya1((uint16_t *)acodeptr + getaddress(), 16);
}

void generatebreakpoint() {
  // send monitor back to MonST or tos
  prs("\n"
      "Press M to go to MonST (will crash if not present)\n"
      "      G to return to Gem or return to continue: \n");

  char c = toupper(waitkey());
  if (c == 'M')
    *(uint16_t *)NULL = 0x4afa; // generate SEGV (to be caught with gdb)
  else if (c == 'G')
    returntogem();
}

// ---

void setbreakpoint() {
  prs("Enter address of acode breakpoint in hex: ");
  breakpointaddress = getaddress();
}

int getaddress() {
  driver(inputlinedcode, intdriverbuffer);
  return strtol(intdriverbuffer, NULL, 16);
}

void checkbreakpoint() {
  if (pc - acodeptr == breakpointaddress) {
    prs("Breakpoint.\n");
    debuggingstatus = stepmodecode;
  }
}

//---
void ToMC(uint8_t code) {
  // in case we had to pad
  if (!i8086 && ((pc - acodeptr) & 1)) pc++;
  mc = true;
}
//---
void messagec(uint8_t code) {
  printmessage(getcon(code));
}

void messagev(uint8_t code) {
  printmessage(*getvar());
}

void intgoto(uint8_t code) {
  pc = getaddr(code);
}

void intgosub(uint8_t code) {
  uint8_t *address = getaddr(code);
  uint8_t *retaddr = pc;
  pc = address;
  instructionloop(); // stack loops
  if (popins) {
    popins = false;
    vartable[popvar] = retaddr - acodeptr;
  } else {
    mc = false;
    retins = false;
    if (!resetins) pc = retaddr;
  }
}

void intreturn(uint8_t code) {
  retins = true;
}

void varcon(uint8_t code) {
  // var:=con
  varvar1(getcon(code));
}

void varvar(uint8_t code) {
  varvar1(*getvar());
}

void varvar1(uint16_t val) {
  // write val into var (acode)
  *getvar() = val;
}

void intadd(uint8_t code) {
  uint16_t val = *getvar();
  *getvar() += val;
}

void intsub(uint8_t code) {
  uint16_t val = *getvar();
  *getvar() -= val;
}

uint16_t getcon(uint8_t code) {
  // return constant stored in code, sized according to sizemask
  int val = 0;
  if (code & sizemask) { // small?
    // get a 8 bit value from pc
    return *pc++;
  } else {
    // get 16 bit value from acode in reverse-format
    val  = *pc++;
    val += *pc++ << 8;
    return val;
  }
}

uint8_t *getaddr(uint8_t code) {
  // return address to jump to
  int val = 0;
  if (code & relativemask) { // relative?
    // get a 8 bit relative offset from pc
    // and sign-extend it
    val = *(int8_t *)pc++;
    // make it relative to address of offset byte
    return pc + val - 1;
  } else {
    val  = *pc++;
    val += *pc++ << 8;
    return acodeptr + val;
  }
}

uint16_t *getvar() {
  // return address of var (acode)
  // note: value not returned (unlike other versions of interpreter)
  int val = *pc++; // get var number from acode
  return vartable + val; // get index into var table
}

uint32_t getmaxind(uint8_t *table) {
  uint32_t maxind = 0;
  if (huge) maxind = 0x10000;
  else if (table >= listarea && table < listarea + listareasize)
    maxind = listarea + listareasize - table;
  else if (table >= startfile && table < enddata)
    maxind = enddata - table;
  return maxind;
}

uint8_t *gettable(uint8_t num) {
  uint8_t *table = NULL;
  if (huge && num < 32)
    table = startfile + hugelistptrs[num];
  else if (!huge && num < 10)
    table = listtbl[num];
  return table;
}

uint16_t readtable16(void *table16, uint16_t index) {
  uint8_t *table = (uint8_t *)table16;
  uint16_t val = table[index] << 8;
  val += table[index + 1];
  return val;
}

uint32_t readtable32(void *table32, uint16_t index) {
  uint8_t *table = (uint8_t *)table32;
  uint32_t val = table[index] << 24;
  val += table[index + 1] << 16;
  val += table[index + 2] << 8;
  val += table[index + 3];
  return val;
}

void writetable16(void *table16, uint16_t index, uint16_t val) {
  uint8_t *table = (uint8_t *)table16;
  table[index] = val >> 8;
  table[index + 1] = val;
}

void writetable32(void *table32, uint16_t index, uint32_t val) {
  uint8_t *table = (uint8_t *)table32;
  table[index] = val >> 24;
  table[index + 1] = val >> 16;
  table[index + 2] = val >> 8;
  table[index + 3] = val;
}

void listhandler(uint8_t code) {
  uint8_t *table = NULL;
  uint16_t index = 0;
  uint16_t *var = NULL;
  if (code >= 224) {
    // listN(var)=var
    code -= 224;
    // get start of list - equivalent of getind
    table = gettable(code);
    index = *getvar();
    var = getvar();
    if (!table) ilins(code);
    else if (index < getmaxind(table))
      table[index] = *var;
  } else if (code >= 192) {
    // var=listN(cons)
    code -= 192;
    // get start of list - equivalent of getind
    table = gettable(code);
    // bits 8-15 were set to 0 because index into list table <40
    index = *pc++; // get constant index into list
    var = getvar();
    if (!table) ilins(code);
    else *var = table[index];
  } else if (code >= 160) {
    // var=listN(var)
    code -= 160;
    // get start of list - equivalent of getind
    table = gettable(code);
    index = *getvar();
    var = getvar();
    if (!table) ilins(code);
    else if (index < getmaxind(table))
      *var = table[index];
  } else { // code=128-159
    // listN(cons)=var
    code -= 128;
    // get start of list - equivalent of getind
    table = gettable(code);
    // bits 8 to 15 of code were set to 0 because index to list table <40
    index = *pc++; // get constant index into list
    var = getvar();
    if (!table) ilins(code);
    else table[index] = *var;
  }
}

void ifthen(bool jump, uint8_t code) {
  uint8_t *address = getaddr(code);
  if (jump) pc = address;
}

int checkequv(uint8_t code) {
  int var1 = *getvar();
  int var2 = *getvar();
  return var2 - var1;
}

void ifeqvt(uint8_t code) {
  // if v=v then ...
  ifthen(checkequv(code) == 0, code);
}

void ifnevt(uint8_t code) {
  // if v<>v then ...
  ifthen(checkequv(code) != 0, code);
}

void ifltvt(uint8_t code) {
  // if v<v then ...
  ifthen(checkequv(code) > 0, code);
}

void ifgtvt(uint8_t code) {
  // if v>v then ...
  ifthen(checkequv(code) < 0, code);
}

int checkequc(uint8_t code) {
  int var = *getvar();
  int con = getcon(code);
  return con - var;
}

void ifeqct(uint8_t code) {
  // if v=c then ...
  ifthen(checkequc(code) == 0, code);
}

void ifnect(uint8_t code) {
  // if v<>c then ...
  ifthen(checkequc(code) != 0, code);
}

void ifltct(uint8_t code) {
  // if v<c then ...
  ifthen(checkequc(code) > 0, code);
}

void ifgtct(uint8_t code) {
  // if v>c then ...
  ifthen(checkequc(code) < 0, code);
}

//---
void acodeprs() {
  // print the text following the function call up to 0
  // for debugging purposes only
  while (*pc) printchar(*pc++);
  pc++;
}
//---
void function(uint8_t code) {
  switch (*pc++) {
    case 1: // was stop originally
      calldriver();
      break;
    case 2:
      intrandom();
      break;
    case 3:
      save();
      break;
    case 4:
      restore();
      break;
    case 5:
      clearworkspace();
      break;
    case 6:
      resetstack();
      break;
    case 250:
      acodeprs();
      break;
    default: ilins(code);
  }
}
//---
void resetstack() {
  // reset stack
  resetins = true;
}

void clearworkspace() {
  // reset all vars to 0
  memset(vartable, 0, sizeof(workspace.vartable));
}

// copy across structure ptrs, converting
// from relative to absolute etc.
void setup_ptrs() {
  int16_t count = 0;
  // calc buffer as address of list# passed in v1.
  uint8_t *buffer = gettable(vartable[1]);

  // buffer is structure buffer
  // *buffer is ptr to list.
  writetable32(SBStart, 0, buffer - startfile);
  uint8_t *ptr = pntrs_tab;
  uint32_t bufstart = buffer - startfile;
  for (count = 5; count; count--) {
    writetable32((uint32_t *)ptr, 0, bufstart + readtable32((uint32_t *)buffer, 0));
    ptr += 4;
    buffer += 4;
    writetable16((uint16_t *)ptr, 0, readtable16((uint16_t *)buffer, 0));
    ptr += 2;
    buffer += 2;
  }

  ptr = FastFindObjectTable; // start with object 0.
  buffer = startfile + bufstart + 32;
  for (uint16_t objno = 0; objno < 4000; objno += 16) {
    // given objno as object number, return buffer as pointer to structure.
    writetable32((uint32_t *)ptr, 0, buffer - startfile); ptr += 4;
    for (count = 16; count; count--)
      buffer += readtable16((uint16_t *)buffer, 0);
  }
}

uint32_t MikeFindObj(uint16_t objno) {
  // given objno as object number, return pointer to structure.
  objno--; // convert object numbering from 1..n to 0..n-1
  uint16_t index = objno; // base index off original object number
  index >>= 2; // divide by 16 (address of every 16th object is stored)
  index &= 0xfffc; // and multiply by 4 (4 bytes per entry)
  uint8_t *ffo = FastFindObjectTable;
  ffo += index;
  ffo = startfile + readtable32(ffo, 0);
  index <<= 2; // regain the object number whose address is a0
  // now get difference between our fast entry and the actual object we want to find.
  objno -= index;
  for ( ; objno; objno--) ffo += readtable16(ffo, 0);
  return ffo - startfile;
}

uint32_t find_obj(uint16_t objno) {
  uint32_t obj = 0;
  uint16_t objid = 0;
  uint8_t  objsz = 0;
  objno &= 0x7fff;
  uint16_t objmk = objno; // pass objmk as parameter to MikeFindObj
  uint8_t *ptr = pntrs_tab; // 1st data pointer
  obj = readtable32((uint32_t *)ptr, 0); ptr +=4; // x,z,h,#'s
  // object is 'x,z,h,#' type?
  if (objno <= readtable16((uint16_t *)ptr, 0)) {
    // object is 'x,z,h,#' type
    objid = 4; // object type
    objno--;
    if (objno) {
      objno--;
      obj = MikeFindObj(objmk);
    }
    uint16_t d2 = (readtable16((uint16_t *)(startfile + obj), 0) - 4) / 5; // needed for other calls?
    d2 = d2; // dummy assignment to keep compiler happy
    return obj;
  }
  ptr += 2; obj = readtable32((uint32_t *)ptr, 0); ptr +=4; // rasters
  // object is raster?
  if (objno <= readtable16((uint16_t *)ptr, 0)) {
    // object is a raster block
    objno += readtable16(RasterOffset, 0);
    objmk = objno; // store off new real object number for MikeFindObject
    objid = 1;
  } else {
    ptr += 2; obj = readtable32((uint32_t *)ptr, 0); ptr +=4; // animats pointer
    if (objno <= readtable16((uint16_t *)ptr, 0)) objid = 2; // animation type
    //if (debug && objid) prs("object is animation type\n");
  }
  if (objid) {
    objno -= readtable16(ptr - 8, 0) + 1; // 1st obj ?
    if (objno) { // no
      objno--;
      obj = MikeFindObj(objmk);
    }
    objmk = readtable16(startfile + obj, 0) - 4;
    // null-length raster object
    if (!objmk) return obj;
    objmk >>= 1;
    objsz = *(uint8_t *)(startfile + obj + 2) - 4;
    // zero x size raster object.
    if (objsz) objsz = objmk / objsz;
    return obj;
  }
  ptr += 2; obj = readtable32((uint32_t *)ptr, 0); ptr +=4; // compresseds
  // object is compressed type?
  if (objno <= readtable16((uint16_t *)ptr, 0)) {
    // object is compressed type
    objid = 5; // compressed type
    return obj;
  }
  ptr += 2; obj = readtable32((uint32_t *)ptr, 0); ptr +=4; // cell data
  // object is a cell
  objid = 3; // cell id
  objmk = -1;
  objno -= readtable16(ptr, 0) + 1; // take off mincell
  obj += objno * 128; // data
  return obj;
  // obj = object start
  // objid = object id
  // objmk = object data list length
  // objsz = object y height (raster)
  objid = objid; // dummy assignment to keep compiler happy
}

void clearmenu() {
  prs("\033[J\033[1A"); // Erase below, go up 1 line
  prs("\033[%dG", nchars + 1); // Go to end of output
  prs("\033[?25h"); // Enable cursor
}

void systemcall() {
  uint16_t vector = (pc - hugesystemstart) / 6;
  switch (vector) {
    case 0x00: // HeroOnceOnlyInit
    case 0x01: // HeroInit
      break;
    case 0x0f: // MCOswrchV1 (assumed only used for menu)
      static bool mcoswrchv1 = false;
      static bool inverted = false;
      static char oldmenu[6][41] = { { 0 } };
      static char newmenu[6][41] = { { 0 } };
      mcoswrchv1 = true;
      if (resetmenu) {
        memset(oldmenu, 0, sizeof(oldmenu));
        memset(newmenu, 0, sizeof(newmenu));
        inverted = false;
        resetmenu = false;
        if (output_terminal())
          prs("\033[?25l\n"); // Disable cursor and newline
      }
      uint16_t cxp = readtable16((uint16_t *)CursorXPos, 0) / 8;
      uint16_t cyp = readtable16((uint16_t *)CursorYPos, 0) / 8;
      if (cxp >= 40 || cyp >= 6) return;
      if (cyp == 0 && inverted && !*InvertFlag) {
        if (output_terminal() && memcmp(oldmenu, newmenu, sizeof(newmenu))) {
          inverted = false;
          for (int16_t y = 0; y < 6; y++) {
            for (int16_t x = 0; x < 41; x++) {
              char c = newmenu[y][x];
              inverted = (c & 0x80); c &= 0x7f;
              if (inverted) prs("\033[7m");
              else prs("\033[0m");
              *intdriverbuffer = c ? c : ' ';
              driver(oswrchdcode, intdriverbuffer);
            }
            prs("\n");
          }
          prs("\033[6A"); // Go back 6 lines
          memcpy(oldmenu, newmenu, sizeof(newmenu));
        }
        memset(newmenu, 0, sizeof(newmenu));
        inverted = false;
      }
      inverted |= *InvertFlag;
      newmenu[cyp][cxp++] = vartable[1] | (*InvertFlag << 7);
      if (cxp == 40) cxp = 0, cyp++;
      if (cyp == 6) cyp = 0;
      writetable16((uint16_t *)CursorXPos, 0, cxp * 8);
      writetable16((uint16_t *)CursorYPos, 0, cyp * 8);
      break;
    case 0x13: // MCCloseDown
      returntogem();
      break;
    case 0x21: // MCOsrdch
      if (mcoswrchv1) mcoswrchv1 = false;
      else if (!resetmenu && output_terminal()) {
        clearmenu();
        resetmenu = true;
      }
      driver(osrdchdcode, intdriverbuffer);
      char c = toupper(*intdriverbuffer);
      vartable[1] = c;
      vartable[2] = c >= 'A' ? c - 'A' : c;
      switch (c) { // For use with NumLocked keypad
        case '6': // right
          vartable[2] = 108;
          break;
        case '4': // left
          vartable[2] = 106;
          break;
        case '8': // up
          vartable[2] = 104;
          break;
        case '2': // down
          vartable[2] = 110;
          break;
        case '5': // stop
          vartable[2] = 107;
          break;
        case '+': // climb
          vartable[2] = 115;
          break;
        case '-': // descend
          vartable[2] = 116;
          break;
        case '3': // right2
          vartable[2] = 128;
          break;
        case '7': // left2
          vartable[2] = 126;
          break;
        case '9': // up2
          vartable[2] = 124;
          break;
        case '1': // down2
          vartable[2] = 120;
          break;
      }
      break;
    case 0x2a: // MCCalcScreenAddress
      hugelistptrs[vartable[1]] = LogicalScreenBase - startfile;
      hugelistptrs[vartable[2]] = PhysicalScreenBase - startfile;
      break;
    case 0x2c: // MCLoadFile
      char *filename = (char *)gettable(17) + 8;
      int len = strlen(filename);
      char *lower = malloc(len + 1);
      for (int i = 0; i <= len; i++)
        lower[i] = tolower(filename[i]);
      uint8_t *buffer = gettable(vartable[1]) + vartable[2];
      len = (vartable[5] << 16) + vartable[6]; // not used
      if (debug) prs("Request to load '%s'\n", lower);
      FILE *fp = fopen(lower, "r");
      if (fp) {
        if (debug) prs("Loading ...\n");
        vartable[1] = fread(buffer, 1, 0xf0000, fp);
        fclose(fp);
      } else {
        vartable[1] = 0;
      }
      free(lower);
      break;
    case 0x2d: // MCCopy
      uint8_t *src = gettable(vartable[1]) + vartable[2];
      uint8_t *dst = gettable(vartable[3]) + vartable[4];
      uint16_t n = vartable[5];
      memcpy(dst, src, n * 2);
      break;
    case 0x30: // MCSetUpPtrs
      setup_ptrs();
      break;
    case 0x34: // MCAddToListPtr
      uint32_t offset = vartable[2] << 16;
      offset += vartable[3];
      hugelistptrs[vartable[1]] += offset;
      break;
    case 0x35: // MCReserveMemory
      *FreeWorkspace += vartable[1];
      break;
    case 0x36: // MCSetUpVariablePtrs
      // dummy values
      vartable[1] = 0x11e6; // v1 SetUpVariablePtrs
      vartable[2] = 0x0008; // v2 hi pool size in bytes
      vartable[3] = 0xf32a; // v3 lo pool size in bytes
      break;
    case 0x45: // MCFindObj
      // obj is object found
      uint32_t obj = find_obj(vartable[1]); // v1 is object number to find.

      // list v2 is start of structure buffer
      // sbuffer is start of structure buffer list.
      uint32_t sbuffer = hugelistptrs[vartable[2]];

      // return v3 as offset in structure buffer
      vartable[3] = obj - sbuffer; // get offset from start of structure buffer
      break;
    default: if (debug) prs("Unimplemented systemcall: $%02X\n", vector);
  }
}

void calldriver() {
  uint8_t code = *list9startptr;
  uint8_t *data = list9startptr + 1;
  switch (code) { // driver code to call
    case initdcode:
      return;
    case ramsavedcode:
      intram(code, data);
      break;
    case ramloaddcode:
      intram(code, data);
      break;
    case chainprogramdcode:
      chainprog(data);
    default: driver(code, data);
  }
}
//---
void intram(uint8_t code, uint8_t *data) {
  // set up args for the drivercall
  // *data is position number
  uint8_t pos = *data;

  if (pos > 250)
    *data = 1;
  else {
    ((void **)data)[0] = workspacestart;
    ((void **)data)[1] = workspaceend;
    ((void **)data)[2] = startramsavearea + pos * sizeof(workspace);
    driver(code, data);
  }
  *list9startptr = *data; // copy result for interpreter
  // reset values to keep listarea deterministic
  // also WIP(MSX) parsing is corrupted by it
  // in case of a (semi-legal) construct like:
  // "THROW BOX NORTH"
  // whereas this (fully legal) construct works fine:
  // "THROW BOX. NORTH"
  // it may be that the parser still wants to look at
  // the INPUT results after doing a RAM save?
  ((void **)data)[0] = NULL;
  ((void **)data)[1] = NULL;
  ((void **)data)[2] = NULL;
}
//---
void chainprog(uint8_t *data) {
  // load in the next section of the game and initialise system
  // patch file name
  char *filename = NULL;
  char *part = NULL;

  filename = gamedatafilename ? gamedatafilename :
             gamedatadriverblock.filename;
  part = filename + strlen(filename) - 5;
  if (!*data) (*part)++;
  else *part = '0' + *data;

  if (splitdata) {
    filename = acodefilename ? acodefilename :
               acodedriverblock.filename;
    part = filename + strlen(filename) - 5;
    if (!*data) (*part)++;
    else *part = '0' + *data;
  }

  intinitialise2(); // do full init, except screen
  restartins = true;
}
//---
void intrandom() {
  randomseed =
    ((((randomseed << 8) | 10) - randomseed) << 2) + randomseed + 1;
  *getvar() = randomseed & 0xff; // zero high byte of var
}

void save() {
  savedriverblock.start = workspacestart;
  savedriverblock.end = workspaceend;
  *savedriverblock.filename = 0; // prompt user for filename
  driver(savedcode, &savedriverblock);
}

void restore() {
  savedriverblock.start = workspacestart;
  *savedriverblock.filename = 0; // prompt user for filename
  driver(loaddcode, &savedriverblock);

  if (*(char *)&savedriverblock != 0) {
    prs("Press a key to restart. ");
    waitkey();
    prs("\n"); // I don't know if this is necessary

    flush();
    restartins = true;
  } else checksumgamedata();
}
//---
void checksumgamedata() {
  if (splitdata) return; // not done in split data mode
  uint8_t *address = startfile;
  struct _fcb *fcb = (struct _fcb *)intdriverbuffer;
  fcb->start = address;
  int len = address[0]; // low byte of length
  len += address[1] << 8; // length of file
  fcb->end = address + len;
  driver(checksumdcode, fcb);
  if (*(uint8_t *)fcb != 0) {
    prs("Don't panic ... CHECKSUM ERROR !!!\n\n"
        "Press a key to continue ... ");
    waitkey();
  }
}
//---
void stopgint() {
  // setuppictured0(0); // XXX
  driver(taskinitdcode, intdriverbuffer);
}

void clearg() {
  if (textmode) {
    stopgint();
    // gintclearg(); // XXX
  }
}

void cleartg(uint8_t code) {
  if (*pc++) clearg();
}

void screen(uint8_t code) {
  textmode = *pc++;
  if (textmode) {
    pc++;
    flush(); //>> mike 24/8/86 - fix "WORDS,PICTURES"->" K."
    clearg();
    driver(settextdcode, intdriverbuffer);
    return;
  }
}
//---
void picture(uint8_t code) {
  /*int pic = **/getvar(); // picture number to draw
  if (!textmode) {
    // setuppictured0(pic); // XXX
    driver(taskinitdcode, intdriverbuffer);
  }
}
//---
void printnumber(uint8_t code) {
  uint16_t n = *getvar();
  uint16_t d = 10000; // max 65535
  bool z = false;
  do {
    uint16_t q = n / d;
    uint16_t r = n % d;
    if (q > 0 || d == 1) z = true;
    if (z) printchar('0' + q);
    n = r;
    d /= 10;
  } while (d > 0);
}

void intexit(uint8_t code) {
  // from, dir, status, newroom
  uint8_t room = *getvar();
  uint8_t dir = *getvar();
  uint16_t res = exit1(room, dir);
  // res = status | newroom
  uint8_t newroom = res & 0xff;
  uint8_t status  = res >> 8;
  *getvar() = (status & 0x70) >> 4;
  *getvar() = newroom;
}

uint16_t exit1(uint8_t from, uint8_t direction) {
  // given from, direction; return status | TO room
  uint8_t *eptr = exitsptr;
  uint8_t status = 0;
  uint8_t room = from;

  if (from) { // catch special case of FROM being 0
    room--;
    while (room) {
      uint8_t entry = *eptr;
      if (!entry) break;
      eptr += 2;
      if (entry & 0x80) // end of room list
        room--;
    }
  }

  if (from && *eptr) {
    // got FROM room
    // now find entry direction
    do {
      status = *eptr++; // get status
      room = *eptr++; // get to room
      if ((status & 0x0f) == direction) // got an entry
        return room | (status << 8);
    } while (!(status & 0x80));
    // end of entries for this room - now try reversibles
  }

  // first pass failed, so try reversible exits
  // first invert direction
  uint8_t exitreversaltable[] = {
    0, 4, 6, 7, 1, 8, 2, 3, 5, 10, 9, 12, 11, 13, 14, 15 };
  direction = direction < 16 ? exitreversaltable[direction] : 255;

  // find exit going to FROM room with right direction and reversible
  eptr = exitsptr;
  room = 1; // room counter (TO room)
  do {
    status = *eptr++;
    uint8_t to = *eptr++;
    if (status & 0x10) { // reversible?
      // it's reversible, but is it in the right direction ?
      if ((status & 0x0f) == direction) {
        // and does it go to the right place ?
        if (to == from)
          return room | (status << 8); // found it!
      }
    }
    // try another exit
    // test status on previous exit
    if (status & 0x80) room++; // inc room number
  } while (status); // at end of exits file ?

  return 0; // no destination found
}

void getnextobject(uint8_t code) {
  // given: hisearchpos,searchpos
  // return: object,number of of object in this pass
  // if hi,searchpos=0 then initialise search
  // at end of search, return object=0

  maxobject = *getvar();

  hisearchposvar = getvar();
  hisearchpos = *hisearchposvar;

  searchposvar = getvar();
  searchpos = *searchposvar;

  // cycle through levels
  while (gnoabs());
}

bool gnoabs() {
  if (!searchpos && !hisearchpos) {
    initgetobjsp(); // set up,ret
    return false;
  }

  if (!numobjectfound)
    // start of a new pass
    inithisearchpos = hisearchpos;

  while (true) {
    object++;
    if (list2ptr[object] != searchpos) {
      if (object < maxobject) continue;
      else {
        // reached end of current pass
        if (inithisearchpos == nonspecific) {
          // started off as non-specific search, so there
          // may be unscanned directions to try
          gnoscratch[hisearchpos] = 0;
          hisearchpos = 0;
          do {
            if (gnoscratch[hisearchpos]) {
              *--gnosp = searchpos;
              *--gnosp = hisearchpos;
            }
            hisearchpos++;
          } while (hisearchpos < nonspecific);
        }

        // start of new level ?
        gnopop();
        numobjectfound = 0;
        if (hisearchpos == nonspecific)
          // nonspecific hisearchpos, so this is a real new level
          searchdepth++;
        initgetobj();
        if (searchpos)
          return true; // cycle through new level
        else {
          object = 0;
          hisearchpos = 0;
          searchpos = 0;
          gnoreturnargs();
          return false;
        }
      }
    }

    // a quick check suggests we may have something here
    hipos = list3ptr[object] & 0x1f;
    if (hipos != hisearchpos) {
      if (!hipos || !hisearchpos) continue;
      else {
        // want same object in different containment
        if (hisearchpos != nonspecific) {
          // gotcha - so note it down for reference at end
          gnoscratch[hipos] = hipos;
          continue;
        } else {
          // start looking for this type rather than nonspecific type
          hisearchpos = hipos;
        }
      }
    }

    numobjectfound++;
    *--gnosp = object;
    *--gnosp = nonspecific;
    // found object, so return it to calling prog
    gnoreturnargs();
    return false;
  }
}

void gnoreturnargs() {
  // return args to acode
  *hisearchposvar = hisearchpos;
  *searchposvar = searchpos;
  *getvar() = object;
  *getvar() = numobjectfound;
  *getvar() = searchdepth;
  return;
}

void initgetobjsp() {
  gnosp = gnospinitial;
  searchdepth = 0;
  initgetobj();
  gnoreturnargs();
}

void initgetobj() {
  numobjectfound = 0;
  object = 0;
  memset(gnoscratch, 0, nonspecific);
}

void gnopop() {
  if (gnosp != gnospinitial) {
    hisearchpos = *gnosp++;
    searchpos = *gnosp++;
  } else {
    hisearchpos = 0;
    searchpos = 0;
  }
}

//       ---

void intjump(uint8_t code) {
  // rel pos of jump table
  uint16_t jmp = 0;
  jmp  = *pc++;
  jmp += *pc++ << 8;
  // indexed by variable
  pc = acodeptr + jmp + *getvar() * 2;
  jmp  = *pc++;
  jmp += *pc++ << 8;
  pc = acodeptr + jmp;
}

void ilins(uint8_t code) {
  pc--;
  prs("\nIllegal %sinstruction: $%02X at $%04X\n", mc ? "MC " : "", code, pc - acodeptr);
  debugging(); // ?????
  pc++;
}

void fatalerror() {
  prs("\nfatal error. Press space to return to OS\n");
  while (waitkey() != ' ');
  returntogem();
}

void printinput(uint8_t code) {
  // acode instruction with no arguments
  // print last input word processed
  char *bufptr = obuff;
  while (*bufptr != ' ') printchar(*bufptr++);
}

void input(uint8_t code) {
  corruptinginput();
  pc += 4; // skip variable parameters
}

void corruptinginput() {
  // input routine which corrupts all registers (origin of asm name)
  // if last input returned end or line, then get more input from user
  list9ptr = list9startptr;
  if (!ibuffpointer) {
    // get keyboard input
    flush();
    wrapreset();
    if (debug && !executingcommandfile)
      prs("[#... to debug] ");
    driver(inputlinedcode, ibuff);
    ibuffpointer = ibuff;
    if (debug && (executingcommandfile || ibuff[0] == '#')) {
      if (!executingcommandfile) ibuffpointer++; // skip '#'
      debuggingstatus = stepmodecode;
    }
    // Is nextpart set through the #next autorun command?
    if (nextpart) {
      nextpart = false;
      chainprog((uint8_t *)""); // zero to indicate next part
    }
  }

  // copy next input word to obuff converting to upper case
  // and removing transparent characters
  char c = 0;
  char c2 = 0;
  // cptr is address of end of previous word
  char *cptr = ibuffpointer;
  char *optr = obuff;
  do {
    c = *cptr++; // get character from input word
    if (!c) // end of input
      ibuffpointer = NULL; // zero ibuffpointer - forced to get input next time
    else if (partword(c)) // could c be part of a word ?
      break; // could c be part of a word ?
    else if (c == ' ') continue;
    else {
      // no - so return it as an ascii character, unless it's just a space
      ibuffpointer = cptr; // write pointer back to ibuffpointer
      *list9ptr++ = 0;
      *list9ptr++ = c;
      *optr = ' ';
      keywordnumber = 0xffff; // force printinput to print obuff
    }
    // write double zero to indicate end of input list
    *list9ptr++ = 0;
    *list9ptr++ = 0;
    return; // return to acode
  } while (c == ' ');

  // have an input word
  cptr--; // only executed for first char of word
  do {
    c = *cptr++;
    if (!partword(c)) break;
    // copy one character of word
    c = tolower(c);
    *optr++ = c;
  } while (optr < obuff + 31); // is the buffer full ?

  // buffer full, simulate end of word
  *optr = ' ';
  cptr--; // make cptr point to char which caused the copy to stop
  ibuffpointer = cptr;
  // convert word in obuff to word number
  abrevword = 0xffff;
  keywordnumber = 0xffff;
  list9ptr = list9startptr;

  // setindex
  uint8_t *itable =  startfile +
                     startfile[10] +
                    (startfile[11] << 8);
  uint16_t nsegs  =  startfile[12] +
                    (startfile[13] << 8);
  // now itable=address of start of index table
  // nsegs is number of segments left

  // find dictionary block and wordnumber base
  bool searching = true;
  uint16_t dictblock = 0;
  uint16_t wordnum = 0xffff; // no word number base
  c = obuff[0] - 'a';
  if (c < 0) {
    // first character not ascii, so must be in first segment
    // first segment has no pointer,
    // dictionary address = start of dictionary, first wordnumber=0
    // dictblock=wordaddress(z80) = start of word dictionary
    dictblock = startfile[6] + (startfile[7] << 8);
    wordnum = 0; // set up word number in first segment
  } else {
    // c is first letter of input word-'a'
    // i.e. if it is alpha, it has a code 0-25
    uint8_t seg = 103; // number of last segment
    if (c < 26) {
      seg = c << 2; // seg is now segment number based on first char
      // if there is a second character in the input word,
      // we can be more precise:
      c = obuff[1];
      if (c != ' ') {
        // get an extra two bits resolution on segment number
        seg += ((c - 'a') >> 3) & 3;
      } // have to make do with segment number in seg
    }

    // seg is segment number
    // now find dictblock as address of dictionary segment relative to startfile
    // and seg as first word number of this segment
    if (seg < nsegs) { // does segment exist?
      // itable is start of index table(from setindex)
      // get index into index table (4 bytes per entry)
      uint8_t *index = itable + (seg << 2);
      // index=entry in index table
      // get relative address of dictionary segment
      dictblock = index[0] + (index[1] << 8);
      wordnum = index[2] + (index[3] << 8);
    }
  }

  // find exact word number of the input word
  if (wordnum != 0xffff) { // do we have a word number base ?
    // have got wordnum as word number at start of segment
    // and dictblock as address of dictionary block
    initunpack(dictblock);
    while (searching) {
      while (searching) {
        if (unpackword()) { // not end of dictionary ?
          // have a word in threecharacters
          // try comparing it with the input word
          optr = obuff;
          cptr = threecharacters;
          int matches = -1; // no. of chars which match
          do {
            matches++;
            c = tolower(*cptr++ & 0x7f); // word from dictionary
            c2 = *optr++; // word from user input
          } while (c == c2);
          if (c2 != ' ') { // end of input word ?
            if (abrevword != 0xffff) {
              // have already had an abbreviated word,
              // so can't accept another unsatisfactory one
              keywordnumber = 0xffff;
              break;
            }
          } else {
            // yes, so was it a complete match ?
            if (!c) {
              keywordnumber = wordnum;
              break;
            } else {
              // no, so can we take it as an abbreviation ?
              if (abrevword != 0xffff) searching = false;
              else {
                // how many characters matched?
                if (matches >= 4) {
                  keywordnumber = wordnum;
                  break;
                }
                // could be an abbreviation
                abrevword = wordnum;
              }
            }
          }
        } else {
          if (abrevword != 0xffff) {
            keywordnumber = abrevword;
            break;
          }
          searching = false;
        }
        wordnum++;
      }

      if (searching) {
        // have got word number in wordnum
        // now fill list9 with a sequence of possible word-type/message-number
        // possibilities terminated by 0x00 0x00
        // write to keywordnumber for benefit of printinput
        findmsgequiv(keywordnumber);
        abrevword = 0xffff;
        if (list9ptr != list9startptr) break;
        else {
          // no words found - garbage word
          wordnum++;
        }
      }
    }
  }

  if (!searching) {
    // not a keyword, try it for a number
    if (*obuff >= '0' && *obuff <= '9') {
      optr = obuff;
      // returns number in n
      int n = readdecimal(&optr);
      // in older games a number may have been 4 bytes without 1
      // at least the GS/DK interpreter seems to believe that
      // v3 games should interpret it like that but the sources
      // available all expect it the way it is done here
      *list9ptr++ = 1; // 1 indicates this is a number
      *list9ptr++ = n;
      *list9ptr++ = n >> 8;
      *list9ptr++ = n >> 16;
    } else {
      // garbage word - return 0x00 0x80
      *list9ptr++ = 0x00;
      *list9ptr++ = 0x80;
    }
  }

  // write double zero to indicate end of input list
  *list9ptr++ = 0;
  *list9ptr++ = 0;
  return; // return to acode
}

void findmsgequiv(uint16_t wordnum) {
  // given word number wordnum
  // return in list9 lots and lots of messages containing
  // meaningful (marked) references to it
  uint16_t code = 0;
  uint16_t msgnum = 0xffff;
  uint8_t *mptr = startmd;
  // have we passed the end of message descriptor table
  // mptr>endmd - have searched all messages
  while (mptr <= endmd) {
    msgnum++;
    code = *mptr;
    if (code & jumphmask) { // jump header ?
      // jump in message numbering
      mptr++;
      msgnum += code & 0x7f; // allow for gap
    } else {
      // found a message header
      if (code & parsemask) {
        // have found a message header which contains keywords
        int msglen = getmdlength(&mptr);
        // loop through message finding any references
        while (msglen) { // if message length=0, nothing to print
          code = *mptr++;
          msglen--; // decrement length due to byte fetched
          if (code & longmask) { // long form reference
            if (code >= 0x90) { // interesting word
              code = (code << 8) + *mptr++;
              msglen--; // decrement length due to extra byte fetched
              // compare with word we're looking for
              if ((code & 0x0fff) == wordnum) {
                // code contains whole word, high-bits are word type
                // write it to list 9 in appropriate format:
                // add in message number
                code = ((code << 1) & 0xe000) | msgnum;
                *list9ptr++ = code >> 8;
                *list9ptr++ = code;
                // space allowed for returns
                if (list9ptr >= list9startptr + 32) {
                  // break out two while loops
                  msglen = 0;
                  mptr = endmd + 1;
                }
              } // not same, so get another from dictionary
            } else { // garbage word
              mptr++;
              msglen--; // decrement length due to byte fetched
            }
          } // short form reference - no meaning
        }
      } else // no keywords, skip message
        mptr += getmdlength(&mptr);
    }
  }
}

void initunpack(uint16_t dictblock) {
  initdict(dictblock);
  lastheader = header;
  unpackword();
}

bool unpackword() {
  if (lastheader == endseg)
    return false; // padder at end of segment
  // get pointer to expansion buffer allowing for similarity
  char *dptr = threecharacters + (lastheader & 3);
  while (true) {
    uint8_t code = getdictionarycode();
    if (packedptr >= endwdp5) // at end of dictionary ??
      return false;
    if (code >= endseg) {
      lastheader = code;
      *dptr = 0;
      return true;
    }
    // not a header
    *dptr++ = getdictionary(code);
  }
}

//       ---

bool partword(uint8_t c) {
  // return true if c could be part of a word
  c = tolower(c);
  return  c == '\'' || c == '-' ||
         (c >= '0' && c <= '9') ||
         (c >= 'a' && c <= 'z');
}

void printmessage(uint16_t msgnum) {
  // print message number msgnum
  absprintmessage(msgnum);
}

void absprintmessage(int16_t msgnum) {
  uint8_t *cwd =  startfile +
                  startfile[14] +
                 (startfile[15] << 8);
  unpackoffset = 8;
  uint8_t *mptr = startmd;

  // search through message descriptor table, decrementing
  // message number msgnum until =0
  uint16_t code = 0;
  // have we passed the end of message descriptor table
  while (msgnum && mptr <= endmd) { // is message number = 0 ?
    code = *mptr;
    if (!(code & jumphmask)) { // jump header ?
      // skip message
      mptr += getmdlength(&mptr);
      // end of message
      msgnum--;
    } else {
      // jump in message numbering
      mptr++; // skip message header
      // given value 0 gives actual gap of 1
      // allow for gap
      msgnum -= (code & 0x7f) + 1;
      if (msgnum < 0) return;
    }
  }
  if (msgnum) return; // end of mdt reached and msg not found

  // have found required message header
  // if jump header, actual number is still higher,
  // hence too high for msgnum
  if (*mptr & jumphmask) return;
  uint16_t msglen = getmdlength(&mptr);
  // loop through message until length to print=0
  while (msglen) { // if message length=0, nothing to print
    code = *mptr++;
    msglen--; // decrement length due to byte fetched
    if (!(code & longmask)) {
      // short form reference
      // set of two byte word numbers
      uint8_t *entry = cwd + code * 2;
      // build up word number
      code = (entry[0] << 8) + entry[1];
    } else {
      // long form reference
      code = (code << 8) + *mptr++;
      msglen--; // decrement length due to extra byte fetched
    }

    // display word reference code
    if (code == 0x8f80) // is it a | terminator ?
      return; // if so, nothing more to display
    displaywordref(code);
  }
}

// ---

uint16_t getmdlength(uint8_t **mptr) {
  // *mptr is the address in the message descriptors of a message header
  // return: *mptr=address of the first word reference of that
  // message, return the length in bytes of that message
  uint16_t length = 0;
  uint8_t code = 0;
  do {
    code = ((*(*mptr)++ & 0x3f) - 1) & 0x3f;
    // if bits 0:5 are 0, will wrap round to 0xff
    // if this happens, another byte is used to extend the length
    length += code;
  } while (code == 0x3f);
  return length;
}

//       ---

void displaywordref(uint16_t wordref) {
  // display word reference wordnum
  uint16_t dictblock = 0;
  uint16_t relwordnum = 0xffff; // no relative word number
  uint16_t code = 0;
  char *cptr = NULL;

  wordcase = false; // reset flag
  // strip top bit, just leaving wordtype
  uint8_t wordtype = (wordref >> 12) & 0x07;
  wordref &= 0x0fff; // remove wordtype

  if (wordref >= 0x0f80) {
    // single ascii character specified
    if (wordtype & 0x02)
      printchar(' ');
    mdtmode = 2;
    // was 0xf80+ascii code, so strip off top bit
    wordref &= 0x7f;
    if (wordref != flushcode)
      printchar(wordref);
    if (wordtype & 0x01)
      printchar(' ');
    return;
  } else {
    // wordref=reference to real word
    if (mdtmode == 1)
      printchar(' ');
    else mdtmode = 1;
  }

  // display word number wordref
  // setindex
  uint8_t *itable =  startfile +
                     startfile[10] +
                    (startfile[11] << 8);
  uint16_t nsegs  =  startfile[12] +
                    (startfile[13] << 8);
  uint8_t *index = itable;

  // wordref is word number to display
  // index is address of current index entry
  // nsegs is number of index segments left
  while (nsegs) { // run out of segments ?
    code = index[2] + (index[3] << 8);
    // gone past word number to display ?
    if (code > wordref) break;
    // not gone past yet, so try another
    index += 4;
    nsegs--;
  }

  // have just gone past word reference pointer,
  // if we are still on the first table entry, then
  // the word reference was to segment -1
  // (should be zero except for a bug or whatever in the squasher)
  if (index == itable) {
    // so we ARE still on the first entry.
    // the real data on this segment is set up as follows:
    // first word of segment is number 0, so wordref is alread relative
    // to segment start. Copy it into relwordnum for future use
    relwordnum = wordref;
    // address of segment is the address of the dictionary itself
    dictblock = startfile[6] + (startfile[7] << 8);
  } else {
    // not segment -1,
    // so step back one entry to get pointer to the segment
    // containing the word we want
    index -= 4;
    dictblock = index[0] + (index[1] << 8);
    // get word reference at start of this block in relwordnum
    relwordnum = wordref - (index[2] + (index[3] << 8));
  }

  // relwordnum is now the number of the word within this segment
  // and dictblock the address within the dictionary of the packed form
  // need to increment relwordnum before starting due to layout of loop
  relwordnum++;
  initdict(dictblock);
  do {
    code = getdictionarycode();
    if (code >= header) { // header
      code &= 0x03; // get number of characters same as previous word
      cptr = threecharacters + code;
      // cptr now points to point of word to which to start expanding
      relwordnum--;
      // if not reached word we want, go for more data
    } else { // not a header
      if (code >= longc)
        *cptr++ = getlongcode(code);
      else // normal alpha
        *cptr++ = 'a' + code;
    }
  } while (relwordnum);
  cptr = threecharacters;
  // code is now no. of characters same count

  // have got the start of a word in the threecharacters buffer
  // print this out (code characters are the same as previous word)
  while (code) {
    // fetch character from threecharacters buffer
    printautocase(*cptr++, wordtype);
    code--; // decrement no. of characters to print here
  }

  // have printed characters same as previous word
  // now print out any subsequent characters
  // stored for this word
  while ((code = getdictionarycode()) < endseg) {
    printautocase(getdictionary(code), wordtype);
  }
}

//       ---

char getdictionary(uint8_t code) {
  // code is the current short code
  // returns the next unpacked ascii code
  if (code >= longc) return getlongcode(code);
  else return 'a' + code; // normal alpha
}

char getlongcode(uint8_t code) {
  // long escape short code (?)
  code = getdictionarycode();
  if (code == uppercasemark) {
    // upper-case-only marker
    wordcase = true;
    code = getdictionarycode();
    return getdictionary(code);
  } else {
    code = (code << 5) & 0xe0;
    code |= getdictionarycode() & 0x1f;
    code |= 0x80; // flag character as a long code
    return code;
  }
}

//       ---

uint8_t getdictionarycode() {
  // unpack and return byte from word dictionary
  if (unpackoffset == 8) {
    unpackoffset = 0;

    uint8_t p0 = *packedptr++; // aaaaabbb
    // put aaaaa into unpack buffer
    unpackbuffer[0] = p0 >> 3;

    uint8_t p1 = *packedptr++; // bbcccccd
    // put bbbbb into unpack buffer
    unpackbuffer[1] = ((p0 << 2) | (p1 >> 6)) & 0x1f;
    // put ccccc into unpack buffer
    unpackbuffer[2] = (p1 >> 1) & 0x1f;

    uint8_t p2 = *packedptr++; // ddddeeee
    // put ddddd into unpack buffer
    unpackbuffer[3] = ((p1 << 4) | (p2 >> 4)) & 0x1f;

    uint8_t p3 = *packedptr++; // efffffgg
    // put eeeee into unpack buffer
    unpackbuffer[4] = ((p2 << 1) | (p3 >> 7)) & 0x1f;
    // put fffff into unpack buffer
    unpackbuffer[5] = (p3 >> 2) & 0x1f;

    uint8_t p4 = *packedptr++; // ggghhhhh
    // put ggggg into unpack buffer
    unpackbuffer[6] = ((p3 << 3) | (p4 >> 5)) & 0x1f;
    // put hhhhh into unpack buffer
    unpackbuffer[7] = p4 & 0x1f;
  }

  return unpackbuffer[unpackoffset++];
}

void printautocase(char c, uint8_t wordtype) {
  absprintautocase(c, wordtype);
}

void absprintautocase(char c, uint8_t wordtype) {
  if (!(c & 0x80)) { // not long code
    if (wordcase)
      c = toupper(c);
    if (wordtype >= 6) {
      // wordtype=proper noun or upper case marked in text
      wordcase = false;
      c = toupper(c);
    }
  }
  printchar(c);
}

void printchar(char c) {
  printchar1(c);
}

void printchar1(char c) {
  if (c & 0x80) { // long code ?
    c &= 0x7f;
    lastchar = c;
  } else {
    // transparent characters: cr space ' <9c> 0x % & ' ( )
    if ( c != flushcode &&
         c != ' ' && c != cr &&
        (c <=  '!' || c > ')')) {
      // sentence terminators: ! ? .
      if (lastchar == '!' ||
          lastchar == '?' ||
          lastchar == '.')
        c = toupper(c);
      c &= 0x7f;
      lastchar = c;
    }
  }

  if (c == ' ') {
    flush();
    pendspace = 0xff;
  } else {
    if (c == cr) {
      flush();
      wrapoutput(cr);
    } else if (wrapbufferpointer != wrapbufferend) // >>mike 10/1/88
      *wrapbufferpointer++ = c;
  }
}

//       ---

void wrapreset() {
  mdtmode = 0;
  nchars = 0;
  lastchar = '.';
  width = screenwidth - 1;
  wrapbufferpointer = wrapbuffer;
  pendspace = 0;
}

//       ---

void flush() {
  if (pendspace) {
    if (wrapbufferpointer - wrapbuffer + nchars < width)
      wrapoutput(' ');
    else
      wrapoutput(cr);
  }

  char *bufptr = wrapbuffer;
  while (bufptr < wrapbufferpointer)
    wrapoutput(*bufptr++);
  wrapbufferpointer = wrapbuffer;
  pendspace = 0;
  fflush(stdout);
}

//       ---

void wrapoutput(char c) {
  if (c == cr) {
    if (nchars) {
      absprintchar(lf);
      nchars = 0;
    }
  } else {
    absprintchar(c);
    nchars++;
  }
}

//       ---

void absprintchar(char c) {
  if (inputnoecho && !resetmenu && output_terminal())
    clearmenu();
  *intdriverbuffer = c;
  driver(oswrchdcode, intdriverbuffer);
  resetmenu = true;
}

void initdict(uint16_t dictblock) {
  // get absolute address of packed word in packedptr
  // given dictblock = address of word relative to start of file
  packedptr = startfile + dictblock;
  unpackoffset = 8;
}

//       ----

void intstart() {
  endint = malloc(compramsize);
  endmemory = endint + compramsize;
  startfile = endint;
  if (autorun || demo) autoruninit(logfilename);
  intinitialise();
  intstart2();
}

// For embedded compilation, define EMBEDINT
#ifndef EMBEDINT
uint8_t *startfile = NULL;
bool splitdata = false;
bool i8086 = false;
void usage(char *progname) {
  printf("Usage: %s [options]\n\n", progname);
  printf("Options:\n");
  printf("--help: print this usage message\n");
  printf("--autorun: run log.bat\n");
  printf("--demo: run log.bat in a loop\n");
  printf("--debug: start in debug step mode\n");
  printf("--splitdata: use split acode and gamedata\n");
  printf("  <gamedatafilename>: alternative name for 'gamedat1.dat'\n");
  printf("Only with --splitdata:\n");
  printf("  <acodefilename>: alternative name for 'acod1.dat'\n");
  printf("Only with --autorun:\n");
  printf("  <logfilename>: alternative name for 'log.bat'\n");
  printf("\n");
  exit(0);
}
int main(int argc, char **argv) {
  int arg = 0;
  while (++arg < argc) {
    if (strcmp(argv[arg], "--help") == 0) usage(argv[0]);
    if (strcmp(argv[arg], "--debug") == 0) { debug = true; continue; };
    if (strcmp(argv[arg], "--autorun") == 0) { autorun = true; continue; };
    if (strcmp(argv[arg], "--demo") == 0) { demo = true; continue; };
    if (strcmp(argv[arg], "--splitdata") == 0) { splitdata = true; continue; };
    if (strncmp(argv[arg], "--", 2) != 0) {
      if (!gamedatafilename) {
        gamedatafilename = argv[arg];
        continue;
      } else if (splitdata && !acodefilename) {
        acodefilename = argv[arg];
        continue;
      } else if (autorun && !logfilename) {
        logfilename = argv[arg];
        continue;
      }
    }
    printf("Unrecognized argument: '%s'\n\n", argv[arg]);
    usage(argv[0]);
  }
  intstart();
  return 0;
}
#endif
