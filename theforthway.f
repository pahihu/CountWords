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

\ Less-than for words (true if count is *greater* for reverse sort).
: count< ( addr1 addr2 -- )
     >r @  r> @  > ;

\ In-place merge sort taken from Rosetta Code:
\ https://rosettacode.org/wiki/Sorting_algorithms/Merge_sort#Forth
: merge-step ( right mid left -- right mid+ left+ )
    over @ over @ count< if
        over @ >r
        2dup - over dup cell+ rot move
        r> over !
        >r cell+ 2dup = if  r>drop dup  else  r>  then
    then
    cell+ ;

: merge ( right mid left -- right left )
    dup >r begin
        2dup >
    while
        merge-step
    repeat
    2drop r> ;

: mid ( l r -- mid )
    over - 2/ cell negate and + ; INLINE

: mergesort ( right left -- right left )
    2dup cell+ <= if
        exit
    then
    swap 2dup mid recurse rot recurse merge ;
 
: sort ( addr len -- )
    cells over + swap mergesort 2drop ;

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

