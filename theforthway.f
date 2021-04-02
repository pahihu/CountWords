\ The FORTH Way
\ Code from Marcel Hendrix' countingwords.frt and Anton Ertl's opt.fs
\ SwiftForth
\ pahihu 1apr2021
\
[DEFINED] -theforthway [IF] -theforthway [THEN]
MARKER -theforthway
DECIMAL

INCLUDE inline.f
32768 CONSTANT hsize

0 VALUE bodies
VARIABLE hcount
0 VALUE WC

: /init ( -- )
   -?                   \ turn-off redefinition warnings
   hsize STRANDS TO WC  \ wordlist w/ 64K strands
   0 hcount !
   hsize CELLS ALLOCATE THROW TO bodies ;

: process-word ( ca u -- )
   2DUP WC SEARCH-WORDLIST
   IF   >BODY 1 SWAP +!  2DROP
   ELSE WC (WID-CREATE)
        HERE hcount @ CELLS bodies + !  \ save BODY
        1 ,
        1 hcount +!
   THEN ;

: bl-skip ( addr1 n1 -- addr2 n2 ) 
   BEGIN DUP WHILE OVER C@ BL <= WHILE 1 /STRING REPEAT THEN ;
: bl-scan ( addr1 n1 -- addr2 n2 ) 
   BEGIN DUP WHILE OVER C@ BL > WHILE 1 /STRING REPEAT THEN ;

: PARSE-NAME2 ( c-addr u -- c-addr2 u2 c-addr1 u1 ) 
   bl-skip OVER >R 
   bl-scan ( end-input len r: start-input ) 
   2DUP DROP R> TUCK - ;

: process-words ( c-addr u -- ) 
   BEGIN PARSE-NAME2 DUP 
   WHILE process-word
   REPEAT 4DROP ; 

: .entry ( nt -- flag )
   DUP CR .ID SPACE NAME> >BODY @ .
   TRUE ;

: .words ( -- ) 
   ['] .entry WC TRAVERSE-WORDLIST ;

  0 VALUE  my-fid
0 0 2VALUE mapaddr

: my-slurp-file ( caddr1 u1 -- caddr2 u2)
   R/O OPEN-FILE THROW  DUP TO my-fid
   MAP-FILE THROW 2DUP  TO mapaddr ;

: finish/ ( -- )
   /WARNING     \ restore redefinition warnings
   bodies  FREE       THROW
   mapaddr UNMAP-FILE THROW
   my-fid  CLOSE-FILE THROW ;

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
      2DUP <= IF  2DUP exch >R CELL+ R> CELL- THEN
   2DUP > UNTIL  R> DROP ;

: qsort ( l r -- )
   partition SWAP ROT
   2DUP < IF  RECURSE  ELSE  2DROP  THEN
   2DUP < IF  RECURSE  ELSE  2DROP  THEN ;

: sort ( array len -- )
   DUP 2 < IF  2DROP EXIT  THEN
   1- CELLS OVER + qsort ;

VARIABLE t0
: TIMER-RESET   COUNTER t0 ! ;
: .ELAPSED   COUNTER t0 @ - u. ;

\ Show "word count" line for each word, most frequent first.
: show-words ( -- )
    bodies dup hcount @ sort
    hcount @ 0 ?do
        dup i cells + @
        ( addr) DUP
        BODY> ( xt) >NAME ( nfa)
        name>string type space
        @ . cr
    loop
    drop ;

: count-biblewords ( -- ) 
   /init
   S" kjvbible_x10.txt" my-slurp-file
   process-words show-words
   finish/ ;

count-biblewords
bye

