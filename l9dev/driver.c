// Atari ST driver (minimal parts adapted for Linux)
// Copyright (C) 1986-1988 Level 9 Computing
// M.J.Austin 20/7/86
// first presentable Linux version 21/12/25

// note - if 'graphics' is defined elsewhere (as anything),
// the appropriate code will be defined in here.
// To make this driver public domain, simply
// remove all the code assembled within the 'ifd' instruction

// Some programs need to know which machine they are running
// on (e.g. to allow for different assemblers)
// this is catered for by the following constants
// THIS FACILITY SHOULD BE USED AS LITTLE AS POSSIBLE

#include <stdarg.h> // for va_ macros

#include "driver.h"

void *endmemory = NULL;
char *driverbuffer = NULL;
uint16_t numwaits = 0;
uint16_t randomseed = 0;
uint16_t setrandomseed = 0;
char lenslok[2] = { 0, };
uint8_t lensindex = 0;
char lastline[81];
uint8_t llindex = 0;
bool inputnoecho = false;
bool autorun = false;
bool demo = false;
bool executingcommandfile = false;
bool nextpart = false;
char *batchptr = NULL;

// fcb for reading autorun log files
struct _fcb logdriverblock = {
  NULL,
  NULL,
  "log.bat"
};

//--------------------//
// the Program Itself //
//--------------------//

//---
// these are for logging printer output
int OutputDevice = 2; // 2 = CON: 1 = AUX:
FILE *logfile = NULL;
void openlogfile(char *filename) {
  logfile = fopen(filename, "a");
}
void closelogfile() {
  if (logfile) fclose(logfile);
  logfile = NULL;
}
void prs(char const *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);
    vprintf(fmt, ap);
    va_end(ap);
    if (OutputDevice == 1 && logfile) {
      va_start(ap, fmt);
      vfprintf(logfile, fmt, ap);
      va_end(ap);
    }
}
char waitkey() {
  char c = 0;
  while (!(c = osrdch()));
  return c;
}
//---

void driver(int code, void *buffer) {
  // Standard entry point for all external routines
  switch (code) {
    case initdcode:
      init(); break;
    case checksumdcode:
      calcchecksum(buffer); break;
    case oswrchdcode:
      driveroswrch(buffer); break;
    case osrdchdcode:
      driverosrdch(buffer); break;
    case savedcode:
      driversavefile(buffer); break;
    case loaddcode:
      driverloadfile(buffer); break;
    case settextdcode:
      settext(); break;

    case taskinitdcode:
      resetginttask(); break;
    case inputlinedcode:
      driverinputline(buffer); break;
    case returntoosdcode:
      closedown(); break;
    case randomnumberdcode:
      randomnumber(buffer); break;

    case getclockdcode:
      getclock(buffer); break;

    case ramsavedcode:
      ramsave(buffer); break;
    case ramloaddcode:
      ramload(buffer); break;

    case lenslokdisplaydcode:
      lenslokdisplay(buffer); break;

    case displayhirescode:
      displayhiresvector(buffer); break;
    case testhirescode:
      testhiresvector(buffer); break;
  }
}

void displayhiresvector(void *buffer) { // XXX
  // displayhires(buffer);
}

void testhiresvector(void *buffer) { // XXX
  *(uint16_t *)buffer = 0; // no picture displayed
  // testhires(buffer);
}

//---
void getclock(void *buffer) {
  // return real time clock in list9(hi4,hi3,lo2,lo)
  // approx 1/50 second per unit
  *(uint32_t *)buffer = 0;
}
//---
void randomnumber(void *buffer) {
  // return a random word
  *(uint16_t *)buffer = (uint16_t)rand();
}
//---
void lenslokdisplay(char *buffer) {
  // On the screen !!!!
  prs("\nThe code is: [%c%c]\n",
      buffer[0],  // left hand character
      buffer[1]); // right hand character
  // remember lenslok code for autorun input
  lenslok[0] = buffer[0];
  lenslok[1] = buffer[1];
}
//---
void ramsave(void **buffer) {
  if (initram(buffer)) {
    // copy workspace to ram
    memcpy(buffer[2], buffer[0], buffer[1] - buffer[0]);
    *(uint8_t *)buffer = 0x00;
  }
}
//---
void ramload(void **buffer) {
  if (initram(buffer)) {
    // copy ram to workspace
    memcpy(buffer[0], buffer[2], buffer[1] - buffer[0]);
    *(uint8_t *)buffer = 0x00;
  }
}
//---
bool initram(void **buffer) {
  // see if enough space in save memory
  if (buffer[2] + (buffer[1] - buffer[0]) > endmemory - autorunsize) {
    *(uint8_t *)buffer = 0xff;
    return false;
  } else return true;
}
//---
void closedown() {
  // exit gracefully
  prs("\nDo you really want to leave the game? ");
  char c;
  do {
    c = toupper(osrdch());
  } while (c != 'Y' && c != 'N');
  if (c == 'Y') {
// ifd graphics
    killmultitasking();
    driver(settextdcode, NULL);
// endc // if graphics
    returntogem();
  }
}
//---
// ifd graphics
void killmultitasking() {
}
int getscreenaddress() {
// return address of screen start in a0.l and d0.l
// call_ebios _physbase
// addq.l 2,sp
// move.l d0,a0
  return 0;
}
void resetginttask() {
// lea gintstacktop(pc),a0

// lea gintstart(pc),a1
// move.l a1,-(a0)
// move.w sr,-(a0)
// lea irqswaptaskend(pc),a1
// move.l a1,-(a0) // return address from ist1

// movem.l d0-d7/a0-a6,-(a0) // dummy stack values
// lea taskstackptr,a1
// move.l a0,(a1)
// rts
}
void init1() {
  // cursorxpos = 0;
  // cursorypos = 24; // bottom left is 0,24 here

  // cyclicwriteptr = cyclicib;
  // cyclicbufferstart = cyclicib;
  // cyclicbufferend = cyclicibtop;
  // cycliccharsused = 0;
}
//---
bool init2() {
  // screenpointer = getscreenaddress();
  // now before doing anything, clear out the screen
  for (int i = 0; i < 25; i++) prs("\n"); // clear screen
  // scrolledlines = 0;
  // and what screen resolution are we in ?
// call_ebios _getrez * move.w #4,-(sp)
// addq.l #2,sp
  // d0.b = 0 - low resolution, 1 = medium resolution, 2 = high res
  // screenresolution = 1;
  // if (screenresolution == 2) {
  //   screenheight = absscreenheight;
  // } else {
  //   screenresolution = 0; // always low res for graphics nowadays
  // }
  // return screenresolution == 2; // hi-res ?
  return false;
}
//---
void init() {
  // .initialise
  // first, some general purpose initialisation ---

  init1();
// ifd graphics
  // initialisetasks();
  // seterrorvectors(); // address error and bus error etc.
// endc // graphics

   bool ishires = init2();
// ifd graphics
  if (!ishires); // initsplitscreen(); // no, so set up med-low res split screen
// endc

  // screenheight = absscreenheight * 2; // hi-res height
}
void calcchecksum(struct _fcb *area) {
  // calculate checksum of area between area->start and area->end
  int length = area->end - area->start + 1;
  uint8_t checksum = 0;
  uint8_t *checkptr = (uint8_t *)area->start;
  while (length-- > 0) checksum += *checkptr++;
  *(uint8_t *)area = checksum;
}

void autoruninit(char *logfilename) {
  // get instructions from disk file
  if (logfilename) {
    *logdriverblock.filename = 0x80;
    *(char **)(logdriverblock.filename + 1) = logfilename;
  } else
    logfilename = logdriverblock.filename;
  // is there a command file in this directory on the disk?
  prs("\nLooking for gameplay log on disk - '%s'\n", logfilename);
  // current batch pointer
  batchptr = endmemory - autorunsize;
  logdriverblock.start = batchptr;
  driver(loaddcode, &logdriverblock);
  if (!*(uint8_t *)&logdriverblock) {
    prs("\nExecuting instructions in file '%s'\n", logfilename);
    // end of batch file
    int r = logdriverblock.end - (void *)batchptr;
    if (r < 0) r = 0;
    batchptr[r++] = cr;
    batchptr[r++] = lf;
    batchptr[r++] = eof;
    batchptr[r++] = eof;
    batchptr[r++] = 0;
    executingcommandfile = true;
 } // not loaded, so ignore command to start fetching
}

void ardelay() {
  // do a two-second delay, then continue
  if (demo) usleep(2000000);
}

void arcommand(char *buffer) {
  if (strncasecmp(buffer, "seed ", 5) == 0) {
    randomseed = atoi(buffer + 5);
    setrandomseed = randomseed; // save for chaining
    prs("Seed set to %d\n", randomseed);
  } else if (strncasecmp(buffer, "quit", 4) == 0)
    returntogem();
  else if (strncasecmp(buffer, "next", 4) == 0)
    nextpart = true;
  else if (strncasecmp(buffer, "wait", 4) == 0) {
    numwaits = atoi(buffer + 5) - 1;
  }
}

void autorunagain() {
  // reset batch pointer
  batchptr = endmemory - autorunsize;
}

void autoruninputline(char *buffer) {
  // copy string into buffer
  bool skip = false;
  bool store = true;
  char *command = NULL;
  char c = 0;
  if (numwaits) numwaits--;
  else
    while (c = *batchptr++,
           c != lf && c != cr && c != eof) {
      if (c == '[' || c == ';')
        skip = true;
      else if (c == '#') {
        command = batchptr;
        store = false;
      }
      if (!skip) {
        if (c == '*') ardelay();
        else {
          if (store) *buffer++ = c;
          if (!inputnoecho) prs("%c", c);
        }
      }
    }

  // end of string, add terminator
  *buffer = 0;
  // lf at end of input
  if (!inputnoecho) prs("\n");
  llindex = 0;

  // execute command if one was found
  if (command) arcommand(command);

  // skip a series of terminators
  if (c != eof)
    while (c = *batchptr,
           c == lf || c == cr) batchptr++;
  if (c == eof) {
    if (autorun) executingcommandfile = false;
    else autorunagain(); // demo
  }
}

void autorunosrdch(char *buffer) {
  if (strcasestr(lastline, "space"))
    *buffer = ' ';
  else if (strcasestr(lastline, "code")) {
    *buffer = lenslok[lensindex];
    lensindex ^= 1;
  } else if (inputnoecho || strncmp(lastline, "3) ", 3) == 0) {
    // multiple choice adventures
    // must interleave with zeroes
    // to indicate buffer empty
    if (inputnoecho) {
      if (lensindex > 20) {
        autoruninputline(buffer);
        lensindex = 0;
      } else *buffer = 0;
      lensindex += 1;
    } else {
      if (lensindex)
        autoruninputline(buffer);
      else *buffer = 0;
      lensindex ^= 1;
    }
  } else *buffer = 0;
}

//---
char *getfilename(struct _fcb *fcb) {
  char *f = fcb->filename;
  if (!*f) { // ask for it
    prs("\nFilename ? ");
    if (!driverbuffer) // max path length
      driverbuffer = malloc(4096);
    f = driverbuffer;
    *fcb->filename = 0x80;
    *(char **)(fcb->filename + 1) = f;
    scanf("%s", f);
  } else if (*f & 0x80) // pointer
    f = *(char **)(f + 1);
  return f;
}

void driverloadfile(struct _fcb *fcb) {
  char *filename = getfilename(fcb);
  FILE *fp = fopen(filename, "r");
  if (fp) {
    int r = fread(fcb->start, 1, 0x30000, fp);
    fclose(fp);
    fcb->end = fcb->start + r;
    *(char *)fcb = 0; // signify load ok
  } else {
    prs("Can't find file on disk.\n");
    *(char *)fcb = 1; // signify load error
  }
}

void driversavefile(struct _fcb *fcb) {
  char *filename = getfilename(fcb);
  FILE *fp = fopen(filename, "w");
  if (fp) {
    int size = fcb->end - fcb->start;
    int written = fwrite(fcb->start, 1, fcb->end - fcb->start, fp);
    fclose(fp);
    if (written == size) {
      *(char *)fcb = 0; // signify save ok
    } else fp = NULL;
  }
  if (!fp) {
    prs("Save error.\n");
    *(char *)fcb = 1; // signify save error
  }
}
void hexlonga0(uint32_t n) {
  prs("%08X", n);
}
void hexworda0(uint16_t n) {
  prs("%04X", n);
}
void hexbyted0(uint8_t n) {
  prs("%02X", n & 0xff);
}
void printhexdigit(uint8_t n) {
  prs("%01X", n & 0xf);
}
void printdecimald0(int n) {
  // print n as a decimal number,
  // suppressing leading zeros
  prs("%d", n);
}
int readdecimal(char **s) {
  // given a decimal number as an ascii string at *s, return
  // its value
  // and *s = character after the number
  return strtol(*s, s, 10);
}
//---
bool isd0alphanumeric(char c) {
  c = toupper(c);
  return ((c >= '0' && c <= '9') || (c >= 'A' && c <= 'Z'));
}
//--- 
#ifdef __linux__
#include <unistd.h>
#include <signal.h>
#include <termios.h>
#include <fcntl.h>
struct termios saved_attributes;
int fcntl_flags;
#endif
void handle_signal(int sig) {
#ifdef __linux__
  exit(128 + sig);
#endif
}
bool output_terminal() {
#ifdef __linux__
  return isatty(STDOUT_FILENO);
#else
  return false;
#endif
}
bool input_terminal() {
#ifdef __linux__
  return isatty(STDIN_FILENO);
#else
  return false;
#endif
}
void reset_terminal(int stat, void *arg) {
#ifdef __linux__
  if (!input_terminal()) return;
  if (output_terminal())
    prs("\033[J\033[?25h"); // Erase below and enable cursor
  if (stat) prs("\n");
  tcsetattr(STDIN_FILENO, TCSANOW, &saved_attributes);
#endif
}
void reset_input_mode() {
#ifdef __linux__
  if (!input_terminal()) return;
  tcsetattr(STDIN_FILENO, TCSANOW, &saved_attributes);
#endif
}
void set_input_mode(bool flush) {
#ifdef __linux__
  struct termios tattr;
  if (!input_terminal()) return;

  static bool saved = false;
  if (!saved) {
    tcgetattr(STDIN_FILENO, &saved_attributes);
    saved = true;
    on_exit(reset_terminal, NULL);
    signal(SIGINT, handle_signal);
    signal(SIGTERM, handle_signal);
    signal(SIGQUIT, handle_signal);
  }

  tcgetattr(STDIN_FILENO, &tattr);
  tattr.c_lflag &= ~(ICANON|ECHO);
  tattr.c_cc[VMIN] = 1;
  tattr.c_cc[VTIME] = 0;
  tcsetattr(STDIN_FILENO, flush ? TCSAFLUSH : TCSANOW, &tattr);
#endif
}
void set_non_blocking() {
#ifdef __linux__
  fcntl_flags = fcntl(STDIN_FILENO, F_GETFL);
  fcntl(STDIN_FILENO, F_SETFL, fcntl_flags | O_NONBLOCK);
#endif
}
void reset_non_blocking() {
#ifdef __linux__
  fcntl(STDIN_FILENO, F_SETFL, fcntl_flags);
#endif
}
char osrdch() {
  set_input_mode(true);
  char c = getchar();
  reset_input_mode();
  if (c == EOF) c = 0;
  return c;
}
void driveroswrch(char *c) {
  oswrch(*c);
  if (executingcommandfile) {
    if (llindex < sizeof(lastline) - 1) {
      lastline[llindex++] = *c;
      lastline[llindex] = 0;
    }
    if (*c == lf)
      llindex = 0;
  }
}
void oswrch(char c) {
  if (c >= ' ' || c == lf)
    prs("%c", c);
}
void inputline(char *buffer) {
  char *bufptr = buffer;
  char c = 0;
  while (c = getchar(),
         c != EOF && c != lf)
    *bufptr++ = c;
  *bufptr = 0;
  if (c == EOF) returntogem();
}
void driverinputline(char *buffer) {
  if (executingcommandfile)
    autoruninputline(buffer);
  else
    inputline(buffer);
}
void absosrdch(char *buffer) {
  set_non_blocking();
  set_input_mode(false);
  usleep(20000); // delay 1/50 sec
  char c = getchar();
  if (!inputnoecho) reset_input_mode();
  reset_non_blocking();
  if (c == EOF) c = 0;
  *buffer = c;
}
void driverosrdch(char *buffer) {
  if (executingcommandfile)
    autorunosrdch(buffer);
  else
    absosrdch(buffer);
}
void returntogem() {
// ifd graphics
  killmultitasking();
  driver(settextdcode, NULL);
// endc // if graphics
  prs("\n");
// call_bdos p_term
  exit(0);

//----------

// ifnd graphics // only assembled if graphics has not been defined
//  settext
//  setgraphics
//  driverclg
//  driverchgcol
//  line
//  fill
//  gintstart
//  killmultitasking
//  rts
// endc
}

//---

// ifd graphics // only assembled if graphics has been defined


void settext() {
  // clear top half of screen
// move.l screenpointer(pc),a0
// move.w #$3bfe,d0 * length to clear
// ...

  // and kill the split screen, restore full screen scrolling etc.
  // drivergraphicsmode = 0;
}
