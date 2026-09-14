// Atari ST driver (minimal parts adapted for Linux)
// Copyright (C) 1986-1988 Level 9 Computing

#include "common.h"

#define autorunsize 32000

// function declarations needed for forward references in driver.c
void getclock(void *);
void randomnumber(void *);
void lenslokdisplay(char *);
void ramsave(void **);
void ramload(void **);
bool initram(void **);
void closedown();
void killmultitasking();
void resetginttask();
void init1();
bool init2();
void init();
void calcchecksum(struct _fcb *);
void driverloadfile(struct _fcb *);
void driversavefile(struct _fcb *);
char osrdch();
void driveroswrch(char *);
void oswrch(char);
void driverinputline(char *);
void driverosrdch(char *);
void settext();
void displayhiresvector(void *);
void testhiresvector(void *);
