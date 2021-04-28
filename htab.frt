\ iForth pahihu 3apr2021
\ original code by Marcel Hendrix
ANEW -htab

   65536 =: hsize
CREATE htable hsize    CELLS ALLOT
CREATE vtable hsize    CELLS ALLOT
CREATE ctable hsize 2* CELLS ALLOT
hsize htable []CELL =: htable/

vtable htable - =: h2v
ctable htable - =: h2c

: /htable ( -- )
   htable hsize    CELLS ERASE
   vtable hsize    CELLS ERASE
   ctable hsize 2* CELLS ERASE ;

: >hash ( c-addr u -- index )
   #2166136261 SWAP 0 ?DO
      >R C@+ >LWC R> XOR #16777619 *
   LOOP SWAP DROP ;

: htable[] ( index -- nod )
   [ hsize 1- ] LITERAL AND htable []CELL ;

0 VALUE the-idx
VARIABLE hcount

: hfind ( -- hnod' )
   the-idx  htable[]
   hsize FOR
      DUP @ DUP \ nod cstr cstr
      IF   \ CR ." string found: " dup count type
           the-idx =
           IF  UNNEXT EXIT  THEN
      ELSE \ CR ." empty node"
           DROP the-idx OVER !
           1 hcount +! UNNEXT EXIT
      THEN
      CELL+
      DUP htable/ = IF DROP htable THEN
   NEXT  CR ." htable full!" ABORT ;


: process-word ( ca u -- )
  \ DLOCAL str
  \ CR ." process-word: " str TYPE
  hfind
  DUP h2v + 1 SWAP +!
  htable - 2* ctable + 2! ;

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
      IF   CR DUP htable - 2* ctable + 2@ TYPE SPACE h2v + @ .
      ELSE DROP
      THEN
   LOOP ;

\ http://rosettacode.org/wiki/Sorting_algorithms/Quicksort#Forth
: elt ( addr -- val )   @ NEGATE ;

1 CELLS NEGATE =: -CELL
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

\ Buffered file I/O.
65536 constant /buffer
/buffer buffer: iobuf
0 value niobuf
0 value fdio

: open-bufio ( c-addr u -- )
   R/W CREATE-FILE ?FILE TO fdio ;

: flush-bufio ( -- )
   niobuf IF  iobuf niobuf fdio WRITE-FILE THROW  THEN
   0 TO niobuf ;

: write-bufio ( c-addr u -- )
   niobuf OVER + /buffer > IF  flush-bufio  THEN
   DUP >R
   niobuf iobuf + SWAP CMOVE
   R> +TO niobuf ;

: close-bufio ( -- )
   flush-bufio  fdio CLOSE-FILE THROW  0 TO fdio ;


CREATE $BL BL C,
CREATE $CCR 10 C,

: print-words ( addr -- )
   S" iforth.result" open-bufio
   hcount @ 0 DO
      DUP @ ( 'vtable[i])
      DUP vtable - 2* ctable + 2@ write-bufio
          $BL 1 write-bufio
          @ (.) write-bufio
          $CCR 1 write-bufio
      CELL+
   LOOP  DROP
   close-bufio ;

: show-words ( -- )
   hcount @ CELLS ALLOCATE THROW
   DUP append-words
   DUP sort-words
   DUP print-words
   FREE THROW ;
   

0 VALUE my-fid

: my-slurp-file ( caddr1 u1 -- caddr2 u2)
   R/O OPEN-FILE THROW  DUP TO my-fid
   MAP-FILE THROW ;

: count-biblewords ( -- ) 
   TIMER-RESET
      /htable  0 hcount !
      S" kjvbible_x10.txt" my-slurp-file
      process-words show-words
      my-fid CLOSE-FILE THROW
   CR ." ###process-words " .ELAPSED ;

count-biblewords
