// Menu program for adventures on Atari ST (adapted for Linux)
//
// Copyright (C) 1986 Level 9 Computing

#include "common.h"

// function declarations needed for forward references in menu.c
void displayhelp();

// defined in int.c or driver.c
extern char driverbuffer[40];
extern void intstart();
