echo "Batch file to compile all parts of Knight Orc for the Spectrum 128. "

echo "compiling part 1. "
cd \games.l9\knight1.l9\
copy mconsts128.txt mconst.txt
copy exit8.txt exit.txt
\comp
copy s128.l9\gamedata.dat \games.l9\knight2.l9\s128.l9\gamedat1.dat
copy acode.acd \games.l9\knight2.l9\s128.l9\acode1.acd
copy acode.sml acode.acd
cd \games.l9\knight1.l9\
\finish
copy s128.l9\gamedata.dat \games.l9\knight2.l9\s128.l9\smallgd1.dat

echo "compiling hitech. "
cd \games.l9\knight2.l9\
copy s128.l9\hsquash.dat s128.l9\squash.dat
copy hpconst.txt pconst.txt
copy exit16.txt exit.txt
\comp
copy s128.l9\gamedata.dat s128.l9\biggd2.dat
copy acode.acd s128.l9\acode2.acd
copy acode.sml acode.acd
cd \games.l9\knight2.l9\
\finish
copy s128.l9\gamedata.dat s128.l9\smallgd2.dat
copy s128.l9\biggd2.dat s128.l9\gamedat2.dat

echo "compiling magic. "
copy s128.l9\msquash.dat s128.l9\squash.dat
copy mpconst.txt pconst.txt
\comp
copy s128.l9\gamedata.dat s128.l9\biggd3.dat
copy acode.acd s128.l9\acode3.acd
copy acode.sml acode.acd
cd \games.l9\knight2.l9\
\finish
copy s128.l9\gamedata.dat s128.l9\smallgd3.dat
copy s128.l9\biggd3.dat s128.l9\gamedat3.dat

era s128.l9\biggd2.dat
era s128.l9\biggd3.dat
