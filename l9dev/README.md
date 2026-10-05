# l9dev
Level 9 dev tools recoded in C from Atari ST 68000 assembler

Installation
============
- make
- sudo make install

Game Generation
===============
Usage: l9gamegen [options]

Options:
```
--help: this usage message
--old: for strict binary compatibility with older games
--no-table: do not assemble table.txt into table.dat
--no-message: do not squash message.txt into squash.dat
--bugcomp: enable bugwards compatibility (e.g. for conditional compilation)
--oddacode: do not align acode in gamedata.dat
--i8086: generate MC code for PC
--splitdata: generate split acode and gamedata
```

- overall game generation script
- calls various components as described below

Compiler
========
Usage: l9comp [options]

Options:
```
--help: print this usage message
--bugcomp: enable bugwards compatibility (e.g. for conditional compilation)
--oddacode: do not align acode in gamedata.dat
--testcomp: limit sizes to test overflow errors
--i8086: generate MC code for i8086
--splitdata: generate split acode and gamedata
```

Usage: l9finish [options]

Options:
```
--help: print this usage message
--oddacode: do not align acode in gamedata.dat
--splitdata: generate split acode and gamedata
```

- as before finish is the standalone finisher also incorporated in comp
- it can be used once the acode.acd is compiled to generate gamedata.dat for various platforms
- both stay close to the original with certain minor improvements and changes due to compiling on Linux
- the order of things has not been changed or split up drastically, hence the need for forward declarations in header files
- effort has been put into making error handling robust (see also regression)
- still some things will cause trouble (e.g. truncated statements, especially prs, but also game data overflow)
- as before, the compiler is driven by a menu or compile.bat file, but two cmdline options can be provided for backward compatibility
- menu option A (printer) can be used to append output to compile.log
- menu option 5 (run game) is also implemented (see below with 'Interpreter')
- menu option 6 (debugging) can be used to precede option 5 to start the interpreter in debug mode
- menu option 7 (long jumps) can be used to precede option 5 to start the interpreter in autorun mode
- all files and directories should be lower case but can have any line terminations (combinations of CR/LF)
- the finish executable can be compiled separately
- simply invoke make to compile for your Linux system (Ubuntu 24.04 executables are provided)
- some version 1.5 features have been integrated (mostly based on observed behaviour)
- this was needed to support games which split acode from gamedata (menu option B)
- this also makes it possible to compile the acode and gamedata of the unpublished last games
- Grange Murders and Billy the Kid acode and gamedata can be compiled in this way (--splitdata)
- MC is modularized so that in principle it should be possible to add another architecture

Squasher
========
Usage: l9squash [options]

Options:
```
--help: print this usage message
--oldgame: squash for old games e.g. Adrian Mole/Archers
--noisy: enable noisy messages
--debug: enable debug messages
```

- stays close to the original but streamlined to remove the Z80/M86k boilerplate
- again the need for forward declarations in header files
- code for driver and common declarations is shared with the compiler
- extra comments have been added to document some squasher behaviour
- all files and directories should be lower case but can have any line terminations (combinations of CR/LF)
- simply invoke make to compile for your Linux system (Ubuntu 24.04 executables are provided)

Interpreter
===========
Usage: ./l9int [options]

Options:
```
--help: print this usage message
--autorun: run log.bat
--demo: run log.bat in a loop
--debug: start in debug step mode
--splitdata: use split acode and gamedata
  <gamedatafilename>: alternative name for 'gamedat1.dat'
```
Only with --splitdata:
```
  <acodefilename>: alternative name for 'acod1.dat'
```
Only with --autorun:
```
  <logfilename>: alternative name for 'log.bat'
```

- standalone interpreter version of the integrated variants (l9comp and l9menu)
- currently it only supports v3-4 games (messaging and input missing for v1-2)
- ST and PC MC interpretation is supported (should be fast enough)
- no graphics support (line, bitmap, sprites)
- care has been taken to make it stable
- thanks to the invaluable work of the GS/DK interpreter for verification
- and thanks to Google's address sanitizer ('gcc -fsanitize=address')
- textonly version of HUGE games is supported (Grange Murders tested)
- the game is playable: use space for menu actions and keypad numbers for directions (8, 6, 2, 4)
- advanced directions: up2, right2, down2, left2 with next clockwise key (9, 3, 1, 7)
- additional directions: climb stairs, descend stairs (+, -)
- extra keys: (F, f) for Fast mode, (Q, q, ctrl-q) for quit

Game chooser menu
=================
Usage: ./l9menu [options]

Options:
```
--help: print this usage message
```

- has the interpreter integrated
- normally used on a packaged disk to select a from a list
- after selection the game is ran through the interpreter

Script: l9tablegen
==================
Usage: l9tablegen [options] [<table>]

Options:
```
--help: this usage message
--bin: use a binary table.bin as input iso table.txt
--old: for strict binary compatibility with older games
```

- generates table.dat from table.txt (or table.bin)
- older games (upto Knight Orc) need a slightly different result
- hence the --old option above
- if a binary table.bin is generated by other means, --bin can be used
- with extra argument <table>.dat can be generated (e.g. for HUGE games)
- calls components below
- uses binutils-m68k-linux-gnu
- the assembler is not perfect:
  - ORG directive is not supported
  - case insensitive lables are not allowed
  - spaces after comma's are not allowed
  - the rep statement wants the repeated instructions word-aligned
  - this last one only occurs once - don't use it for new work
  - for all these limitations a workaround is in place

Script: l9asm2bin
=================
Usage: l9asm2bin [options] <name>

Options:
```
--help: this usage message
```

- tablegen generates a table.s which can be assembled by l9asm2bin
- basically comes down to:
  - m68k-linux-gnu-as -M -o <name>.o <name>.s
  - m68k-linux-gnu-objcopy -O binary <name>.o <name>.bin

Script: l9bin2tos
=================
Usage: l9bin2tos [options] <name>

```
Options:
--help: this usage message
--old: for strict binary compatibility with older games
```

- use the table.bin output from l9asm2bin
- generates Atari exec header and footer around the binary
- which results in <name>.prg
- tablegen finally renames this result to table.dat

Regression
==========
regress/compileall
- should give no reports of differences with the reference (and no git diffs)
- generates table.dat for all salvaged v3/v4 games to date (no v2 games available yet to test)
- squashes all salvaged v3/v4 games to date (no v2 games available yet to test)
- compiles all salvaged v3/v4 games to date (no v2 games available yet to test)
- have a look at the script to see which games need which compiler options
- some input files are missing:
  - most of Jewels of Darkness' Dungeon Adventure and Adventure Quest (not included here)
  - table.txt for The Price of Magik
  - exit.txt and table.txt/dat for Lancelot part 2 (compiles without those)
  - message.txt for Colossal Adventure (not needed for compilation as squash.dat is used as provided)
  - message.txt for Snowball (not needed for compilation as squash.dat is used as provided)
  - message.txt for Return to Eden (not needed for compilation as squash.dat is used as provided)
  - Gnome Ranger is badly corrupted (not included here)
- the naming of the platform subdirs is not accurate, as some patchwork went into selecting uncorrupted files

regress/compileerrors
- should give no report of differences with the reference (and no git diff)
- compiles a modified test.txt as errors.txt which triggers all compiler errors
- for this to succeed for all errors (e.g. including overflow errors) the --testcomp option is used
- is called from compileall

regress/runall
- should give no report of differences with the reference (and no git diff)
- runs all games through the interpreter with a log.bat script
- scripts and command framework based upon work of the GS/DK interpreter

TODO
====
- further conversion of HUGE (for animated adventure games: graphics and editor)
- support for graphics (line-drawn pictures, hires bitmaps and sprites)
- subject to sources being salvaged:
  - support for v2 games (mainly message compression and input processing)
  - support for packaging (including loaders and interpreters for various platforms)
