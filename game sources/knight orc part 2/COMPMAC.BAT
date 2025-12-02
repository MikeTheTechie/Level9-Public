echo "Batch file to compile all parts of Knight Orc for Amiga"

echo "compiling part 1. "
cd \games.l9\knight1.l9\
copy exit16.txt exit.txt
copy mconstami.txt mconst.txt
\comp
copy ami.l9\gamedata.dat \games.l9\knight2.l9\ami.l9\gamedat1.dat

echo "compiling hitech. "
cd \games.l9\knight2.l9\
copy ami.l9\hsquash.dat ami.l9\squash.dat
copy hpconst.txt pconst.txt
copy c2_16.txt c2.txt
copy exit16.txt exit.txt
\comp
copy ami.l9\gamedata.dat ami.l9\gamedat2.dat

echo "compiling magic. "
copy ami.l9\msquash.dat ami.l9\squash.dat
copy mpconst.txt pconst.txt
\comp
copy ami.l9\gamedata.dat ami.l9\gamedat3.dat
