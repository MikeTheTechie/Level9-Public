// finish program
//
// M.J.Austin started 5/8/86
// last change: 3/11/86
//
// started Linux version on Monday 8/12/25
// first presentable version: 21/12/25
//
// Copyright (C) 1986-1988 Level 9 Computing

#include "finish.h"

// for menu program to build up a list
// of possible games, from which the user chooses one
// this data is overwritten when the game is loaded

char *ptr = NULL; // pointer to current pos in file
char *finishedptr = NULL;
void *endfinish = NULL;
char directorypathname[100]; // will contain the complete path name for use by climb
char subdirname[100];
char directoryname[] = "*.l9";
//---
char finishdriverbuffer[40];
struct _fcb loadexitsdriverblock = {
  NULL,
  NULL,
  "exit.txt"
};
struct _fcb loadtablesdriverblock = {
  NULL,
  NULL,
  "table.dat"
};
struct _fcb loadsquashdriverblock = {
  NULL,
  NULL,
  "squash.dat"
};
struct _fcb loadacodedriverblock = {
  NULL,
  NULL,
  "acode.acd"
};
struct _fcb savecompletedriverblock = {
  NULL,
  NULL,
  "gamedata.dat"
};
//---
// and now some workspace
void *startsources = NULL; // where the exits, tables etc. are loaded
char *startcomplete = NULL; // start of complete.dat block in memory
int linenumber = 0;
int squashlength = 0;
//
char terminator = 0;
//---
void finishstart() {
  prs("%s", finish_version);

  // this program always produces a complete.dat
  // file from the data on the disk

  // once-only init
  endfinish = malloc(compramsize);
  finishedptr = endfinish;
  startsources = finishedptr;
  finishedptr += 0x30008; // allow space for files to be loaded
  startcomplete = finishedptr; // pointer to start of complete.dat block in memory
  finishedptr += sizeofpointers;

  processexits();

  processtables();

  if (!splitdata) savedirectory(); // with split data no subdirs are used (1.5)
  if (!splitdata) selectdirectory(); // subdirectory for computer-specific text
  processsquash();
  if (!splitdata) climb(); // and back to root for acode

  processacode();

  finishchecksum();

  if (!splitdata) descend(); // with split data no subdirs are used (1.5)
  prs("Saving gamedata.dat\n");

  savecompletedriverblock.start = startcomplete; // start address to save
  savecompletedriverblock.end = finishedptr; // end address to save
  driver(savedcode, &savecompletedriverblock);

  if (!splitdata) climb(); // leave us back where we started

  returntogem();
}
//---
void softinit() {
  // init for each stage of development
  linenumber = 1;
}
//---
void finisheven() {
  // make ptr even and zero out skip byte
  if ((ptr - startcomplete) & 1) *ptr++ = 0;
}
//---
void processexits() {
  softinit();
  prs("Loading exit.txt\n");

  char c = eof;
  int flags = 0;
  int direction = 0;
  int room = 0;

  char *exitptr = startcomplete + exitptroffset;
  int offset = finishedptr - startcomplete;
  *exitptr = offset & 0xff; // poke in rel. ptr to exits
  *(exitptr + 1) = offset >> 8;

  loadexitsdriverblock.start = startsources; // start address
  driver(loaddcode, &loadexitsdriverblock);
  char *buf = (char *)loadexitsdriverblock.end;
  if (!buf) buf = startsources;
  buf[0] = eof;
  buf[1] = lf;
  buf[2] = eof;

  ptr = startsources;
  while (c = *ptr++, c != cr && c != lf);
  buf[1] = terminator = c;
  ptr = startsources; // start of exit data

  do {
    if (supersearch() == eof) {
      // terminate exit table on eof (without explicit end of data marker)
      *finishedptr++ = 0;
      *finishedptr++ = 0;
      break;
    }

    // first get four binary digits
    flags = getbin() << 3 | getbin() << 2 | getbin() << 1 | getbin();

    // now get direction
    direction = getdec();
    *finishedptr++ = direction | flags << 4;

    // finally get destination room
    room = getdec();
    *finishedptr++ = room;
  } while (flags | direction | room); // 0000 0 0 ? (=end of data)
}
//---
int getdec() {
  // return a decimal number
  char c = search();
  if (c < '0' || c > '9') errorindata();
  return readdecimal(&ptr);
}
int getbin() {
  // return a binary digit
  char c = search();
  if (c != '0' && c != '1') errorindata();
  ptr++;
  return c - '0';
}
//---
void processtables() {
  prs("Loading table.dat\n");
  ptr = startsources;
  loadtablesdriverblock.start = ptr;
  driver(loaddcode, &loadtablesdriverblock);
  if (*(char *)&loadtablesdriverblock) return;

  // set up pointers at start of complete.dat file
  // at the start of the table.dat file are pointers (longs)
  // to the tables. There are numtable of these
  // and then a pointer to the end of the table file
  // copy the table pointers
  ptr += 0x1c; // skip reloc information
  int ntables = 9 + 1; // number of tables
  int tableptr = 0;

  // get start of tables relative to complete.dat
  int starttables = finishedptr - startcomplete;
  // ptr is start of table data (assembled by any assembler)
  char *destptr = startcomplete + list1ptroffset;
  destptr[-1] = 0; // zero out unused field
  destptr[-2] = 0; // aka list0

  do {
    ptr += 2; // skip high word
    tableptr  = *(uint8_t *)ptr++ << 8;
    tableptr |= *(uint8_t *)ptr++;
    // tableptr is a table pointer
    // is it a workspace reference ? (0x8000-0x9000)
    if (tableptr < 0x8000 || tableptr >= 0x9000) {
      // so convert it to make it point to the table data
      // relative to the start of complete.dat
      tableptr += starttables - (9 * 4 + 4); // 9 table pointers = 40
    } // between 8000 and 9000, so don't adjust
    *destptr++ = tableptr & 0xff;
    *destptr++ = tableptr >> 8;
  } while (--ntables > 0); // number of tables to process

  // and copy data in to finished data area
  int len = tableptr - starttables;
  memcpy(startcomplete + starttables, ptr, len);
  ptr += len;
  finishedptr = startcomplete + tableptr;
}
//---
void processsquash() {
  // load in squash.dat at finishedptr
  // and adjust all pointers
  prs("Loading squash.dat\n");

  // make finishedptr even and zero out skip byte
  if ((finishedptr - startcomplete) & 1) *finishedptr++ = 0;
  int offset = 0;
  int val = 0;

  loadsquashdriverblock.start = finishedptr;
  driver(loaddcode, &loadsquashdriverblock);
  if (*(char *)&loadsquashdriverblock) return;

  ptr = finishedptr;
  char *oldptr = ptr;
  finishedptr = startcomplete;

  // offset to add to all squash pointers
  offset = ptr - startcomplete;
  val = z80load(); // length
  squashlength = val;
  z80write(val + offset); // startcomplete+0

  val = z80load(); // message destriptor pointer
  z80write(val + offset);

  val = z80load(); // length of descriptors
  z80write(val);

  val = z80load(); // word dictionary pointer
  z80write(val + offset);

  val = z80load(); // word dictionary length
  z80write(val);

  val = z80load(); // word dictionary index table
  int dict = val + offset; // preserve value
  z80write(dict);

  val = z80load(); // number of segments
  int segments = val; // preserve value
  z80write(segments);

  val = z80load(); // common word dictionary
  z80write(val + offset);

  z80load(); // version number - ignore
  z80write(0); // zero out unused bytes explicitely

  z80load(); // not used - ignore

  // and adjust word dictionary pointers
  // to make them relative to (startcomplete)
  // offset   is offset to add to pointer
  // dict     is offset of word dictionary pointer
  // segments is number of segments

  // fist find end of index table
  // clear high bits of dict
  dict &= 0xffff;

  uint8_t *start = (uint8_t *)startcomplete + dict;
  uint8_t *end = start + 4 * segments;
  uint8_t *scan = start;
  // start is start of table. end is end of table
  // let scan be the offset used to scan the table
  // offset is offset to add to pointers
  while (scan < end) {
    // calc address of index entry in val
    val = scan[0] | scan[1] << 8;
    val += offset;
    scan[0] = val & 0xff;
    scan[1] = val >> 8;
    scan += 4;
  }
  ptr = oldptr + squashlength;
  finishedptr = ptr;
}
//---
int z80load() {
  int val = 0;
  val  = *(uint8_t *)ptr++;
  val |= *(uint8_t *)ptr++ << 8;
  return val;
}
//---
void z80write(int val) {
  *finishedptr++ = val & 0xff;
  *finishedptr++ = val >> 8;
}
//---
void processacode() {
  // load acode.acd at finishedptr
  // and adjust all pointers
  prs("Loading acode.acd\n");

  ptr = finishedptr;
  if (!oddacode) finisheven(); // make ptr even

  loadacodedriverblock.start = ptr;
  driver(loaddcode, &loadacodedriverblock);
  processacodeptr();
}

void processacodeptr() {
  finishedptr = ptr;
  // get length of acode
  int acodelen = z80load();

  // ptr = start of acode
  // acodelen = length of acode
  char *endcomplete = ptr + acodelen; // end of complete.dat file in memory
  endcomplete++; // allow an extra byte for the checksum
  finishedptr = endcomplete;

  int sizecomplete = endcomplete - startcomplete; // size of complete.dat file
  sizecomplete--; // and another byte less for good measure
  startcomplete[0] = sizecomplete & 0xff;
  startcomplete[1] = sizecomplete >> 8;

  int acodeoffset = ptr - startcomplete;
  startcomplete[40] = acodeoffset & 0xff;
  startcomplete[41] = acodeoffset >> 8;

  // zero out unused bytes explicitly
  startcomplete[42] = 0;
  startcomplete[43] = 0;
  // finishedptr is end of complete.dat file in memory
}
//---
void finishchecksum() {
  struct _fcb *fcb = (struct _fcb *)&finishdriverbuffer;
  fcb->start = startcomplete; // start of block to checksum
  fcb->end = finishedptr - 1; // disregard checksum byte at present
  driver(checksumdcode, fcb);

  // address checksum done up to
  // poke in checksum byte
  *(uint8_t *)fcb->end = -*(uint8_t *)fcb;
}
//---
void errorindata() {
  prs("error in data at line ");
  printdecimald0(linenumber);
  prs(" \nPress a key to return to Gem\n");
  waitkey();
  returntogem();
}
//---
void ssskiptoeol() {
  skiptoeol();
  supersearch(); // on new line as well!
}
void skiptoeol() {
  if (*ptr == eof) return;
  while (*ptr++ != terminator);
  do {
    linenumber++;
    // skip control characters (including false eol)
    uint8_t c = eof;
    while (c = *ptr++, c < 32 && c != terminator && c != eof);
    ptr--;
  } while (*ptr++ == terminator);
  ptr--;
}
int search() {
  // search, skipping spaces
  while (*ptr == ' ') ptr++;
  return *ptr;
}
int supersearch() {
  // search, skipping over comments if present
  while (true) {
    uint8_t c = search();
    if (c == eof) break;
    if (c == '*' || c == ';' || c == terminator || c < 32) {
      skiptoeol();
    } else break;
  }
  return *ptr;
}
//---
//
// ++++++++++++++ Some ST specific code to scan
// 		 for possible sub-directories  +++++++++++++++++
// look in current directory for interesting sub-directories - 
// i.e. those which match with directoryname
void selectdirectory() {
  if (splitdata) return; // with split data no subdirs are used (1.5)
  int found = 0; // number of files found
  int current = 0;
  int selection = 0;
  glob_t globbuf;
  glob(directoryname, 0, NULL, &globbuf);
  found = globbuf.gl_pathc;
  while (current < found) {
    prs("                               ");
    prs("%c .. %s\n", current + 'A', globbuf.gl_pathv[current]);
    current++;
  }

  if (!found) {
    prs("No suitable files on disk\n");
    prs("Press a key to return to gem\n");
    waitkey();
    returntogem();
    return;
  } else if (found == 1) {
    prs("Only one sub-directory - proceeding with finish\n");
  } else {
    prs("Enter the letter corresponding to your choice .. ");
    char c;
    do {
      // now get a letter
      c = toupper(waitkey());
      prs("%c\n", c);
      selection = c - 'A';
    } while (selection < 0 || selection >= found);
  }
  strcpy(subdirname, globbuf.gl_pathv[selection]);
  globfree(&globbuf);
  chdir(subdirname);
}
//---
void descend() {
  // go back down to previously selected directory
  if (splitdata) return; // with split data no subdirs are used (1.5)
  chdir(subdirname);
}
//---
void savedirectory() {
  // save the current directory
  // to be restored by climb
  if (splitdata) return; // with split data no subdirs are used (1.5)
  // getcwd(directorypathname, sizeof(directorypathname));
  strcpy(directorypathname, ".."); // should be ok on modern systems
}
//---
void fileerror() {
  prs("Can't get current directory name\n");
  prs("Press a key to return to gem\n");
  waitkey();
  returntogem();
}
//---
void climb() {
  chdir(directorypathname);
}

// For embedded compilation, define EMBEDFINISH
#ifndef EMBEDFINISH
bool oddacode = false;
bool splitdata = false;
void usage(char *progname) {
  printf("Usage: %s [options]\n\n", progname);
  printf("Options:\n");
  printf("--help: print this usage message\n");
  printf("--oddacode: do not align acode in gamedata.dat\n");
  printf("--splitdata: generate split acode and gamedata\n");
  printf("\n");
  exit(0);
}
int main(int argc, char **argv) {
  int arg = 0;
  while (++arg < argc) {
    if (strcmp(argv[arg], "--help") == 0) usage(argv[0]);
    if (strcmp(argv[arg], "--oddacode") == 0) { oddacode = true; continue; }
    if (strcmp(argv[arg], "--splitdata") == 0) { splitdata = true; continue; };
    printf("Unrecognized argument: '%s'\n\n", argv[arg]);
    usage(argv[0]);
  }
  finishstart();
  return 0;
}
#endif
