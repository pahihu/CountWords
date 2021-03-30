#!/bin/sh
if [ ! -s kjvbible_x10.txt ];
then
  cat kjvbible.txt kjvbible.txt > kjvbible_x2.txt
  cat kjvbible_x2.txt kjvbible_x2.txt > kjvbible_x4.txt
  cat kjvbible_x4.txt kjvbible_x4.txt > kjvbible_x8.txt
  cat kjvbible_x8.txt kjvbible_x2.txt > kjvbible_x10.txt
fi

DATAIN=kjvbible_x10.txt
rm -f *.result

echo "\nmawk"
time mawk -f simple.awk $DATAIN > awk.result

# FSF GNAT 10.1.0
gcc -O2 -o c_opt opt.c
echo "\nC"
time cat $DATAIN | ./c_opt > c.result

gcc -O2 -o c_simple simple.c
echo "\nC - simple"
time cat $DATAIN | ./c_simple > c_simple.result

# clang -std=c++14 -O2 -o cpp_opt opt.cpp -lstdc++
g++ -std=c++17 -O2 -o cpp_opt opt.cpp -lstdc++
echo "\nC++"
time cat $DATAIN | ./cpp_opt > cpp.result

# clang -std=c++14 -O2 -o cpp_simple simple.cpp -lstdc++
g++ -std=c++17 -O2 -o cpp_simple simple.cpp -lstdc++
echo "\nC++ - simple"
time cat $DATAIN | ./cpp_simple > cpp_simple.result

echo "\nK"
time k count.k -- $DATAIN > k.result

echo "\nForth"
time cat $DATAIN | gforth-fast opt.fs > forth.result

echo "\nForth - simple"
time cat $DATAIN | gforth-fast simple.fs > forth_simple.result

echo "\nShell"
time tr 'A-Z' 'a-z' <$DATAIN | tr -s ' ' '\n' | LC_ALL=C sort -S 2G | uniq -c | sort -rn> shell.result

echo "\npicoLisp"
time pil count.l - $DATAIN > picoLisp.result

echo "\nSBCL"
sbcl --load simple.lisp --eval "(sb-ext:save-lisp-and-die #p\"lisp_simple\" :toplevel #'main :executable t :purify t)"
time ./lisp_simple <$DATAIN >lisp.result

echo "\nGNAT Ada"
gnatmake -O2 word_frequency
time ./word_frequency $DATAIN >ada.result

