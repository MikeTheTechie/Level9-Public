echo "Batch file to compile part 3 of Knight Orc. "

echo "compiling magic. "
copy msx.l9\msquash.dat st.l9\squash.dat
copy mpconst.txt pconst.txt
\comp
copy msx.l9\gamedata.dat st.l9\gamedat3.dat
