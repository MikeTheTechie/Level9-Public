echo "Batch file to compile all parts of Knight Orc for st/ibm"

echo "compiling part 1. "
cd \games.l9\knight1.l9\
copy mconst16.txt mconst.txt
copy exit16.txt exit.txt
\comp
copy st.l9\gamedata.dat \games.l9\knight2.l9\st.l9\gamedat1.dat

echo "compiling hitech. "
cd \games.l9\knight2.l9\
copy st.l9\hsquash.dat st.l9\squash.dat
copy hpconst.txt pconst.txt
copy c2_16.txt c2.txt
copy exit16.txt exit.txt
\comp
copy st.l9\gamedata.dat st.l9\gamedat2.dat

echo "compiling magic. "
copy st.l9\msquash.dat st.l9\squash.dat
copy mpconst.txt pconst.txt
\comp
copy st.l9\gamedata.dat st.l9\gamedat3.dat
