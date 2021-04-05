\ SwiftForth pahihu 3apr2021
\ original code by Marcel Hendrix
[DEFINED] -htab [IF] -htab [THEN]
MARKER -htab

REQUIRES filebuf.f

   65536 CONSTANT hsize
CREATE htable hsize    CELLS ALLOT
CREATE vtable hsize    CELLS ALLOT
CREATE ctable hsize 2* CELLS ALLOT
htable hsize CELLS + CONSTANT htable/

vtable htable - CONSTANT h2v
ctable htable - CONSTANT h2c

: /htable ( -- )
   htable hsize    CELLS ERASE
   vtable hsize    CELLS ERASE
   ctable hsize 2* CELLS ERASE ;

: >hash ( c-addr u -- index )
   #2166136261 SWAP 0 ?DO
      >R COUNT UPPER R> XOR #16777619 *
   LOOP SWAP DROP ;

: htable[] ( i -- nod )
   [ hsize 1- ] LITERAL AND CELLS htable + ;

0 VALUE -the-idx

: hfind ( ca u -- hnod' ff)
   >hash
   DUP [ hsize 1- ] LITERAL AND CELLS htable +
   SWAP
   hsize 0 DO
      >R
      DUP @ DUP \ nod cstr cstr
      IF   \ CR ." string found: " dup count type
           R@ =
           IF  R>DROP TRUE UNLOOP EXIT  THEN
      ELSE \ CR ." empty node"
           DROP R> OVER !
           FALSE UNLOOP EXIT
      THEN
      CELL+
      DUP htable/ = IF DROP htable THEN
      R>
   LOOP  CR ." htable full!" ABORT ;

VARIABLE hcount

: process-word ( ca u -- )
  \ CR ." process-word: " 2DUP TYPE
  2DUP hfind
  IF   h2v + 1 SWAP +! 2DROP EXIT  THEN
  DUP h2v + 1 SWAP ! ( ca u nod)
  htable - 2* ctable + 2!
  1 hcount +! ;


: bl-skip ( addr1 n1 -- addr2 n2 ) BEGIN DUP WHILE OVER C@ BL <= WHILE 1 /STRING REPEAT THEN ;
: bl-scan ( addr1 n1 -- addr2 n2 ) BEGIN DUP WHILE OVER C@ BL U> WHILE 1 /STRING REPEAT THEN ;

: PARSE-NAME2 ( c-addr u -- c-addr2 u2 c-addr1 u1 ) 
\ bl-skip 
BEGIN DUP WHILE OVER C@ BL <= WHILE 1 /STRING REPEAT THEN
OVER >R 
\ bl-scan
BEGIN DUP WHILE OVER C@ BL U> WHILE 1 /STRING REPEAT THEN
( end-input len r: start-input ) 
2DUP DROP R> TUCK - ; 

: process-words ( c-addr u -- ) 
BEGIN PARSE-NAME2 DUP 
WHILE 
\ process-word
  2DUP hfind
  IF   h2v + 1 SWAP +! 2DROP
  ELSE DUP h2v + 1 SWAP ! ( ca u nod)
       htable - 2* ctable + 2!
       1 hcount +!
  THEN
REPEAT 4DROP ; 

: .words ( -- ) 
   hsize 0 DO
      I htable[]
      DUP @             \ hnod val
      IF   CR DUP htable - 2* ctable + 2@ TYPE SPACE h2v + @ .
      ELSE DROP
      THEN
   LOOP ;

\ http://rosettacode.org/wiki/Sorting_algorithms/Quicksort#Forth
: elt ( addr -- val )   @ NEGATE ;

: mid ( l r -- mid )
   OVER - 2/ -CELL AND + ;

: exch ( addr1 addr2 -- )
   DUP @ >R OVER @ SWAP ! R> SWAP ! ;

: partition ( l r -- l r r2 l2 )
   2DUP mid @ elt >R ( r: pivot )
   2DUP BEGIN
      SWAP BEGIN DUP @ elt       R@     < WHILE CELL+ REPEAT
      SWAP BEGIN     R@     OVER @  elt < WHILE CELL- REPEAT
      2DUP <= IF  2DUP EXCH >R CELL+ R> CELL- THEN
   2DUP > UNTIL  R> DROP ;

: qsort ( l r -- )
   partition SWAP ROT
   2DUP < IF  RECURSE  ELSE  2DROP  THEN
   2DUP < IF  RECURSE  ELSE  2DROP  THEN ;

: sort ( array len -- )
   DUP 2 < IF  2DROP EXIT  THEN
   1- CELLS OVER + qsort ;


: append-words ( addr -- )
   0
   hsize 0 DO
      I CELLS vtable + DUP @    \ arr offs 'val
      IF   >R 2DUP + R> SWAP ! CELL+
      ELSE DROP
      THEN
   LOOP  2DROP ;

: sort-words ( addr -- )
   hcount @ sort ;

BUFFERED-FILE-OUTPUT BUILDS FOUT
FOUT CONSTRUCT

CREATE $BL 32 C,
CREATE $CR 10 C,

: print-words ( addr -- )
   S" swiftforth.result" FOUT OPEN
   hcount @ 0 DO
      DUP @ ( 'vtable[i])
      DUP vtable - 2* ctable + 2@ FOUT WRITE
          $BL 1 FOUT WRITE
          @ DUP 0< (D.) FOUT WRITE
          $CR 1 FOUT WRITE
      CELL+
   LOOP  DROP
   FOUT CLOSE ;

VARIABLE t0
: TIMER-RESET   COUNTER t0 ! ;
: .ELAPSED   COUNTER t0 @ - U. ;

: show-words ( -- )
   hcount @ CELLS ALLOCATE THROW
   \ TIMER-RESET
   DUP append-words \ CR ." ###append-words " .ELAPSED
   \ TIMER-RESET
   DUP sort-words   \ CR ." ###sort-words " .ELAPSED
   \ TIMER-RESET
   DUP print-words  \ CR ." ###print-words " .ELAPSED
   FREE THROW ;
   

0   VALUE my-fid
0. 2VALUE mapaddr

: my-slurp-file ( caddr1 u1 -- caddr2 u2)
   R/O OPEN-FILE THROW  DUP TO my-fid
        MAP-FILE THROW 2DUP TO mapaddr ;

: count-biblewords ( -- ) 
   TIMER-RESET 
      /htable  0 hcount !
      S" kjvbible_x10.txt" my-slurp-file
      process-words 
      show-words
      \ .words 
      mapaddr UNMAP-FILE THROW
      my-fid CLOSE-FILE THROW
   CR ." ###process-words " .ELAPSED ;

count-biblewords
bye
