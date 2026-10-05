// 68000 Acode interpreter (adapted for Linux)
// PC MC interpretation
//
// Copyright (C) 1986-1988 Level 9 Computing

#include "int.h"

void initpchuge() {
  pc = acodeptr + 7; // @MCFns
  int16_t address = pc[0];
  address += pc[1] << 8;
  pc = acodeptr + address; // data @Dummy
  hugesystemstart = pc;

  address = pc[0];
  address += pc[1] << 8;
  pc = acodeptr + address; // .Dummy
  hugesystemend = pc;

  pc = acodeptr + 5; // @AcodeFns
  address = pc[0];
  address += pc[1] << 8;
  pc = acodeptr + address; // goto @AcodeStart

  hugevbl = pc + 21; // goto @VBL

  pc += 1;
  int16_t offset = pc[0];
  offset += pc[1] << 8;
  pc += offset + 2; // .AcodeStart

  // catch code +
  pc -= 1;
  if (*pc != 0xc) pc -= 6;
}

uint8_t *doshortjump() {
  int8_t offset = *pc++;

  uint8_t *retaddr = pc;
  pc += offset;

  return retaddr;
}

uint8_t *dolongjump() {
  int16_t offset = *pc++;
  offset += *pc++ << 8;

  uint8_t *retaddr = pc; // allow wrapround (MC vectors)
  pc = acodeptr + ((pc - acodeptr + offset) & 0xffff);

  return retaddr;
}

void pcintShortGoto(uint8_t code) {
  doshortjump();
}

void pcintGosub(uint8_t code) {
  uint8_t *retaddr = dolongjump();
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

void pcintLongGoto(uint8_t code) {
  dolongjump();
  if (pc < hugesystemend) {
    systemcall();
    retins = true;
  }
}

void pcintRet(uint8_t code) {
  retins = true;
}

int16_t getpcword() {
  int16_t word = *pc++;
  word += *pc++ << 8;
  return word;
}

int16_t getpcvar() {
  return (getpcword() - PCvarsoffset) / 2;
}

int16_t getpclist() {
  return (getpcword() - PCListVector) / 4;
}

void pcintPush(int16_t var) {
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

void pcintMove(uint8_t code) {
  uint8_t *retaddr = NULL;
  int16_t var1 = getpcvar();
  code = *pc++;
  switch (code) {
    case 0x50: // push ax
      pcintPush(var1);
      break;
    case 0xa3: // mov ds:V,ax
      int16_t var2 = getpcvar();
      vartable[var2] = vartable[var1];
      break;
    case 0x01:
      code = *pc++;
      if (code == 0x06) { // add ds:V,ax
        int16_t var2 = getpcvar();
        vartable[var2] += vartable[var1];
      }
      break;
    case 0x29:
      code = *pc++;
      if (code == 0x06) { // sub ds:V,ax
        int16_t var2 = getpcvar();
        vartable[var2] -= vartable[var1];
      }
      break;
    case 0x21:
      code = *pc++;
      if (code == 0x06) { // and ds:V,ax
        int16_t var2 = getpcvar();
        vartable[var2] &= vartable[var1];
      }
      break;
    case 0x09:
      code = *pc++;
      if (code == 0x06) { // or ds:V,ax
        int16_t var2 = getpcvar();
        vartable[var2] |= vartable[var1];
      }
      break;
    case 0x31:
      code = *pc++;
      if (code == 0x06) { // xor ds:V,ax
        int16_t var2 = getpcvar();
        vartable[var2] ^= vartable[var1];
      }
      break;
    case 0x3b:
      code = *pc++;
      if (code == 0x06) { // cmp ax,ds:V
        int16_t var2 = getpcvar();
        code = *pc++;
        switch (code) {
          case 0x75: // jnz
            retaddr = doshortjump(code);
            if (vartable[var1] == vartable[var2])
              pc = retaddr;
            break;
          case 0x74: // jz
            retaddr = doshortjump(code);
            if (vartable[var1] != vartable[var2])
              pc = retaddr;
            break;
          case 0x72: // jb
            retaddr = doshortjump(code);
            if (vartable[var1] >= vartable[var2])
              pc = retaddr;
            break;
          case 0x73: // jae
            retaddr = doshortjump(code);
            if (vartable[var1] < vartable[var2])
              pc = retaddr;
            break;
          case 0x77: // ja
            retaddr = doshortjump(code);
            if (vartable[var1] <= vartable[var2])
              pc = retaddr;
            break;
          case 0x76: // jbe
            retaddr = doshortjump(code);
            if (vartable[var1] > vartable[var2])
              pc = retaddr;
            break;
          default: ilins(code);
        }
      }
      break;
    default: ilins(code);
  }
}

void pcintPop(uint8_t code) {
  code = *pc++;
  if (code == 0xa3) { // mov ds:V,ax
    popvar = getpcvar();
    popins = true;
  } else ilins(code);
}

void pcintLetVC(uint8_t code) {
  int16_t var = getpcvar();
  int16_t val = getpcword();
  vartable[var] = val;
}

void pcintSAR(uint8_t code) {
  int16_t var = getpcvar();
  vartable[var] >>= 1;
}

void pcintCompare(uint8_t code) {
  int16_t var = getpcvar();
  uint16_t val = getpcword();
  uint8_t *retaddr = NULL;
  code = *pc++;
  switch (code) {
    case 0x75: // jnz
      retaddr = doshortjump(code);
      if (vartable[var] == val)
        pc = retaddr;
      break;
    case 0x74: // jz
      retaddr = doshortjump(code);
      if (vartable[var] != val)
        pc = retaddr;
      break;
    case 0x72: // jb
      retaddr = doshortjump(code);
      if (vartable[var] >= val)
        pc = retaddr;
      break;
    case 0x73: // jae
      retaddr = doshortjump(code);
      if (vartable[var] < val)
        pc = retaddr;
      break;
    case 0x77: // ja
      retaddr = doshortjump(code);
      if (vartable[var] <= val)
        pc = retaddr;
      break;
    case 0x76: // jbe
      retaddr = doshortjump(code);
      if (vartable[var] > val)
        pc = retaddr;
      break;
    default: ilins(code);
  }
}

void pcintTable1(uint8_t code) {
  int16_t num = getpclist();
  uint16_t ins = getpcword();
  int16_t var1 = 0;
  int16_t var2 = 0;
  uint16_t index = 0xffff;

  uint8_t *table = gettable(num);
  if (!table) ilins(code);

  if (ins == 0x3e03) { // add di,ds:V1
    var1 = getpcvar();
    index = vartable[var1];
    code = *pc++;
    if (code == 0xa0) { // mov al,ds:V2
      var2 = getpcvar();
      code = *pc++;
      if (code == 0xaa) // stosb
        if (table && index < getmaxind(table))
          table[index] = vartable[var2];
    } else if (code == 0xa1) { // mov ax,ds:V2
      var2 = getpcvar();
      ins = getpcword();
      if (ins == 0xe086) { // xchg ah,al
        code = *pc++;
        if (code == 0xab) // stosw
          if (table && index < getmaxind(table))
            writetable16(table, index, vartable[var2]);
      }
    }
  }
}

void pcintTable2(uint8_t code) {
  int16_t num = getpclist();
  uint16_t ins = 0;
  int16_t var1 = 0;
  int16_t var2 = 0;
  int16_t var = 0;
  uint16_t index = 0xffff;

  uint8_t *table = gettable(num);
  if (!table) ilins(code);

  code = *pc++;
  switch (code) {
    case 0xa0: // mov al,ds:V
      var = getpcvar();
      ins = getpcword();
      if (ins == 0x8826) { // mov es:C[si],al
        code = *pc++;
        if (code == 0x84) { // short constant
          index = getpcword();
          if (table && index < getmaxind(table))
            table[index] = vartable[var];
        }
      }
      break;
    case 0x8b:
      code = *pc++;
      if (code == 0x1e) { // mov bx,ds:V1
        var1 = getpcvar();
        index = vartable[var1];
        ins = getpcword();
        if (ins == 0x8a26) {
          ins = getpcword();
          if (ins == 0x8910) {
            code = *pc++;
            if (code == 0x16) {
              var2 = getpcvar();
              if (table && index < getmaxind(table))
                vartable[var2] = table[index];
            }
          }
        }
      }
      break;
    case 0x26:
      ins = getpcword();
      if (ins == 0x948a) { // mov dl,es:C[si]
        index = getpcword();
        ins = getpcword();
        if (ins == 0x1689) { // mov ds:V,dx
          var = getpcvar();
          if (table && index < getmaxind(table))
            vartable[var] = table[index];
        }
      } else if (ins == 0x848b) { // mov ax,es:[si+C]
        index = getpcword();
        ins = getpcword();
        if (ins == 0xe086) { // mov ds:V,dx
          code = *pc++;
          if (code == 0xa3) {
            var = getpcvar();
            if (table && index < getmaxind(table))
              vartable[var] = readtable16(table, index);
          }
        }
      }
      break;
    case 0xa1:
      var = getpcvar();
      ins = getpcword();
      if (ins == 0xe086) {
        ins = getpcword();
        if (ins == 0x8926) { // mov es:C[si],ax
          code = *pc++;
          if (code == 0x84) { // short constant
            index = getpcword();
            if (table && index < getmaxind(table))
              writetable16(table, index, vartable[var]);
          }
        }
      }
      break;
    case 0x03:
      code = *pc++;
      if (code == 0x36) { // add si,ds:V1
        var1 = getpcvar();
        index = vartable[var1];
        ins = getpcword();
        if (ins == 0xad26) { // lods es:[si]
          ins = getpcword();
          if (ins == 0xe086) {
            code = *pc++;
            if (code == 0xa3) {
              var2 = getpcvar();
              if (table && index < getmaxind(table))
                vartable[var2] =  readtable16(table, index);
            }
          }
        }
      }
      break;
    default: ilins(code);
  }
}

void executepcmc(uint8_t code) {
  switch (code) {
    case 0xeb: // jmp short
      pcintShortGoto(code);
      break;
    case 0xe9: // jmp near
      pcintLongGoto(code);
      break;
    case 0xe8: // call near
      pcintGosub(code);
      break;
    case 0xc3: // ret near
      pcintRet(code);
      break;
    case 0xbb: // mov bx,offset label
    case 0xbf: // mov di,0
      pc += 2; // skip
      break;
    case 0x2e: // cs: segment override
      break;
    case 0xff: // jmp far indirect
        pc++; // skip register
        mc = false; // end of code section
      break;
    case 0xcc: // break
      breakpointaddress = pc - acodeptr;
      break;
    case 0xa1: // mov ax,ds:V
      pcintMove(code);
      break;
    case 0x58: // pop ax
      pcintPop(code);
      break;
    case 0xc7:
      code = *pc++;
      if (code == 0x06) // mov ds:V1,C1
        pcintLetVC(code);
      break;
    case 0xd1:
      code = *pc++;
      if (code == 0x3e) // sar ds:V,1
        pcintSAR(code);
      break;
    case 0x81:
      code = *pc++;
      if (code == 0x3e) // cmp ds:V,C
        pcintCompare(code);
      break;
    case 0xc4:
      code = *pc++;
      if (code == 0x3e) // les di,ds:N
        pcintTable1(code);
      else if (code == 0x36) // les ds:N
        pcintTable2(code);
      break;
    default: ilins(code);
  }
}
