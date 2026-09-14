// Code generation section specific to particular processors
//
// 68000 version (adapted for Linux).
//
// Copyright (C) 1988 Level 9 Computing

#include "common.h"

// function declarations needed for forward references in code.c
void MCPushPop(uint8_t *, int);
void MCAddSub(uint8_t *);
bool MCDataEntry();
void MCShortGoto();
void MCLongGoto();
void MCShortGosub();
void MCLongGosub();
void MCShortJump();
void MCLongJump();
void Generate(uint8_t *, int, int, int);
void GenerateLen(uint8_t *, uint8_t, int, int, int);
void TableGenerate(uint8_t *, uint8_t *, int, int, int);

// defined in comp.c
extern bool testcomp;
extern bool i8086;
extern char *ptr;
extern void *compacodeptr;
extern void *startacode;
extern struct _forwardentry *startforward;
extern void *opcodeaddress;
extern void *jumpdummyopcode;
extern void *dummyshortopcode;
extern void *dummylongopcode;
extern bool forcedlongjumps;
extern bool SixteenFlag;
extern char CodeState;
extern void codew(uint16_t);
extern void code(uint8_t);
extern int compgetvar();
extern int getlabel(struct _symbol **);
extern int evaloperator();
extern bool findsymbol(struct _symbol **);
extern int getnumberconstant();
extern int stringcompare();
extern int compsearch();
extern void compssskiptoeol();
extern void EvenError();
extern void commaexpected();
extern void NotAllowedInMC();
extern void WrongCodeState();
extern void MCTooFar();
extern void reljumpoutofrange();
extern void badtype();
extern void bracketsexpected();
extern void badindex();
extern void equalsexpected();
extern void compnotimp();
extern void forwardoutofrange(struct _symbol *, struct _forwardentry *);

// code data table structure
struct _datatable {
  uint8_t *ShortGoto;
  uint8_t *LongGoto;
  uint8_t *ShortGosub;
  uint8_t *LongGosub;
  uint8_t *Return;
  uint8_t *ToAcode;
  uint8_t *LetVC;
  uint8_t *LetVV;
  uint8_t *AddVV;
  uint8_t *SubVV;
  uint8_t *IfNEVCShort;
  uint8_t *IfNEVCLong;
  uint8_t *IfEQVCShort;
  uint8_t *IfEQVCLong;
  uint8_t *IfLTVCShort;
  uint8_t *IfLTVCLong;
  uint8_t *IfGTVCShort;
  uint8_t *IfGTVCLong;
  uint8_t *IfNEVVShort;
  uint8_t *IfNEVVLong;
  uint8_t *IfEQVVShort;
  uint8_t *IfEQVVLong;
  uint8_t *IfLTVVShort;
  uint8_t *IfLTVVLong;
  uint8_t *IfGTVVShort;
  uint8_t *IfGTVVLong;
  uint8_t *AttVV;
  uint8_t *AttCV;
  uint8_t *AftVV;
  uint8_t *AftVC;
  uint8_t *AttVV16;
  uint8_t *AttCV16;
  uint8_t *AftVV16;
  uint8_t *AftVC16;
  uint8_t *BreakPt;
  uint8_t *Push;
  uint8_t *Pop;
  uint8_t *AndVV;
  uint8_t *OrVV;
  uint8_t *XorVV;
  uint8_t *ASR;
};
