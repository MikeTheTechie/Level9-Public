echo "Batch file to compile all parts of Knight Orc for CBM Tape"

echo "compiling part 1. "
cd \games.l9\knight1.l9\
copy exit8.txt exit.txt
copy mconstcc.txt mconst.txt
\comp
copy cbmcass.l9\gamedata.dat \games.l9\knight2.l9\cbmcass.l9\gamedat1.dat

echo "compiling hitech. "
cd \games.l9\knight2.l9\
copy cbmcass.l9\hsquash.dat cbmcass.l9\squash.dat
copy hpconst.txt pconst.txt
copy c2_8.txt c2.txt
copy exit8.txt exit.txt
\comp
copy cbmcass.l9\gamedata.dat cbmcass.l9\gamedat2.dat

echo "compiling magic. "
copy cbmcass.l9\msquash.dat cbmcass.l9\squash.dat
copy mpconst.txt pconst.txt
\comp
copy cbmcass.l9\gamedata.dat cbmcass.l9\gamedat3.dat
