echo "Batch file to compile all parts of Knight Orc for Spectrun48 Disk. "

echo "compiling part 1. "
cd \games.l9\knight1.l9\
copy exit8.txt exit.txt
copy mconsts4.txt mconst.txt
\comp
copy spec48.l9\gamedata.dat \games.l9\knight2.l9\spec48.l9\gamedat1.dat

echo "compiling hitech. "
cd \games.l9\knight2.l9\
copy spec48.l9\hsquash.dat spec48.l9\squash.dat
copy hpconst.txt pconst.txt
copy c2_8.txt c2.txt
copy exit8.txt exit.txt
\comp
copy spec48.l9\gamedata.dat spec48.l9\gamedat2.dat

echo "compiling magic. "
copy spec48.l9\msquash.dat spec48.l9\squash.dat
copy mpconst.txt pconst.txt
\comp
copy spec48.l9\gamedata.dat spec48.l9\gamedat3.dat
