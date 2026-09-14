// 68000 Acode interpreter (adapted for Linux)
// ST MC interpretation
//
// Copyright (C) 1986-1988 Level 9 Computing

#include "int.h"

void initsthuge() {
  pc = acodeptr + 8; // @MCFns
  int16_t offset = pc[0] << 8;
  offset += pc[1];
  pc += offset; // data @Dummy
  hugesystemstart = pc;

  offset = pc[0] << 8;
  offset += pc[1];
  pc += offset; // .Dummy
  hugesystemend = pc;

  pc = acodeptr + 6; // @AcodeFns
  offset = pc[0] << 8;
  offset += pc[1];
  pc += offset; // goto @AcodeStart

  hugevbl = pc + 28; // goto @VBL

  pc += 2;
  offset = pc[0] << 8;
  offset += pc[1];
  pc += offset; // .AcodeStart

  // catch code +
  pc -= 2;
  if (*pc != 0xc) pc -= 8;
}

int16_t getoffset() {
  int16_t offset = *(int8_t *)pc++;
  if (!offset) {
    offset = *pc++ << 8;
    offset += *pc++;
  }
  return offset;
}

uint8_t *dojump() {
  uint8_t *address = pc + 1;
  address += getoffset();

  uint8_t *retaddr = pc;
  pc = address;

  return retaddr;
}

int16_t getstword() {
  int16_t word = *pc++ << 8;
  word += *pc++;
  return word;
}


int16_t getstvar() {
  return getstword() / 2;
}

int16_t getstlist() {
  return getstword() / 4;
}

void stintGoto(uint8_t code) {
  dojump();
}

void stintGosub(uint8_t code) {
  uint8_t *retaddr = dojump();
  instructionloop(); // stack loops
  if (popins) {
    popins = false;
    vartable[popvar] = retaddr - acodeptr;
  } else {
    mc = true;
    retins = false;
    pc = retaddr;
  }
}

void stintRet(uint8_t code) {
  retins = true;
}

void stintLetVC(uint8_t code) {
  int16_t val = getstword();
  int16_t var = getstvar();
  vartable[var] = val;
}

void stintLetVV(uint8_t code) {
  int16_t var2 = getstvar();
  int16_t var1 = getstvar();
  vartable[var1] = vartable[var2];
}

void stintOpVV(uint8_t code) {
  int16_t var2 = getstvar();
  code = getstword() >> 8;
  int16_t var1 = getstvar();

  switch (code) {
    case 0xd1: // add
      vartable[var1] += vartable[var2];
      break;
    case 0x91: // sub
      vartable[var1] -= vartable[var2];
      break;
    case 0xc1: // and
      vartable[var1] &= vartable[var2];
      break;
    case 0x81: // or
      vartable[var1] |= vartable[var2];
      break;
    case 0xb1: // xor
      vartable[var1] ^= vartable[var2];
      break;
    case 0xe2: // asr
      var1 = getstvar();
      ((int16_t *)vartable)[var1] >>= 1;
      break;

    case 0xb0: // cmp
      code = *pc++;
      uint8_t *address = pc + 1;
      address += getoffset();
      switch (code) {
        case 0x66: // bne
          if (vartable[var2] != vartable[var1])
            pc = address;
          break;
        case 0x67: // beq
          if (vartable[var2] == vartable[var1])
            pc = address;
          break;
        case 0x65: // blt
          if (vartable[var2] < vartable[var1])
            pc = address;
          break;
        case 0x62: // bhi
          if (vartable[var2] > vartable[var1])
            pc = address;
          break;
        default: ilins(code);
      }
      break;
    case 0x31: // 0x31ac: move.w v2(a4),0(a0,d0)
      // shorted version of 16bit access for list0ptr
      // in theory other variants are possible
      // this one is sufficient for BTK
      uint16_t index = vartable[var2];
      pc += 2; // skip remainder
      if (index < getmaxind(list0ptr))
        *(uint16_t *)&list0ptr[index] = vartable[var1];
      break;

    default: ilins(code);
  }
}

void stintPush(uint8_t code) {
  int16_t var = getstvar();
  uint16_t val = vartable[var];
  instructionloop(); // stack loops
  if (popins) {
    popins = false;
    vartable[popvar] = val;
  } else {
    mc = true;
    retins = false;
    pc = acodeptr + val;
  }
}

void stintPop(uint8_t code) {
  popvar = getstvar();
  popins = true;
}

void stintIfVC(uint8_t code) {
  uint16_t val = getstword();
  int16_t var = getstvar();
  code = *pc++;
  uint8_t *address = pc + 1;
  address += getoffset();

  switch (code) {
    case 0x66: // bne
      if (vartable[var] != val)
        pc = address;
      break;
    case 0x67: // beq
      if (vartable[var] == val)
        pc = address;
      break;
    case 0x65: // blt
      if (vartable[var] < val)
        pc = address;
      break;
    case 0x62: // bhi
      if (vartable[var] > val)
        pc = address;
      break;
    default: ilins(code);
  }
}

void stintTable(uint8_t code) {
  int16_t num = getstlist();
  uint16_t ins = getstword();
  int16_t var1 = 0;
  int16_t var2 = 0;
  int16_t var = 0;
  uint16_t index = 0xffff;

  uint8_t *table = gettable(num);
  if (!table) ilins(code);

  switch (ins) {
    case 0x302c: // move.w v1(a4),d0
      var1 = getstvar();
      index = vartable[var1];
      ins = getstword();
      switch (ins) {
        case 0x11ac: // move.b v2+1(a4),0(a0,d0)
          var2 = getstvar();
          pc += 2; // skip remainder
          if (table && index < getmaxind(table))
            table[index] = vartable[var2];
          break;
        case 0x426c: // clr.w v2(a4)
          var2 = getstvar();
          vartable[var2] = 0;
          pc += 6; // skip remainder
          if (table && index < getmaxind(table))
            vartable[var2] = table[index];
          break;
        case 0x31ac: // move.w v2(a4),0(a0,d0)
          var2 = getstvar();
          pc += 2; // skip remainder
          if (table && index < getmaxind(table))
            writetable16(table, index, vartable[var2]);
          break;
        case 0x3970: // move.w 0(a0,d0),v2(a4)
          pc += 2; // skip indexbyte
          var2 = getstvar();
          if (table && index < getmaxind(table))
            vartable[var2] = readtable16(table, index);
          break;
        default: ilins(ins >> 8);
      }
      break;
    case 0x116c: // move.b v2+1(a4),cccc(a0)
      var = getstvar();
      index = getstword();
      if (table && index < getmaxind(table))
        table[index] = vartable[var];
      break;
    case 0x426c: // clr.w v2(a4)
      var = getstvar();
      ins = getstword();
      vartable[var] = 0;
      index = getstword();
      if (ins == 0x1968) { // move.b cccc(A0),v2+1(a4)
        pc += 2; // skip remainder
        if (table && index < getmaxind(table))
          vartable[var] = table[index];
      }
      break;
    case 0x316c: // move.w v2(a4),cccc(a0)
      var = getstvar();
      index = getstword();
      if (table && index < getmaxind(table))
        writetable16(table, index, vartable[var]);
      break;
    case 0x3968: // move.w cccc(a0),v2(a4)
      index = getstword();
      var = getstvar();
      if (table && index < getmaxind(table))
        vartable[var] = readtable16(table, index);
      break;
    default: ilins(ins >> 8);
  }
}

void executestmc(uint8_t code) {
  switch (code) {
    case 0x60: // bra
      stintGoto(code);
      break;
    case 0x61: // bsr
      stintGosub(code);
      break;
    case 0x4e:
      code = *pc++;
      if (code == 0x75) // rts
        stintRet(code);
      else if ((code & 0xd0) == 0xd0) // jmp(aX)
        mc = false; // end of code section
      break;
    case 0x20:
      code = *pc++;
      if (code == 0x7a) // move.l rel(pc),a0
        pc += 2; // skip rel
      else if (code == 0x6b) // move.l n*4(a3),a0
        stintTable(code);
      break;
    case 0x2a:
      code = *pc++;
      if (code == 0x7c) // move.w val,a5
        pc += 4; // skip val
      break;
    case 0x39:
      code = *pc++;
      if (code == 0x7c) // move.w c,v(a4)
        stintLetVC(code);
      else if (code == 0x6c) // move.w v2,v1(a4)
        stintLetVV(code);
      else if (code == 0x5f) // move.l (sp)+,v1(a4)
        stintPop(code);
      break;
    case 0x30:
      code = *pc++;
      if (code == 0x2c) // move.w v(a4),d0
        stintOpVV(code);
      break;
    case 0x4a:
      code = *pc++;
      if (code == 0xfa) // break
        breakpointaddress = pc - acodeptr;
      break;
    case 0x3f:
      code = *pc++;
      if (code == 0x2c) // move.l v1(a4),-(sp)
        stintPush(code);
      break;
    case 0x0c:
      code = *pc++;
      if (code == 0x6c) // cmp.w c,v(a4)
        stintIfVC(code);
      break;
    default: ilins(code);
  }
}
