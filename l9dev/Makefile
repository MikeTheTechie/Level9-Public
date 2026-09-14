# 68000 Acode compiler, finish and squasher program (for Linux)
# common Makefile for l9comp, l9finish, l9int, l9menu and l9squash
# Copyright (C) 1986-1988 Level 9 Computing

CC=gcc
CFLAGS=-Wall

execs = l9comp l9finish l9int l9menu l9squash
scripts = l9gamegen l9tablegen l9asm2bin l9bin2tos

all: $(execs)
debug: CFLAGS+=-g
debug: clean all
nodebug: clean all
clean:
	rm -f $(execs)
install: $(execs) $(scripts)
	cp $^ /usr/local/bin

l9comp: CFLAGS+=-DEMBEDFINISH -DEMBEDINT
l9comp: comp.c code.c stcode.c pccode.c finish.c int.c stint.c pcint.c driver.c
l9comp: comp.h code.h       common.h    finish.h int.h                 driver.h
l9finish: finish.c driver.c
l9finish: finish.h driver.h common.h
l9int: int.c stint.c pcint.c driver.c
l9int: int.h                 driver.h common.h
l9menu: CFLAGS+=-DEMBEDINT
l9menu: menu.c int.c stint.c pcint.c driver.c
l9menu: menu.h int.h                 driver.h common.h
l9squash: squash.c driver.c
l9squash: squash.h driver.h common.h

$(execs):
	$(CC) $(CFLAGS) -o $@ $(filter %.c,$^)
