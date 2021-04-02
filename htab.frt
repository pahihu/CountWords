ANEW -htab

   65536 CONSTANT hsize
CREATE htable hsize CELLS ALLOT
CREATE vtable hsize CELLS ALLOT
CREATE ctable hsize CELLS ALLOT
htable hsize CELLS + CONSTANT htable/

vtable htable - CONSTANT h2v
ctable htable - CONSTANT h2c

: /htable ( -- )
   htable hsize CELLS ERASE
   vtable hsize CELLS ERASE
   ctable hsize CELLS ERASE ;

: >hash ( c-addr u -- index )
   #2166136261 SWAP 0 ?DO
      >R C@+ >LWC R> XOR #16777619 *
   LOOP SWAP DROP ;

: htable[] ( i -- nod )
   [ hsize 1- ] LITERAL AND htable []CELL ;

0 VALUE the-idx

: hfind ( -- hnod' ff)
   the-idx  htable[]
   hsize FOR
      DUP @ DUP \ nod cstr cstr
      IF   \ CR ." string found: " dup count type
           the-idx =
           IF  TRUE UNLOOP EXIT  THEN
      ELSE \ CR ." empty node"
           DROP the-idx OVER !
           FALSE UNLOOP EXIT
      THEN
      CELL+
      DUP htable/ = IF DROP htable THEN
   NEXT  CR ." htable full!" ABORT ;

VARIABLE hcount

: process-word ( ca u -- )
  DLOCAL str
  \ CR ." process-word: " str TYPE
  hfind
  IF   h2v + 1 SWAP +!
  ELSE 
       DUP h2v + 1 SWAP !
       \ h2c + str DROP SWAP !
       str HERE OVER 1+ ALLOT PACK  SWAP h2c + !
       1 hcount +!
  THEN ;



: bl-skip BEGIN DUP WHILE OVER C@ BL U<= WHILE 1 /STRING REPEAT THEN ; ( addr1 n1 -- addr2 n2 ) 
\ : bl-scan BEGIN DUP WHILE OVER C@ BL U> WHILE 1 /STRING REPEAT THEN ; ( addr1 n1 -- addr2 n2 ) 

: bl-scan ( addr1 n1 -- addr2 n2 )
   0 #2166136261 LOCALS| idx ch |
   BEGIN DUP WHILE
      OVER C@ TO ch  ch BL U> WHILE
         ch >LWC idx XOR #16777619 * TO idx
         1 /STRING
      REPEAT
   THEN  idx TO the-idx ;

: PARSE-NAME2 ( c-addr u -- c-addr2 u2 c-addr1 u1 ) 
bl-skip OVER >R 
bl-scan ( end-input len r: start-input ) 
2DUP DROP R> TUCK - ; 

: process-words ( c-addr u -- ) 
BEGIN PARSE-NAME2 DUP 
WHILE process-word
REPEAT 4DROP ; 

: .words ( -- ) 
   hsize 0 DO
      I htable[]
      DUP @             \ hnod val
      IF   CR DUP h2c + @ COUNT TYPE SPACE h2v + @ .
      ELSE DROP
      THEN
   LOOP ;

: elt ( addr -- val )   @ NEGATE ;

1 CELLS NEGATE CONSTANT -CELL
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
      I vtable []CELL DUP @        \ arr offs 'val
      IF   >R 2DUP + R> SWAP ! CELL+
      ELSE DROP
      THEN
   LOOP  2DROP ;

: sort-words ( addr -- )
   hcount @ sort ;

: print-words ( addr -- )
   hcount @ 0 DO
      I OVER []CELL @ ( 'vtable[i])
      DUP vtable - ctable + @ COUNT TYPE SPACE
      @ . CR
   LOOP ;

: show-words ( -- )
   hcount @ CELLS ALLOCATE THROW
   DUP append-words
   DUP sort-words
   DUP print-words
   FREE THROW ;
   

VARIABLE my-fid

: my-slurp-file ( caddr1 u1 -- caddr2 u2)
   R/O OPEN-FILE THROW  DUP my-fid !
   MAP-FILE THROW ;

: count-biblewords ( -- ) 
/htable  0 hcount !
TIMER-RESET 
S" kjvbible_x10.txt" my-slurp-file
process-words show-words
\ .words 
.ELAPSED SPACE hcount @ DEC. ." words found"
my-fid @ CLOSE-FILE DROP ;

count-biblewords
