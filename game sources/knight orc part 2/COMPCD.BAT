echo "Batch file to compile all parts of Knight Orc for CBM Disk"

echo "compiling part 1. "
cd \games.l9\knight1.l9\
copy exit8.txt exit.txt
copy mconstcd.txt mconst.txt
\comp
copy cd.l9\gamedata.dat \games.l9\knight2.l9\cd.l9\gamedat1.dat

echo "compiling hitech. "
cd \games.l9\knight2.l9\
copy cd.l9\hsquash.dat cd.l9\squash.dat
copy hpconst.txt pconst.txt
copy c2_8.txt c2.txt
copy exit8.txt exit.txt
\comp
copy cd.l9\gamedata.dat cd.l9\gamedat2.dat

echo "compiling magic. "
copy cd.l9\msquash.dat cd.l9\squash.dat
copy mpconst.txt pconst.txt
\comp
copy cd.l9\gamedata.dat cd.l9\gamedat3.dat
