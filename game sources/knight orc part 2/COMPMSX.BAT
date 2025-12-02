echo "Batch file to compile all parts of Knight Orc for the MSX. "

echo "compiling part 1. "
cd \games.l9\knight1.l9\
copy exit16.txt exit.txt
\comp
copy msx.l9\gamedata.dat \games.l9\knight2.l9\msx.l9\gamedat1.dat

echo "compiling hitech. "
cd \games.l9\knight2.l9\
copy msx.l9\hsquash.dat msx.l9\squash.dat
copy hpconst.txt pconst.txt
copy exit16.txt exit.txt
\comp
copy msx.l9\gamedata.dat msx.l9\gamedat2.dat

echo "compiling magic. "
copy msx.l9\msquash.dat msx.l9\squash.dat
copy mpconst.txt pconst.txt
\comp
copy msx.l9\gamedata.dat msx.l9\gamedat3.dat
