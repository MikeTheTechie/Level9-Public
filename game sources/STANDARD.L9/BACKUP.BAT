echo "; Batch file to backup Standard Adventure"
md b:\games.l9
md b:\games.l9\standard.l9
md b:\games.l9\standard.l9\st.l9

copy \games.l9\standard.l9\*.* b:\games.l9\standard.l9\
copy \games.l9\standard.l9\st.l9\squash.dat b:\games.l9\standard.l9\st.l9\
copy \games.l9\standard.l9\st.l9\message.txt b:\games.l9\standard.l9\st.l9\
copy \games.l9\standard.l9\st.l9\picture.dat b:\games.l9\standard.l9\st.l9\
