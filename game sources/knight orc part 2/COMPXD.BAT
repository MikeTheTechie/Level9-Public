echo "Batch file to compile all parts of Knight Orc for Atari Disk"
echo "The text is identical to that used by CBM disk"
echo "compiling part 1. "
cd \games.l9\knight1.l9\
copy exit8.txt exit.txt
copy mconstxd.txt mconst.txt
\comp
copy xd.l9\gamedata.dat \games.l9\knight2.l9\xd.l9\gamedat1.dat

echo "compiling hitech. "
cd \games.l9\knight2.l9\
copy xd.l9\hsquash.dat xd.l9\squash.dat
copy hpconst.txt pconst.txt
copy c2_8.txt c2.txt
copy exit8.txt exit.txt
\comp
copy xd.l9\gamedata.dat xd.l9\gamedat2.dat

echo "compiling magic. "
copy xd.l9\msquash.dat xd.l9\squash.dat
copy mpconst.txt pconst.txt
\comp
copy xd.l9\gamedata.dat xd.l9\gamedat3.dat
