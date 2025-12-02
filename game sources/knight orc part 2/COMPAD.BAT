echo "Batch file to compile all parts of Knight Orc for the Amstrad. "
echo "*********** Check MCONSTAD - need to compile p1 separately"

echo "compiling part 1. "
cd \games.l9\knight1.l9\
copy mconstad.txt mconst.txt
copy exit8.txt exit.txt
\comp
copy ad.l9\gamedata.dat \games.l9\knight2.l9\ad.l9\gamedat1.dat
copy acode.acd \games.l9\knight2.l9\ad.l9\acode1.acd
copy acode.sml acode.acd
cd \games.l9\knight1.l9\
\finish
copy ad.l9\gamedata.dat \games.l9\knight2.l9\ad.l9\smallgd1.dat

echo "compiling hitech. "
cd \games.l9\knight2.l9\
copy ad.l9\hsquash.dat ad.l9\squash.dat
copy hpconst.txt pconst.txt
copy exit16.txt exit.txt
\comp
copy ad.l9\gamedata.dat ad.l9\biggd2.dat
copy acode.acd ad.l9\acode2.acd
copy acode.sml acode.acd
cd \games.l9\knight2.l9\
\finish
copy ad.l9\gamedata.dat ad.l9\smallgd2.dat
copy ad.l9\biggd2.dat ad.l9\gamedat2.dat

echo "compiling magic. "
copy ad.l9\msquash.dat ad.l9\squash.dat
copy mpconst.txt pconst.txt
\comp
copy ad.l9\gamedata.dat ad.l9\biggd3.dat
copy acode.acd ad.l9\acode3.acd
copy acode.sml acode.acd
cd \games.l9\knight2.l9\
\finish
copy ad.l9\gamedata.dat ad.l9\smallgd3.dat
copy ad.l9\biggd3.dat ad.l9\gamedat3.dat

era ad.l9\biggd2.dat
era ad.l9\biggd3.dat
