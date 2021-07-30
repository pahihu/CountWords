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
sbcl --load simple.lisp --eval "(sb-ext:save-lisp-and-die #p\"sbcl_simple\" :toplevel #'main :executable t :purify t)"
time ./sbcl_simple <$DATAIN >sbcl.result

echo "\nClozureCL"
ccl64 --load simple.lisp --eval "(ccl:save-application \"ccl_simple\" :toplevel-function #'main :purify t :prepend-kernel t)"
time ./ccl_simple <$DATAIN >ccl.result

echo "\nGNAT Ada"
gnatmake -O2 word_frequency
time ./word_frequency $DATAIN >ada.result

echo "\niForth"
time i6 htab.frt

echo "\nSwiftForth"
rm -f swiftforth.result
time sf htab.f

echo "\nComponent Pascal"
cpmake CountWords
time cprun CountWords < $DATAIN

echo "\nJava"
javac optimized.java
time java -cp . optimized <$DATAIN >java.result

echo "\nPython3 - P.Norwig"
time python3 norwig2.py >norwig2.result

echo "\nPython3"
time python3 opt.py <$DATAIN >python.result

echo "\nREBOL2"
time rebol -q count.r $DATAIN >rebol.result

