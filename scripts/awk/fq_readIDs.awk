{if(NR%4==1) split($0,a," "); sub("@", "", a[1]); print a[1]}