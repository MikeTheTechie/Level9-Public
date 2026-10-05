// message.txt to squash.dat compressor (for Linux)
//
// Copyright (C) 1986-1988 Level 9 Computing
//
// Original version: 24/06/86
// Linux version started: 05/01/26
// First presentable Linux version: 20/01/26
//

#include "squash.h"

// stage 1 variables
void *starttablememory = NULL;
void *startfilebuffer = NULL;
char *readptr = NULL;
char *writeptr = NULL;
char *msgptr = NULL;
int linenum = 0;
int msgnum = 0;
int numcharacters = 0;
int nummessages = 0;
int lengthsmt = 0;
int inputlength = 0;
int modifycount = 0;
bool seencomment = false;
bool debug = false;
char terminator = lf;
char *startmsg = NULL;
char *endmsg = NULL;
int messagelength = 0;
char lastchar = 0;
char lastsigchar = 0;
void *startft = NULL;
void *endft = NULL;
int charactercounts[128] = { 0, };
int numwords = 0;
int Phase03ProgressCounter = 0;
bool noisy = false;
char buffer[200];
char *bufptr = NULL;
char *ftptr = NULL;
void *startcwt = NULL;
void *endcwt = NULL;
char *cwtptr = NULL;
int wordnumber = 0;
int frequencytimes = 0;
int commonmaxentries = 1;

// stage 2 variables
bool oldgame = false; // For Adrian Mole/Archers
void *startmdt = NULL;
void *currentmdt = NULL;
void *maxmdt = NULL;
int Phase06ProgressCounter = 0;
char *wordaddress = NULL;
char wordtype = 0;
char p6mode = 0;
char p6char = 0;
int nummsgheads = 0;
int numjumpheads = 0;
int numshortrefs = 0;
int numlongrefs = 0;
int numkeywords = 0;
int lengthicf = 0;
int indexmd = 0;
int lengthmd = 0;
int startconvertedmsg = 0;
char segmentaddresses[416] = { 0, }; // 26*4*4
char *lastpointer = NULL;
int segnum = 0;
int indexwd = 0;
int lengthwd = 0;
int indexwdi = 0;
int numsegs = 0;
int finalchecksum = 0;
uint8_t *readwritepointer = NULL;
char lastbyte;
char threecharacters[4] = { 0, };
bool wordcase = false;

// file control blocks
struct _fcb loadmessagedriverblock = {
  NULL,
  NULL,
  "message.txt"
};
struct _fcb savesquashdatdriverblock = {
  NULL,
  NULL,
  "squash.dat"
};

void squasherflush() {
  fflush(stdout);
}

// stage 1 code

//
// -----
//
// Phase 1 - Load message.txt
//
// Load message.txt at address starttablememory
// Copy the file up to the top of memory.
// startfilebuffer is the address of the start of this
//
// -----
//

void phase01() {
  squasherprs("Phase 1 - Clear memory\n");
  starttablememory = ram;
  startfilebuffer = ram + 0x60000;
}

//
// -----
//
// Phase 2 - Sort messages
//
// Phase 2 read the file message.txt serially and creates
// the 'Sorted Message Table' - A list of all messages in
// numeric order.
//
// Each 'Sorted Message' entry starts with a six-byte
// header giving the length of the header (2 bytes), the
// message number (2 bytes) and the message.txt line
// number (2 bytes) for error messages.
//
// Comments, '[' and ']' are discarded.
//
// -----
//

void phase02() {
  squasherprs("Phase 2 - Sort into message number order\n\n");
  squasherprs("Squashing. Please wait.\n\n");
  //
  // Initialise 'Sorted Message Table'
  //
  linenum = 1;
  // After auto-increment first message is number 1
  msgnum = 0;
  numcharacters = 0;
  lengthsmt = 0;
  inputlength = 0;
  modifycount = 0;
  seencomment = false;
  //
  // Open message.txt for reading
  //
  readptr = (char *)startfilebuffer;
  loadmessagedriverblock.start = startfilebuffer;
  driver(loaddcode, &loadmessagedriverblock);

  writeptr = loadmessagedriverblock.end;
  if (!writeptr) {
    squasherprs("Can't read message.txt");
    returntogem();
  }
  inputlength = writeptr - readptr;

  // first add eof to end of message.txt file
  *writeptr++ = eof;
  *writeptr++ = eof;
  *writeptr++ = eof;
  *writeptr++ = lf;
  *writeptr++ = eof;

  // then find out what the line terminator is
  writeptr = readptr;
  while (*writeptr != cr && *writeptr != lf) writeptr++;
  terminator = *writeptr;
  writeptr = readptr;

  sortfile();

  // terminate SMT
  *writeptr++ = 0;
  *writeptr++ = 0;

  // display length of SMT
  squasherprs("Length of SMT = %d bytes.\n", lengthsmt);

  // (Optional) Display sorted messages
  if (debug) {
    // Initialize read buffer
    readptr = (char *)startfilebuffer;
    nummessages = 0;

    squasherprs("\n");
    while (true) {
      if (!(readptr[0] | readptr[1])) {
        squasherprs("\nNumber of messages = %d.\n", nummessages);
        break;
      }
      displaysortedmessage();
      nummessages++;
    }
  }

  squasherprs("Number of modifications = %d.\n", modifycount);
  squasherprs("Number of text characters = %d.\n\n", numcharacters);
}

void sortfile() {
  //
  // Read characters until found start of message '['
  //
  while (true) {
    char c = *readptr++;
    if (c == eof) return; // Normal end-of-file exit
    if (c == terminator) {
      linenum++;
      continue;
    }
    if (c <= ' ') continue; // Skip spaces and control chars
    if (c == ';') { // Skip comment
      do {
        c = *readptr++;
        if (c == terminator) linenum++;
      } while (c != terminator && c != eof);
      if (c == eof) readptr--;
      continue;
    }
    if (c == '[') {
      sortmessage();
      continue;
    }
    // Character not part of official comment or message
    if (c == ']') {
      squasherprs("Mis-use of special character ']'");
      phase2error();
      break;
    }
    if (!seencomment) {
      seencomment = true;
      squasherprs("\nWarning: Text found outside square brackets. \n"
                  "All future text outside brackets will be treated\n"
                  "as comments. This first happened"); // at line n
      displaywhere();
    }
  }
}

void sortmessage() {
  // have come to '[' i.e. the start of a new message
  // Do the appropriate processing on it.

  // Messages are read from readptr and written to msgptr
  // this provides a way of remaining compatible with the serial files
  // originally used on the z80 squasher.

  msgptr = (char *)starttablememory;
  startmsg = msgptr;
  lastchar = ' ';

  // Read remainder of message
  while (true) {
    char c = *readptr++;
    *msgptr = c;
    if (c == ']') {
      endmsg = msgptr;
      *msgptr = 0;
      if (lastsigchar == terminator) {
        squasherprs("Illegal newline");
        phase2error();
        break;
      }
      // Check for message number
      msgptr = startmsg;
      int num = -1;
      while (*msgptr++ == ' '); // Skip spaces
      msgptr--;
      if (*msgptr >= '0' && *msgptr <= '9') {
        // Read the whole number
        num = readdecimal(&msgptr);
        while (*msgptr++ == ' '); // Skip spaces
        // If no colon it is no message number (or a mistake)
        if (*(msgptr - 1) != ':') {
          num = -1;
          squasherprs("Warning: message starts with number without colon");
          displaywhere();
        }
      } else {
        squasherprs("Warning: message does not start with number");
        displaywhere();
      }
      if (num == -1) {
        // Implicit next message number
        num = msgnum + 1;
        msgptr = startmsg;
      }
      if (num >= 65536 || num <= msgnum) {
        // Message numbers must be sorted
        // and within 16 bit range
        squasherprs("Illegal message number");
        phase2error();
        break;
      }
      // Set message number to calculated number
      msgnum = num;
      // Do not count explicit message number
      if (msgptr > startmsg) {
        numcharacters -= msgptr - startmsg;
        startmsg = msgptr;
      }
      // Calculate length of header required
      messagelength = endmsg - startmsg;
      if (!messagelength) return;
      // Add 6 bytes for sorted message header length
      int lenhdr = messagelength + 6;
      // Write header. Two bytes are length of entry
      *writeptr++ = lenhdr & 0xff;
      *writeptr++ = lenhdr >> 8;
      // Two bytes are message number
      *writeptr++ = msgnum & 0xff;
      *writeptr++ = msgnum >> 8;
      // Two bytes are source line number
      *writeptr++ = linenum & 0xff;
      *writeptr++ = linenum >> 8;
      // Copy message
      writeptr = mempcpy(writeptr, startmsg, messagelength);
      lengthsmt += lenhdr;
      return;
    }
    if (c != terminator && (c == cr || c == lf)) continue; // Skip fake terminators
    lastsigchar = c;
    if (c == '/') {
      // Escape disables effect of ']' and disables conversion.
      // Store 'escaped' characters with top bit set
      c = *readptr++;
      lastchar = c;
      if (c < ' ') {
        squasherprs("Mis-use of special character '/'");
        phase2error();
        break;
      }
      if (c != ' ') c |= 0x80;
    }
    if (c == '[') {
      squasherprs("Mis-use of special character '['");
      phase2error();
      break;
    }
    if (c == '^') { // Start of keyword
      lastchar = c;
      c = tolower(*readptr++);
      *++msgptr = c;
      if (!checktype(c)) {
        squasherprs("Mis-use of special character '^'");
        phase2error();
        break;
      }
      while (*readptr == ' ' || *readptr == lf || *readptr == cr) {
        if (*readptr == terminator) linenum++;
        readptr++;
      }
      numcharacters--; // Don't count keyword chars
    }
    if (c == '|') { // Keyword separator
      // '|' marks end of printable message, start of keywords
      // Remove any spaces stored before '|'
      lastchar = ' ';
      while (p1getlastchar() == ' ') msgptr--;
      // increments modify count below via case modify check
      // probably was not the intention
      // also, should we not subtract from number of characters?
    }
    if (c == terminator) {
      // Increment line number then as SPACE
      linenum++;
      if (p1getlastchar() == '%') continue;
      else *msgptr = c = ' ';
    }
    if ((uint8_t)c < ' ') {
      squasherprs("Illegal character $%02X", c);
      phase2error();
      break;
    }
    // Remove upper case chars if follow '.' '?' or '!'
    char mc = casemodify(c);
    if (mc & 0x80) {
      *msgptr = mc;
    } else if (mc != *msgptr) {
      *msgptr = mc;
      modifycount++;
    }
    // Next character
    numcharacters++;
    msgptr++;
  }
}

char p1getlastchar() {
  if (msgptr <= startmsg) return 0;
  else return *(msgptr - 1);
}

char casemodify(char c) {
  uint8_t uc = c;
  if (uc == ' ' || uc == '_' || uc == '%') return c;
  if (uc > '!' && uc <= ')') return c;

  uint8_t lc = lastchar;
  lastchar = c;
  if (lc == '!' || lc == '?' || lc == '.') {
    // Needs lower-case force, so set top bit
    if (c >= 'a' && c <= 'z') c |= 0x80;
    else lastchar = c = tolower(c);
  }
  return c;
}

void displaycode(char c) {
  if (c & 0x80) squasherprs("%c", '*');
  squasherprs("%c", c & 0x7f);
  squasherflush();
}

void displaysortedmessage() {
  int lenhdr = *(uint8_t *)readptr++;
  lenhdr += *(uint8_t *)readptr++ << 8;
  displayheader();
  squasherprs("Text ");
  for (int i = 0; i < lenhdr - 6; i++)
    displaycode(*readptr++);
  squasherprs("\n");
}

void displayheader() {
  msgnum = *(uint8_t *)readptr++;
  msgnum += *(uint8_t *)readptr++ << 8;
  linenum = *(uint8_t *)readptr++;
  linenum += *(uint8_t *)readptr++ << 8;
  squasherprs("Line %d Number %d ", linenum, msgnum);
}

void displaywhere() {
  squasherprs(" in line %d (message %d)\n\n", linenum, msgnum);
}

void displaylinenum() {
  displaywhere();
  returntogem();
}

void phase2error() {
  displaylinenum(); // Ends in exit to OS
}

//
// -----
//
// Phase 3 - Construct 'Frequency Table'
//
// Phase 3 scans the 'Sorted Message Table' and builds the
// Frequency Table' - A list of all 'words' in
// alphabetical order stored with the number of times they
// are used.
//
// The 'Frequency Table' occupies addresses startft
// thru endft-1.
//
// Each Frequency entry starts with
// the entries length (one byte) and the number of
// occurrances (two bytes.)
//
// -----
//

void phase03() {
  squasherprs("Phase 3 - Construct 'Frequency Table'\n\n");
  //
  // Clear 'Frequency Table'
  //
  startft = starttablememory;
  endft = startft;

  // Initialize read buffer
  readptr = (char *)startfilebuffer;

  //
  // Search each sentence picking out 'words'
  //
  numwords = 0;
  linenum = 0;
  msgnum = 0;

  while (true) {
    startmsg = readptr;
    int lenhdr = *(uint8_t *)readptr++;
    lenhdr += *(uint8_t *)readptr++ << 8;

    if (!lenhdr) {
      squasherprs("\n");
      // Check frequency table not too big (2^12-128)
      if (numwords > 0xf80) {
        squasherprs("More than $0F80 words");
        phase3error();
        break;
      }
      if (!noisy && !debug) squasherprs("\n");
      squasherprs("Number of 'words' = %d.\n", numwords);
      squasherprs("Length of 'Frequency Table' = %d bytes.\n\n", endft - startft);
      if (noisy) {
        squasherprs("Low memory used = %d bytes.\n", endft - starttablememory);
        squasherprs("High memory used = %d bytes. ", endmemory - startfilebuffer);
        squasherprs("Free = %d bytes.\n\n", startfilebuffer - endft);
      }
      return;
    }

    msgnum = *(uint8_t *)readptr++;
    msgnum += *(uint8_t *)readptr++ << 8;
    linenum = *(uint8_t *)readptr++;
    linenum += *(uint8_t *)readptr++ << 8;

    if (!(++Phase03ProgressCounter % 32)) {
      // display progress info every so often
      squasherprs("Line number = %d. ", linenum);
      squasherflush();
    }
    if (noisy) squasherprs("Message number = %d.\n", msgnum);

    messagelength = lenhdr - 6;
    countsentence();

    readptr = startmsg + lenhdr;
  }
}

void countsentence() {
  // Search each sentence skiping punctuation, picking out
  // words. readptr is address of start of text of sentence.
  // messagelength is its length.

  while (messagelength) {
    // If a non-simple word it will be preceeded by '^'
    // and a word-type.
    char c = *readptr;
    if (c == '^') {
      readptr++;
      messagelength--;
      if (!messagelength) {
        p3badwordtype();
        break;
      }
      c = tolower(*readptr);
      if (!checktype(c)) {
        p3badwordtype();
        break;
      }
      do {
        readptr++;
        messagelength--;
        // Word-type declaration must be followed by a word
        if (!messagelength) {
          p3badwordtype();
          break;
        }
        c = *readptr;
      } while (c == ' ');
      if (!validwordstart()) {
        p3badwordtype();
        break;
      }
    } else {
      // Check for a simple word
      if (!validwordstart()) {
        // Not part of a word so count as puctuation:
        charactercounts[(uint8_t)c & 0x7f]++;
        readptr++;
        messagelength--;
        continue;
      }
    }
    loadbuffer();
    addfrequency();
  }
}

bool validwordstart() {
  // Phase 3 only:
  // Returns true if a valid start-of-word sequence.
  // readptr is address of char in SMT. messagelength is number
  // or chars remaining in message.

  char c = *readptr & 0x7f;
  if (c >= '0' && c <= '9') return true;
  c = tolower(c);
  if (c >= 'a' && c <= 'z') return true;
  return false;
}

void p3badwordtype() {
  squasherprs("Bad use of special character '^'");
  phase3error();
}

void loadbuffer() {
  // Copy word from SMT into buffer.
  // readptr is address in SMT. messagelength is length of sentence
  // remaining.

  bufptr = buffer;
  while (messagelength) {
    char c = *readptr;
    // Protect capitals against wordcase determination in phase 7
    // In fact without the wordcase mechanism, no protection needed
    // But it can save a byte when more than one hyphen or quote used
    if (!(c & 0x80) && tolower(c) != c) *readptr |= 0x80;

    c &= 0x7f;
    if (c == '\'' || c == '-') {
      // Single quote, will be an apostrophe if followed by an
      // alpha. It's already preceeded by an alpha otherwise
      // can't be a word.
      uppointer();
      if (!messagelength) {
        downpointer();
        break;
      }
      c = tolower(*readptr);
      downpointer();
      if (c < 'a' || c > 'z') break;
      *bufptr = *readptr;
      uppointer();
    } else {
      c = tolower(c);
      if (c < 'a' || c > 'z')
        if (c < '0' || c > '9') break;
    }

    *bufptr = *readptr;
    uppointer();
  }

  // End of word
  *bufptr = 0;
}

void uppointer() {
  // Advance read and write pointers, decrement count (to
  // end of sentence.) Check that write pointer does not
  // escape buffer.
  readptr++;
  bufptr++;
  messagelength--;
  if (bufptr >= buffer + maxwordlen) {
    squasherprs("Word too long");
    phase3error();
  }
}

void downpointer() {
  // Retreat read and write pointers.
  readptr--;
  bufptr--;
  messagelength++;
}

void addfrequency() {
  // If word in buffer is already in dictionary its frequency 
  // count is incremented. Otherwise the word is inserted in
  // alphabetical order.

  int lenhdr = strlen(buffer) + 3;
  ftptr = startft;
  while ((void *)ftptr < endft) {
    int cmp = compare();
    if (cmp == 0) {
      // Word exists
      int occurrences = (uint8_t)ftptr[1] + ((uint8_t)ftptr[2] << 8);
      occurrences++;
      ftptr[1] = occurrences & 0xff;
      ftptr[2] = occurrences >> 8;
      if (debug) displayfrequency();
      return;
    } else if (cmp < 0) {
      // Insert word here.
      // Move up dictionary
      memmove(ftptr + lenhdr, ftptr, endft - (void *)ftptr);
      break;
    }
    // Move on one entry.
    ftptr += *ftptr;
  }

  endft += lenhdr;
  // Do not let 'Frequency Table' (built at bottom)
  // overwrite unprocessed section of 'Sorted Message Table'
  // (at top of memory)
  // ensure that this comparison traps overflows
  // before they become serious (hence extra amount)
  if (endft + 0x100 >= startfilebuffer) {
    squasherprs("'Frequency Table' full");
    phase3error();
    return;
  }

  // Put word in dictionary
  numwords++;
  ftptr[0] = lenhdr;
  ftptr[1] = 1; // Initially occurrences=1
  ftptr[2] = 0;
  memcpy(ftptr + 3, buffer, lenhdr - 3);
  if (debug) displayfrequency();
}

int compare() {
  int cmp = 0;
  int cmp2 = 0;
  int len = *ftptr;
  char *word = ftptr + 3;
  char *endword = ftptr + len;

  char next = *endword; // store next size
  *endword = 0; // temporarily terminate word

  // make an unforced copy of both words
  char c = 0;
  char *sptr = NULL;
  char *dptr = NULL;

  char bufword[maxwordlen + 1];
  sptr = buffer;
  dptr = bufword;
  while ((c = (*sptr++ & 0x7f))) *dptr++ = c;
  *dptr = 0;

  char ftword[maxwordlen + 1];
  sptr = word;
  dptr = ftword;
  while ((c = (*sptr++ & 0x7f))) *dptr++ = c;
  *dptr = 0;

  cmp = strcasecmp(bufword, ftword);
  if (cmp == 0) { // insensitive and unforced the same
    cmp2 = strcmp(buffer, word);
    if (cmp2 != 0) { // sensitive and forced not the same
      cmp = strcmp(bufword, ftword);
      if (cmp == 0) // sensitive and unforced the same
        cmp = -cmp2; // forced the same must be before unforced
      else { // sensitive and unforced not the same
        // forced lower case must be before forced uppercase
        cmp = -strcasecmp(buffer, word);
        if (cmp == 0) // insensitive and forced the same
          cmp = cmp2; // uppercase must be before lowercase
      }
    }
  }

  *endword = next; // restore next size
  return cmp;
}

void phase3error() {
  displaylinenum(); // Ends in returntogem
}

//
// -----
//
// Phase 4 - (Optional) Display 'Frequency Table'
//
// Phase 4 Displays the Sorted 'Frequency Table'
// list of all 'words'.
//
// -----
//

void phase04() {
  squasherprs("Phase 4 - (Optional) Display 'Frequency Table'\n");
  if (!debug) return;

  // Display 'Frequency Table'
  squasherprs("\n");
  ftptr = startft;
  while ((void *)ftptr < endft) {
    displayfrequency();
    ftptr += *ftptr;
  }
  squasherprs("\n");
  for (int i = 0; i < 128; i++)
    if (charactercounts[i])
      squasherprs("Character $%02X occurrences = %d\n", i, charactercounts[i]);
  squasherprs("\n");
}

void displayfrequency() {
  // Display a single entry from the 'Frequency Table'.
  // ftptr is the address of the entry.
  int len = *ftptr - 3;
  char *word = ftptr + 3;
  int occurrences = (uint8_t)ftptr[1] + ((uint8_t)ftptr[2] << 8);
  squasherprs("Occurrences = %d Word = ", occurrences);
  for (int i = 0; i < len; i++)
    displaycode(word[i]);
  squasherprs("\n");
}

//
// -----
//
// Phase 5 - Construct 'Common Word Dictionary'
//
// Phase 5 scans the 'Frequency Table' and picks
// most often used words. this are built into the 'Common
// Word Dictionary' at address startcwt thru endcwt-1.
//
// -----
//

void phase05() {
  // Clear 'Common Word Dictionary'
  squasherprs("Phase 5 - Construct 'Common Word Dictionary'\n");
  endcwt = startcwt = endft;

  // Select each word in 'Frequency Table' and assess it for
  // insertion into the 'Common Word Dictionary'.
  wordnumber = 0;
  ftptr = startft;
  while ((void *)ftptr < endft) {
    frequencytimes = (uint8_t)ftptr[1] + ((uint8_t)ftptr[2] << 8);
    assesscommonword();
    wordnumber++;
    ftptr += *ftptr;
  }

  // Go through each 'character' used and assess each to be
  // a common reference.
  for (int i = 0; i < 128; i++)
    if (i != '|' && charactercounts[i]) {
       frequencytimes = charactercounts[i];
       wordnumber = 0x0f80 + i;
       assesscommonword();
    }

  // Add some special combinations
  frequencytimes = 0x200;
  wordnumber = 0x1fae; // dot space
  assesscommonref();
  wordnumber = 0x1fac; // comma space
  assesscommonref();
  wordnumber = 0x1fba; // colon space
  assesscommonref();
  wordnumber = 0x2fa2; // space quote
  assesscommonref();

  // Convert 'Frequency Table' addresses to word references
  cwtptr = startcwt;
  char *convptr = cwtptr;
  while ((void *)cwtptr < endcwt) {
    convptr[0] = cwtptr[0];
    convptr[1] = cwtptr[1];
    cwtptr += 4;
    convptr += 2; // drop counts
  }
  endcwt = convptr;

  if (debug) {
    // Display 'Common Word Dictionary'
    squasherprs("\n");
    cwtptr = startcwt;
    while ((void *)cwtptr < endcwt) {
      wordnumber = (uint8_t)cwtptr[1] + ((uint8_t)cwtptr[0] << 8);
      displayword();
      cwtptr += 2;
    }
    squasherprs("\n");
  }

  // Display length of 'Common Word Dictionary'
  if (noisy)
    squasherprs("\nLength of 'Common Word Dictionary' = %d bytes.\n", endcwt - startcwt);
  if (noisy || debug) squasherprs("\n");
}

void displayword() {
  // Display word reference in wordnumber
  int type = (wordnumber >> 12) & 0x07;
  if (type) {
    // 1tttiiii, ttt is word type
    squasherprs("^%c", gettype(type));
  }

  int character = wordnumber - 0x0f80;
  if (character >= 0) {
    // character ref
    squasherprs(" {%c} ", character);
  } else {
    // word ref
    squasherprs(" [");
    int ref = wordnumber & 0x0fff;
    ftptr = startft;
    while ((void *)ftptr < endft) {
      if (!ref--) { // ref found
        // Display the word
        int len = *ftptr - 3;
        char *word = ftptr + 3;
        for (int i = 0; i < len; i++) {
          displaycode(word[i]);
        }
        squasherprs("] ");
        return;
      }
      // Move to next word
      ftptr += *ftptr;
    }
    // ref not found
    squasherprs("squash error. Invalid word number");
    returntogem();
  }
}

char types[] =  " "  // No meaning
                "v"  // Verb
                "j"  // Conjunction
                "p"  // Preposition
                "n"  // Noun
                "a"  // Adjective
                "c"  // Proper Noun
                "u"; // Captalised but no meaning
int checktype(char c) {
  int index = 0;
  char *pi = strchr(types + 1, c);
  if (pi) index = pi - types;
  return index;
}

char gettype(int index) {
  return types[index];
}

void assesscommonword() {
  // If word is more 'Common' than those in Dictionary then it
  // replaces one of them. ftptr is address of Frequency entry.

  wordnumber &= 0x0fff;
  assesscommonref();
}

void assesscommonref() {
  cwtptr = startcwt;
  while ((void *)cwtptr < endcwt) {
    int occurrences = (uint8_t)cwtptr[2] + ((uint8_t)cwtptr[3] << 8);
    if (frequencytimes >= occurrences) break;
    // Keep on moving down 'Common Word Dictionary'
    cwtptr += 4;
  }

  // Insert new Common Word
  if (endcwt + 4 >= startfilebuffer) {
    squasherprs("'Common Word Dictionary' too big");
    returntogem();
    return;
  }

  // Move up dictionary
  memmove(cwtptr + 4, cwtptr, endcwt - (void *)cwtptr);

  // Put word in dictionary
  cwtptr[0] = wordnumber >> 8;
  cwtptr[1] = wordnumber & 0xff;
  cwtptr[2] = frequencytimes & 0xff;
  cwtptr[3] = frequencytimes >> 8;

  // Adjust top of table pointer
  if (endcwt - (void *)startcwt < commonmaxentries * 4)
    endcwt += 4;
}

// stage 2 code

// -----
//
// Phase 6 - Construct 'Message Descriptors'
//
// Phase 6 Scans the 'Sorted Message Table' in conjunction
// with the 'Frequency Table' (for word numbers)
// 'Common Word Dictionary' (for short-form references)
// and builds the 'Message Descriptors'.
//
// -----
//

void phase06() {
  squasherprs("Phase 6 - Construct 'Message Descriptors'\n\n");

  // maxmdt will be highest byte used (below buffer)
  maxmdt = startmdt = endcwt;

  // Set up message number expected
  msgnum = 0;
  numshortrefs = 0;
  numlongrefs = 0;
  nummsgheads = 0;
  numjumpheads = 0;

  // Initialize read buffer
  readptr = (char *)startfilebuffer;

  // Initialize write buffer
  writeptr = startfilebuffer + spaceforsquashdat;
  lengthicf = 0;

  while (true) {
    char *start = readptr;
    int lenhdr = (uint8_t)readptr[0] + ((uint8_t)readptr[1] << 8);

    if (!lenhdr) { // end of SMT reached
      squasherprs("\n");
      if (!noisy) squasherprs("\n");

      if (debug) {
        // Display Message Descriptors
        squasherprs("Number of short-references = %d.\n", numshortrefs);
        squasherprs("Number of long-references = %d.\n", numlongrefs);
        squasherprs("Number of Message Headers = %d.\n", nummsgheads);
        squasherprs("Number of Jump Headers = %d.\n\n", numjumpheads);
      }

      lengthmd = lengthicf;
      indexmd = lengthicf + lengthpointers;

      squasherprs("Longest compressed message = %d bytes.\n", maxmdt - startmdt);
      squasherprs("Length compressed Message Desriptors = %d bytes.\n\n", lengthmd);
      if (noisy) {
        squasherprs("Low memory used = %d bytes.\n", maxmdt - starttablememory);
        squasherprs("High memory used = %d bytes. ", endmemory - startfilebuffer);
        squasherprs("Free = %d bytes.\n\n", startfilebuffer - maxmdt);
      }
      return;
    }

    convertmessage();

    // Increment expected message number
    msgnum++;

    if (!(++Phase06ProgressCounter % 32)) {
      // display progress info every so often
      squasherprs("Line number = %d. ", linenum);
      squasherflush();
    }

    readptr = start + lenhdr;
  }
}

void p6badwordtype() {
  squasherprs("Illegal use of special character '^'");
  p6error();
}

void modeerror() {
  squasherprs("squash error: Invalid p6mode value: $%02X", p6mode);
  p6error();
}

void p6error() {
  displaylinenum(); // ends in exit to OS
}

void convertmessage() {
  // Build a message descriptor from one 'Sorted Message
  // Table' entry. readptr is address of SMT entry.

  // Reset for new message:
  currentmdt = startmdt;

  // Get source line number (for errors)
  int msg = (uint8_t)readptr[2] + ((uint8_t)readptr[3] << 8);
  linenum = (uint8_t)readptr[4] + ((uint8_t)readptr[5] << 8);

  // Check this is the next message number in sequence
  int delta = msg - msgnum;
  if (!delta) {
    // Not a jump, Create zero-length 'Message Header'
    wordtype = 0;
    numkeywords = 0;
    p6mode = modeinit;

    startmsg = currentmdt;
    *(char *)currentmdt++ = 0;
    if (currentmdt >= startfilebuffer) mdtfull();

    nummsgheads++;
    messagelength = (uint8_t)readptr[0] + ((uint8_t)readptr[1] << 8) - 6;
    readptr += 6;
    if (noisy) squasherprs("Message number = %d.\n", msg);

    // Examine for words
    while (messagelength) {
      wordtype = 0;
      char c = *readptr;
      if (debug) displaycode(c);

      // Check for space (or implicit cr or lf)
      if (c == ' ') {
        switch (p6mode) {
          case modeinit:
            p6mode = modelead;
            break;
          case modenull:
            p6mode = modespace;
            break;
          case modechar:
            p6mode = modecs;
            break;
          case modesc:
            // Output character
            storecharacter(0x3f80 + p6char); // Leading+trailing spaces
            p6mode = modenull;
            break;
          case modecs:
          case modelead:
          case modespace:
            break;
          default: modeerror();
        }
        // Move on to next character
        readptr++;
        messagelength--;
        continue;
      }

      // Check for word-type
      wordaddress = readptr;
      if (c == '^') {
        // Process word-type declaration
        processwordtype();
      }

      // Check for known word
      int msglen = messagelength;
      if (c != '%' && c != '_' && c != '|' && findfrequency()) {
        // Frequency table address of word found, check if it's
        // a 'Common Word', convert and store its word number.
        switch (p6mode) {
          case modenull:
          case modeinit:
          case modespace:
            break;
          case modelead:
            // Only places where space is before a word are at start
            // of sentence or where space is forced as a character ('_' or '/ ')
            storecharacter(0x0f80 + ' ');
            break;
          case modesc:
            // Previously found space then character (hoping
            // to find another space, but got a word)
            // Leading space
            storecharacter(0x2f80 + p6char);
            break;
          case modecs:
            // Not stricktly required:
            // Trailing space
            storecharacter(0x1f80 + p6char);
            break;
          case modechar:
            storecharacter(0x0f80 + p6char);
            break;
          default: modeerror();
        }
        // Output word and reset to 'idle' state
        p6mode = modenull;
        storewordnum();
        continue;
      }
      // Not in Frequency Table (i.e. Not a 'word')
      readptr = wordaddress;
      messagelength = msglen;

      // Check for special character codes
      // '%' Forces a cr.
      // '_' Forces a space
      // '|' Terminates printing part of message
      c = *readptr;
      if (c & 0x80) c &= 0x7f;
      else if (c == '%') c = cr; // Forces a CR
      else if (c == '_') c = ' '; // Forces a SPACE
      else if (c == '|') { // End of printable message
        modeeof();
        examinekeywords();
        break;
      }

      // Handle character
      switch (p6mode) {
        case modeinit:
        case modenull:
          // Character in initial and 'idle' states just stores
          p6mode = modechar;
          break;
        case modelead:
        case modespace:
          // Following a space
          p6mode = modesc;
          break;
        case modechar:
          // Two characters together
          storecharacter(0x0f80 + p6char);
          p6mode = modechar;
          break;
        case modesc:
          // Space character character
          storecharacter(0x2f80 + p6char);
          p6mode = modechar;
          break;
        case modecs:
          // Character space character
          storecharacter(0x1f80 + p6char);
          p6mode = modechar;
          break;
        default: modeerror();
      }
      p6char = c; // store character
      // Move on to next character
      readptr++;
      messagelength--;
      continue;
    }

    // End of message descriptor
    modeeof();
    if (noisy && debug) squasherprs("\n");

    // Examine message header
    if (*startmsg) {
      squasherprs("Illegal message header");
      p6error(); // Calls displaylinenum and returntogem
    }

    // If message contains any non-garbage words then
    // set 'parse' bit in first header byte.
    if (numkeywords) *startmsg |= parse;

    // Calculate length of finished message
    int len = (char *)currentmdt - startmsg;
    frequencytimes = len;

    // Split out length bytes if needed
    while (len >= 0x003f + 1) {
      // Length is greater than allowed for a single
      // header byte, add additional header.
      writeicf(*startmsg++); // Duplicate 'PARSE' flag
      char *msgptr = currentmdt;
      for (int i = 0; i < frequencytimes; i++) msgptr[-i] = msgptr[-i - 1];
      currentmdt++;
      if (currentmdt >= startfilebuffer) mdtfull();
      len -= 0x003f;
    }

    // Replace length byte
    *startmsg |= len;
    if (currentmdt >= maxmdt) maxmdt = currentmdt;

    // Write message to ICF
    char *msgptr = startmsg;
    while (msgptr != currentmdt)
      writeicf(*msgptr++);
    return;
  }

  // Calculate distance of 'jump'
  delta--; // Jump range is 1-$80.
  if (delta >= 0x80) delta = 0x7f;

  // Adjust for new expected message number
  msgnum += delta + 1;

  // Make a jump header
  writeicf(delta | jump);
  numjumpheads++;

  // Next jump or actual message
  convertmessage();
}

void modeeof() {
  switch (p6mode) {
    case modenull:
    case modeinit:
      break;
    case modespace:
    case modelead:
      storecharacter(0x0f80 + ' ');
      break;
    case modechar:
      storecharacter(0x0f80 + p6char);
      break;
    case modesc:
      storecharacter(0x2f80 + p6char); // Leading space
      break;
    case modecs:
      storecharacter(0x1f80 + p6char); // Trailing space
      break;
    default: modeerror();
  }
  p6mode = modenull;
}

void examinekeywords() {
  // Examine for key words
  storereference(0x0f80);
  if (!messagelength) return;
  readptr++;
  messagelength--;

  while (messagelength) {
    wordtype = 0;
    char c = *readptr;
    if (debug) displaycode(c);

    // Check for 'special' characters
    if (c != '^') {
      // Not a keyword so ignore
      readptr++;
      messagelength--;
      continue;
    }

    // Process word-type declaration
    wordaddress = readptr;
    processwordtype();
    if (findfrequency()) {
      storewordnum(); // Store it
      continue;
    }

    // Not in Frequency Table (i.e. Not a 'word')
    readptr = wordaddress;
  }
}

void processwordtype() {
  // Process word-type declaration
  readptr++;
  messagelength--;
  if (!messagelength) {
    p6badwordtype();
    return;
  }
  char c = *readptr;
  if (debug) displaycode(c);
  if (!(wordtype = checktype(c))) {
    p6badwordtype();
    return;
  }
  numkeywords++;
  do {
    readptr++;
    messagelength--;
    if (!messagelength) {
      p6badwordtype();
      return;
    }
  } while (*readptr == ' ');
  wordaddress = readptr;
  if (debug) displaycode(*readptr);
}

bool findfrequency() {
  // Search directory for a matching word
  loadbuffer();
  ftptr = startft;
  while ((void *)ftptr < endft) {
    int cmp = compare();
    if (cmp == 0) { // On it
      // Found entry in Frequency Table
      return true;
    } else if (cmp < 0) { // Past it
      // Not in Frequency Table (i.e. Not a 'word')
      return false;
    }
    // Move on one entry.
    ftptr += *ftptr;
  }
  return false;
}

void storewordnum() {
  // Frequency table address of word found, check if it's
  // a 'Common Word', convert and store its word number.
  storereference(getwordnumber());
  if (!*buffer) return;
  char *bufptr = buffer + 1;
  if (debug) while (*bufptr) displaycode(*bufptr++);
}

int checkshortref(uint16_t val) {
  // val is Long word reference. Returns positive
  // short-ref. Otherwise returns -1.
  int shortref = 0;
  cwtptr = startcwt;
  while ((void *)cwtptr < endcwt) {
    int longref = *(uint8_t *)cwtptr++ << 8;
    longref += *(uint8_t *)cwtptr++;
    if (val == longref) return shortref;
    shortref++;
  }
  return -1;
}

int getwordnumber() {
  // ftptr is the address of a frequency entry.
  // Returns its word number.
  int wordnum = 0;
  char *entry = ftptr;
  ftptr = startft;
  while ((void *)ftptr < endft) {
    if (ftptr == entry) return wordnum;
    wordnum++;
    ftptr += *ftptr;
  }
  squasherprs("squash error. ");
  squasherprs("Short-reference address conversion failed.");
  returntogem();
  return -1;
}

void storereference(uint16_t val) {
  // Make it a long-form reference
  storecharacter(((wordtype << 12) & 0x7000) | (val & 0x0fff));
  wordtype = 0;
}

void storelongref(uint16_t val) {
  // val is a long-form word-reference. It is appended to the
  // end of the current message descriptor.
  val |= longf; // Make it a long-form reference
  if (currentmdt + 2 >= startfilebuffer) mdtfull();
  *(uint8_t *)currentmdt++ = val >> 8;
  *(uint8_t *)currentmdt++ = val & 0xff;
  numlongrefs++;
}

void storeshortref(uint8_t val) {
  // val is a short-form word-reference. It is appended to the
  // end of the current message descriptor.
  val &= ~longf; // Make it a short-form reference
  if (currentmdt + 1 >= startfilebuffer) mdtfull();
  *(uint8_t *)currentmdt++ = val;
  numshortrefs++;
}

void oldfix(uint16_t val) {
  if (val >= 0x2f80)
    storecharacter(0x0f80 + ' ');
  storecharacter(0x0f80 + p6char);
  if (val < 0x2f80)
    storecharacter(0x0f80 + ' ');
}

void storecharacter(uint16_t val) {
  if (oldgame && val >= 0x1f80 && val < 0x3f80) {
    oldfix(val);
    return;
  }
  int shortref = checkshortref(val);
  if (shortref >= 0) storeshortref(shortref);
  else storelongref(val);
}

void mdtfull() {
  // 'Message Descriptor Table' full
  squasherprs("'Message Descriptor Table' full");
  p6error();
}

void writeicf(uint8_t c) {
  *writeptr++ = c;
  lengthicf++;
}

void writeicf16(uint16_t val) {
  writeicf(val & 0xff);
  writeicf(val >> 8);
}

//
// -----
//
// Phase 7 - Construct 'Word Dictionary'
//
// Phase 7 Converts words from the 'Frequency Table' into
// a bit-stream of 5, 10 and 15 bit short-codes.
// These are used to build the 'Word Dictionary'
// at addresses currentmdt thru startfilebuffer.
// endwd holds the current top of the Dictionary.
//
// -----
//

void phase07() {
  squasherprs("Phase 7 - Construct 'Word Dictionary'\n");

  // Clear current segment:
  segnum = 0;
  lastpointer = segmentaddresses;

  // Clear 'Previous Word Start' buffer.
  clearthree();
  readwritepointer = unpack1;
  lastbyte = endseg;
  wordnumber = 0;

  // Convert all words
  ftptr = startft;
  while ((void *)ftptr < endft) {
    int len = *ftptr - 3;
    ftptr += 3;
    // segments are subdivided based on the first two chars
    // the second char amounts to max 4 (0-3) subdivisions
    // first find high part of segment number
    uint8_t seg = tolower(ftptr[0] & 0x7f);
    if (seg >= 'a') {
      seg -= 'a';
      if (seg < 26) {
        // seg is first char of word to put into dictionary.
        // We know it IS alphabetic
        // len is length of word
        seg <<= 2; // high part of segment number
        if (len >= 2) {
          // more than 2 chars in word, so find low part of segment number
          uint8_t lowseg = tolower(ftptr[1] & 0x7f);
          if (lowseg >= 'a') seg += ((lowseg - 'a') >> 3) & 3;
        }
      } else seg = 103; // (26 << 2) - 1

      // Next segment
      seg++;
      while (seg > segnum) {
        if (lastpointer != segmentaddresses + 26 * 4 * 4) {
          if (lastbyte != endseg)
            storeworddictionary(endseg);
          bytealign();
          int entry = lengthicf + lengthpointers;
          *lastpointer++ = entry & 0xff;
          *lastpointer++ = entry >> 8;
          *lastpointer++ = wordnumber & 0xff;
          *lastpointer++ = wordnumber >> 8;
        }
        segnum++;
      }
    }

    // Convert word
    ftptr -= 3;
    convertword();

    // Move on to next word
    wordnumber++;
  }

  // Extend table so it ends on a byte-boundary
  if (lastbyte != endseg) {
    // Terminate final word
    storeworddictionary(endseg);
  }
  bytealign();

  // Calculate offset into squash file end
  // and length of Word Dictionary.
  indexwd = lengthicf + lengthpointers;
  lengthwd = indexwd - indexmd;

  // (Optional) Display length of table
  if (noisy) {
    squasherprs("\nLength of 'Word Dictionary' = %d bytes.\n\n", lengthwd);
  }
}

void clearthree() {
  threecharacters[0] = 0;
  threecharacters[1] = 0;
  threecharacters[2] = 0;
  threecharacters[3] = 0;
}

void bytealign() {
  // Clear current unpack buffer (which must end in an endseg code)
  // and re-align endwd to the byte following the byte containing
  // the last bit of the endseg code.
  //
  // Also clears threecharacters to force $1C header type next.
  clearthree();
  int delta = readwritepointer - unpack1;
  if (!delta) return;

  doconversion();

  switch (delta) {
    case 1:
    case 2:
      break;
    case 3:
      delta = 2;
      break;
    case 4:
      delta = 3;
      break;
    case 5:
      delta = 4;
      break;
    case 6:
      delta = 4;
      break;
    case 7:
      delta = 5;
      break;
    default:
      squasherprs("byte-align error");
      returntogem();
  }

  // delta holds the number of bytes of 'pack'ed data
  // to be written to dictionary
  uint8_t *p = pack1;
  for (int i = 0; i < delta; i++)
    writeicf(*p++);
  readwritepointer = unpack1;
}

void convertword() {
  // Change one 'Frequency Table' entry to a
  // 'Word Dictionary' entry. ftptr is the address of
  // the 'Frequency Table' entry.
  int wordlen = *ftptr - 3;
  wordaddress = ftptr += 3;
  wordcase = false;
  int same = 0; // Number of characters the same

  // Determine similarity
  int len = wordlen;
  char *cptr = threecharacters;
  while (same != maxheaderlength
      // Don't exceed header length
      && len // Don't go beyond end of word
      && *cptr == *ftptr) { // End of similarity?
    ftptr++;
    cptr++;
    len--;
    same++;
  }

  // Save Word header (111xx, xx is number of characters
  // same as previous word.)
  storeworddictionary((same & 0x03) | header);
  clearthree();

  // Copy three characters
  ftptr = wordaddress;
  len = wordlen;
  int min = maxheaderlength;
  min = (len < min) ? len : min;
  for (int i = 0; i < min; i++)
    threecharacters[i] = *ftptr++;

  // Save word itself
  ftptr = wordaddress;
  len = wordlen;

  // Skip similar characters
  while (same--) {
    ftptr++;
    len--;
  }

  // Save remainder of word
  while (len) {
    // If remainder of word contains upper case chars but no lower case
    // then put in an upper-case-word marker.
    if (!wordcase) {
      // This would take advantage of all-uppercase words
      // but the buffer loading in phase 3 protects mostly against that
      // except for the odd unprotected character after hyphen or quote
      // which saves a byte - was it all meant to do better?
      // The issue is that when storing the word in lower case,
      // the decompression gets confused with the starting similiarity
      // where e.g. the subsequent capitalized word loses its capital
      wordcase = uppercaseword(len);
      if (wordcase) {
        storeworddictionary(longc);
        storeworddictionary(uppercasemark);
      }
    }
    // If character is preceeded by '/' it cannot be a
    // normal character so it must be a long-escape code.
    uint8_t val = *ftptr;
    if (!(val & 0x80) && wordcase) val = tolower(val);
    if (val & 0x80 || val < 'a' || val > 'z' ) {
      // Not an auto-case alpha so do an escape sequence
      val = val & 0x7f;
      // Long escape sequence
      storeworddictionary(longc);
      storeworddictionary((val >> 5) & 0x03);
      storeworddictionary( val       & 0x1f);
    } else {
      // Not escaped, so since it is lower-case alpha
      // it can be represented as a 5-bit short-code.
      storeworddictionary(val - 'a');
    }
    // Move on to next character of word in Frequency Table.
    ftptr++;
    len--;
  }
}

bool uppercaseword(int len) {
  // ftptr is address within Frequency table of a word or part
  // or a word, len is number of chars in remainder
  // Returns true if word is suitable for an
  // upper-case-only marker.
  int upper = 0;
  char *cptr = ftptr;
  while (len) {
    char c = *cptr++;
    if (c >= 'a' && c <= 'z') return false;
    if (c >= 'A' && c <= 'Z') upper++;
    len--;
  }
  // Found end of word with no lower-case, Check that
  // word contains enough upper-case
  if (upper < 2) return false;
  return true;
}

void storeworddictionary(uint8_t val) {
  lastbyte = val;
  *readwritepointer++ = val;
  if (readwritepointer != unpack1 + 8) return;
  readwritepointer = unpack1;

  // Convert 8 short-codes to 5 bytes
  doconversion();

  // Store all 5 bytes of 'PACK'ed buffer
  for (int i = 0; i < 5; i++)
    writeicf(pack1[i]);
}

void doconversion() {
  // Convert block of 8 short-codes to 5 bytes.

  // unpack1: 000aaaaa --> aaaaa000
  // unpack2: 000bbbbb --> 00000bbb
  // Store aaaaabbb
  *pack1 = ((*unpack1 << 3) & 0xf8)
         | ((*unpack2 >> 2) & 0x07);
  // unpack2: 000bbbbb --> bb000000
  // unpack3: 000ccccc --> 00ccccc0 
  // unpack4: 000ddddd --> 0000000d
  // Store bbcccccd
  *pack2 = ((*unpack2 << 6) & 0xc0)
         | ((*unpack3 << 1) & 0x3e)
         | ((*unpack4 >> 4) & 0x01);
  // unpack4: 000ddddd --> dddd0000
  // unpack5: 000eeeee --> 0000eeee
  // Store ddddeeee
  *pack3 = ((*unpack4 << 4) & 0xf0)
         | ((*unpack5 >> 1) & 0x0f);
  // unpack5: 000eeeee --> e0000000
  // unpack6: 000fffff --> 0fffff00
  // unpack7: 000ggggg --> 000000gg
  // Store efffffgg
  *pack4 = ((*unpack5 << 7) & 0x80)
         | ((*unpack6 << 2) & 0x7c)
         | ((*unpack7 >> 3) & 0x03);
  // unpack7: ;000ggggg --> ggg00000
  // unpack8: ;000hhhhh --> 000hhhhh
  // Store ggghhhhh
  *pack5 = ((*unpack7 << 5) & 0xe0)
         | ((*unpack8     ) & 0x1f);

  // pack1 thru pack5 contain 5 bytes
  // packed short-codes.
}

//
// -----
//
// Phase 8 - Construct 'Word Dictionary Index'
//
// Reads the segmentaddresses table built by the
// 'Construct Word Dictionary' phase and builds the 'Word
// Dictionary Index' between addresses startwdi and startfilebuffer
//
// The current top of this table is endwdi.
//
// -----
//

void phase08() {
  squasherprs("Phase 8 - Construct 'Word Dictionary Index'\n");

  // Clear table
  numsegs = 0;

  // Copy each entry from segmentaddresses subtracting start
  // address of 'Word Dictionary' to give offset.
  char *segptr = segmentaddresses;
  while (segptr < lastpointer) {
    // Get address of byte-aligned boundary
    // and store offset
    writeicf(*segptr++);
    writeicf(*segptr++);
    writeicf(*segptr++);
    writeicf(*segptr++);
    numsegs++;
  }

  // (Optional) Display length of table
  indexwdi = lengthicf + lengthpointers;
  if (noisy)
    squasherprs("\nLength of 'Word Dictionary Index' = %d bytes.\n\n", indexwdi - indexwd);

  // Option to display Segment Table Index removed:
  // too difficult when writing squash file 'on-the-fly'
  // Original listing not useful anyway.
}

//
// -----
//
// Phase 9 - Build Squash File
//
// Move 'Common Word Index' to be above 'Word Dictionary Index'
// then build the 'squash' file and save it.
//
// -----
//

void phase09() {
  squasherprs("Phase 9 - Build Squash File\n\n");

  // Save CWT to ICF
  cwtptr = startcwt;
  while ((void *)cwtptr < endcwt) {
    writeicf(*cwtptr++);
  }

  finalchecksum = 0;
  squasherprs("Writing squash.dat ...\n\n");
  writeptr = startfilebuffer;

  // Write Header/Pointers:
  // Length of file
  writesquash16(lengthicf + lengthpointers + 1);
  // Offset to Message Descriptors
  writesquash16(lengthpointers);
  // Length of Message Descriptors
  writesquash16(lengthmd);
  // Offset to Word Dictionary
  writesquash16(indexmd);
  // Length of Word Dictionary
  writesquash16(lengthwd);
  // Offset to Dictionary Index
  writesquash16(indexwd);
  // Number of Segments
  writesquash16(numsegs);
  // Offset to Common Word Index
  writesquash16(indexwdi);
  // Version number
  writesquash(minor);
  writesquash(major);
  // Unused
  writesquash16(0);

  // Copy ICF file to squash file
  readptr = startfilebuffer + spaceforsquashdat;
  for (int i = 0; i < lengthicf; i++)
    writesquash(*readptr++);

  // Write checksum
  writesquash(-finalchecksum);

  // (Optional) Pad file to be a multiple of 256 bytes long
  int partial = (lengthicf + lengthpointers + 1) % 256;
  if (partial) // Uneven part of bytes written sofar
    for (int i = 256; i > partial; i--) writesquash(0);

  // Now write out squash.dat to disk...
  savesquashdatdriverblock.start = startfilebuffer;
  savesquashdatdriverblock.end = writeptr;
  driver(savedcode, &savesquashdatdriverblock);

  // Print Statistics
  squasherprs("File 'message.txt' length = %d bytes.\n", inputlength);
  squasherprs("Number of characters = %d. ", numcharacters);
  squasherprs("Number of words = %d.\n\n", numwords);
  if (noisy) {
    squasherprs("Low memory used = %d bytes.\n", maxmdt - startft);
    squasherprs("High memory used = %d bytes. ", endmemory - startfilebuffer);
    squasherprs("Free = %d bytes.\n\n", startfilebuffer - maxmdt);
  }
  squasherprs("File 'squash.dat' length = %d bytes.\n", lengthicf + lengthpointers + 1);
  squasherprs("Compressed size of message descriptors = %d bytes.\n", lengthmd);
  squasherprs("Compressed size of word dictionary     = %d bytes.\n", lengthwd);
  int percentage = calccompression();
  squasherprs("Compression = %d%% of filesize = %d%% saved space.\n", percentage, 100 - percentage);
}

void writesquash(uint8_t c) {
  *writeptr++ = c;
  finalchecksum += c;
}

void writesquash16(uint16_t val) {
  writesquash(val & 0xff);
  writesquash(val >> 8);
}

int calccompression() {
  return (lengthicf + lengthpointers + 1) * 100 / numcharacters;
}

// main, chain, selectdr and RAM variables
void *ram = NULL;
char squasherdriverbuffer[40];
char subdirname[100];
char directoryname[] = "*.l9";

// selectdr code

void selectdirectory() {
  squasherprs("\n\n\n                             ");
  squasherprs("Level 9 Adventures");
  squasherprs("\n\n                  ");
  squasherprs("Copyright (C) 1986-1988 Level 9 Computing\n\n\n\n\n");
  int found = 0; // number of files found
  int current = 0;
  int selection = 0;
  glob_t globbuf;
  glob(directoryname, 0, NULL, &globbuf);
  found = globbuf.gl_pathc;
  while (current < found) {
    squasherprs("                               ");
    squasherprs("%c .. %s\n", current + 'A', globbuf.gl_pathv[current]);
    current++;
  }

  if (!found) {
    squasherprs("\nNo suitable sub-directories available - searching current.\n\n");
    return;
  } else if (found == 1) {
    squasherprs("Only one sub-directory - proceeding with squash\n\n");
  } else {
    squasherprs("Enter the letter corresponding to your choice .. ");
    char c;
    do {
      // now get a letter
      c = toupper(waitkey());
      squasherprs("%c\n", c);
      selection = c - 'A';
    } while (selection < 0 || selection >= found);
    squasherprs("\n");
  }
  strcpy(subdirname, globbuf.gl_pathv[selection]);
  globfree(&globbuf);
  chdir(subdirname);
}

// chain code

void squash() {
  ram = malloc(ramsize);
  endmemory = ram + ramsize;

  squasherprs("\nCOMPACT " MAJOR "." MINOR "\n");
  squasherprs("7th September 1987\n");
  squasherprs("Available memory = %d bytes\n\n", endmemory - ram);

  // Up to 128 entries allowed in 'Common Word Dictionary'
  commonmaxentries = 128;
  squasherprs("Options: %c %c %d\n\n", noisy ? 'Y' : 'N', debug ? 'Y' : 'N', commonmaxentries);

  selectdirectory();

  phase01();
  phase02();
  phase03();
  phase04();
  phase05();
  phase06();
  phase07();
  phase08();
  phase09();

  returntogem();
}

// main code

void usage(char *progname) {
  printf("Usage: %s [options]\n\n", progname);
  printf("Options:\n");
  printf("--help: print this usage message\n");
  printf("--oldgame: squash for old games e.g. Adrian Mole/Archers\n");
  printf("--noisy: enable noisy messages\n");
  printf("--debug: enable debug messages\n");
  printf("\n");
  exit(0);
}

int main(int argc, char **argv) {
  int arg = 0;
  while (++arg < argc) {
    if (strcmp(argv[arg], "--help") == 0) usage(argv[0]);
    if (strcmp(argv[arg], "--oldgame") == 0) { oldgame = true; continue; }
    if (strcmp(argv[arg], "--noisy") == 0) { noisy = true; continue; }
    if (strcmp(argv[arg], "--debug") == 0) { debug = true; continue; };
    printf("Unrecognized argument: '%s'\n\n", argv[arg]);
    usage(argv[0]);
  }
  squash();
  return 0;
}
