// Menu program for adventures on Atari ST (adapted for Linux)
//
// M.J.Austin started 22/8/86
// last change: 3/11/86
// Linux version: 6/2/26
//
// Copyright (C) 1986 Level 9 Computing

#include "menu.h"

uint8_t *startfile = NULL;
char directoryname[] = "*.l9";
char acodename[] = "acod1.dat";
bool splitdata = false;

void menustart() {
  int found = 0; // number of files found
  int current = 0;
  int selection = 0;
  glob_t globbuf;
  for (int i = 0; i < 25; i++) prs("\n"); // clear screen

  do {
    prs("\n\n                             Level 9 Adventures\n\n"
        "                    "
        "Copyright (C) 1986 Level 9 Computing\n\n\n\n\n");

    // look in current directory for interesting sub-directories - 
    // i.e. those which match with directoryname
    glob(directoryname, 0, NULL, &globbuf);
    found = globbuf.gl_pathc;
    while (current < found) {
      char base = '1' + (current > 8 ? 7 : 0);
      *strchr(globbuf.gl_pathv[current], '.') = 0;
      prs("                               ");
      prs("%c .. %s\n", current + base, globbuf.gl_pathv[current]);
      *strchr(globbuf.gl_pathv[current], 0) = '.';
      current++;
    }

    selection = 0;
    if (!found) {
      prs("No suitable files on disk\n");
      prs("Press a key to return to gem\n");
      waitkey();
      returntogem();
      return;
    } else if (found == 1) {
      prs("Only one game available - I am loading it!\n");
    } else {
      prs("Press the key corresponding to your choice ");
      prs("or '?' for more information. ");
      char c;
      do {
        // now get a digit
        c = toupper(waitkey());
        prs("%c\n", c);
        if (c == '?') {
          displayhelp();
          selection = -1;
          break;
        }
        if (c > '9') c -= 7;
        selection = c - '1';
      } while (selection < 0 || selection >= found);
    }
  } while (selection < 0);

  chdir(globbuf.gl_pathv[selection]);
  glob(acodename, 0, NULL, &globbuf);
  if (globbuf.gl_pathc) splitdata = true;
  globfree(&globbuf);
  intstart();
}

void displayhelp() {
  prs("\n\n"
      "When entering commands in a game, you may use the cursor"
      " left and right keys\n"
      "to move through a line and make changes as required."
      " Previous lines may be\n"
      "recalled and edited using the up and"
      " down cursor keys:"
      " press return when the\n"
      "line looks correct.\n"
      "\n"
      "There is a 1000 character type-ahead buffer, so you can"
      " enter commands\n"
      "while the game is obeying your earlier orders."
      " If something goes wrong\n"
      "(like a monster appearing!), "
      "you can clear the type-ahead buffer by\n"
      "pressing the key marked 'Esc'.\n\n"
      "To leave the game, press 'Alt' and 'Q'.\n\n"
      "The 'Help' and 'Undo' keys perform useful functions.\n\n"
      "[All this is not implemented.]\n" // XXX
      "Have fun, and press a key to return to the menu. ");

  waitkey();
}

bool i8086 = false;
void usage(char *progname) {
  printf("Usage: %s [options]\n\n", progname);
  printf("Options:\n");
  printf("--help: print this usage message\n");
  printf("\n");
  exit(0);
}
int main(int argc, char **argv) {
  int arg = 0;
  while (++arg < argc) {
    if (strcmp(argv[arg], "--help") == 0) usage(argv[0]);
    printf("Unrecognized argument: '%s'\n\n", argv[arg]);
    usage(argv[0]);
  }
  menustart();
  return 0;
}
