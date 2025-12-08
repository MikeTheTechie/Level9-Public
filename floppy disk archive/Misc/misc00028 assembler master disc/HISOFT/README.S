This contains information to supplement that in the manual.

This is DevpacST Version 2.08

The HiSoft File Selector can be found in the FSEL folder. The .TXT file
contains its documentation.

Assembler 2.08
==============
The new directives TEXT, DATA and BSS are supported for increased
compatibility. They are the same as specifying SECTION xxx.
IMPORTANT: The DCB directive (page 52) now works as described. Previously
the order of the parameters were reversed, so existing code which relied
on the bug will no longer work. Similarly the optimising numbers in the
OPT O directive (page 48) are now implemented as described. Previously
you had to use one less than the documented numbers.
The LIST + and - directives (page 53) now work exactly as described.
Incorrect divide-by-zero errors on pass 1 no longer occur.
The destination of a MOVE is not allowed to be (PC) relative.
Register equates are allowed in ADDX/SUBX/ABCD/SBCD.
It was possible to crash the editor if a block was deleted and the
cursor was within the block.
The .TTP version now returns a GEMDOS return code to indicate the success
or otherwise of the assembly. Values are:
	100	main file not found
	20	fatal error
	10	error(s)
	5	warning(s)
	0	OK
The AESLIB.S file has been updated.

Debugger 2.02
=============
The Follow Traps option works on Line A op-codes.
Disassembling with Long-sized data areas works.
The Effective Address display in the register window correctly shows memory
around the stack when in supervisor mode.

Assembler 2.07
==============
A problem with GST sections has been corrected. The editor Delete File
function has been fixed (it was broken in 2.06 only).

Assembler 2.06
==============
The following bugs have been fixed:
type checks on PC-relative with index; FORMAT; IFND/IFD with SET labels.

In addition a new form of local label is supported, denoted with decimal
digits ending with a $ sign, e.g. 1234$. This is to improve compatibility.
The AESLIB.S file has been updated.

Assembler 2.04
==============
The following bugs have been fixed:
GEMDOS MALLOC problem; the optimiser being memory hungry; assembling DRI
code to no-where; low-memory GST output; mixing macros and repeat loops;
INCBIN and odd-length files; INCBIN and ORG together.

INCBIN is now forced to start on an even boundary and is padded with a null
byte if the file is odd in length.

Editor 2.02
===========
There is a new option under Preferences, called End of Line. When
Wrap is selected the cursor behaves differently when you  or  past
the ends of a line. Try it and see if you like it.

Assembler 2.02
==============
There is a new option, OPT A+, which enables automatic-PC mode where
possible. For example the line MOVE.L int_in,d0 would get assembled
as MOVE.L int_in(pc),d0. Note that this does not guarantee position-
independent code, but does reduce program size and execution times.
It is used in the GEMTEST program to good effect. This may have to
be overidden (when reading absolute memory for example) and this may be
done by using the (expression).L form, similar to that detailed on page 
43 for short word addressing.

There is a new option determining the speed of the assembler, available
in the assembly options dialog box. Under normal circumstances leave the
Fast button selected, but only if the assembler runs out of memory should
you select Slow. This forces the assembler to use as little memory as
possible which slows down disk accesses. It can slow down to a little
faster than GenST Version 1 (which isn't actually that slow!). The .TTP
version may be set to slow mode using the command line option -M.

The assembler can now generate code suitable for linking with OSS Personal
Pascal (Pascal Plus in Germany). For further details please quote your
DevpacST and, if a UK customer, your Pascal serial numbers.

Bugs fixed include the ORG, CNOP, ENDC and REPT directives.

Debugger 2.01
=============
The debugger can now save its Preferences in a MONST2.INF file.

There is a new command, Ctrl-S, that skips the current instruction.
It is equivalent to setting the PC to be x words further on, ideal
for not executing instructions you know are going to produce nasty
results.

The machine may be reset by pressing the combination
Ctrl-Alt-NumericDot when in the debugger. No warning is given.

Linker 2.01
===========
A bug to do with large library files has been corrected.

Source Files 2.01
==================
The GEMTEST, AESLIB, VDILIB and GEMMACRO files have been updated.

Editor 2.00
===========
Not a new feature at all really, we've just never documented it before.
To search and/or replace Tab characters press Ctrl-I in the dialog box
They will be echoed as clock face characters. Ctrl-M must *not* be used
as a substitute for CR. Strange characters, like   and  may be
entered by typing a special character, say ?, then using 
the Find dialog box to replace it with the required Ctrl- characters.

When using Run Other to run a program you may pass the name of the file
you are currently editing by including a % in the command line, which
will be expanded. A true % may be specified using %%

Assembler 2.00
==============
The default for option M, macro expansions, is OPT M-.

The directive OPT U+ changes local labels start with underlines (_) instead
of periods, to allow code to be generated for the Prospero range of
languages.

In the .TTP version the tab size used when listing may be specified using
the option -Txx, for example -T10.

Debugger 2.00
=============
The command Ctrl-E forces all exceptions to be re-installed. This can be
useful when dealing with compiled programs whose run-times use the
exceptions themselves.

If you enter AMONST2 during the boot sequence you may abort its
installation by quitting with Ctrl-R instead of Ctrl-C.

Please note decimal numbers are now denoted with \, not # as in version 1.

Linker 2.00
===========
An additional directive is allowed in control files:
TRUNCATE
This truncates all symbols to 8 characters, sometimes required to link
assembly language with long labels to compiled code with short labels.

Lattice C Users
===============
Now supplied is a replacement C.LNK file for use with Lattice C 3.04.
Using it with LINKST will reduce your link times and also reduce your
output file size by using a true BSS-type section.
If you use the -n option of the compiler (page 132) you will be able
to specify HiSoft Extended Debug when linking, allowing longer and more
meaningful symbols when debugging with MonST2.

Manual Corrections
==================
Page 65, the macro expansion at the bottom of the page should show the
binary number as %0110.
Page 156, addr_out consists of longwords, not words.
Page 158, the parameter list to evnt_multi has two missing:

                             
evnt_multi flags,clicks,mask,bstate,m1flags,m1x,m1y,m1w,m1h,
                             
                                
&	m2flags,m2x,m2y,m2w,m2h,messagebuf.L,count.L
                                
Page 94, under Lock Window it should read 'disassembly and memory
windows'
Page 161, under fsel_input, should read 'If D0.W is *zero* on return
then it means'
Page 164, Clear Workstation is v_clrwk, not v_clrwrk

Developer Version
=================
Please note that the Developer version described on Page 180 is not
yet available. If you are interested in it please write to us and your
details will be put on file, you will be then contacted when it is
available.

Last changed: 2nd October 1988
