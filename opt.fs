
\ Start hash table at larger size
15 :noname to hashbits hashdouble ; execute

65536 constant buf-size
create buf buf-size allot  \ Buffer for read-file
wordlist constant counts   \ Hash table of words to count
variable num-uniques  0 num-uniques !

\ Convert character to lowercase.
: to-lower ( C -- c )
    dup [char] A [ char Z 1+ ] literal within if
        32 +
    then ;

\ Convert string to lowercase in place.
: lower-in-place ( addr u -- )
    over + swap ?do
        i c@ to-lower i c!
    loop ;

\ Count given word in hash table.
: count-word ( c-addr u -- )
    2dup counts find-name-in dup if
        ( name>interpret ) >body 1 swap +! 2drop
    else
        drop nextname create 1 ,
        1 num-uniques +!
    then ;

\ Process text in the buffer.
: process-string ( -- )
    begin
        parse-name dup
    while
        count-word
    repeat
    2drop ;

\ Element access for words (for reverse sort).
: elt ( nt -- )
    name>interpret >body @ negate ;

\ Quicksort taken from Rosetta Code:
\ https://rosettacode.org/wiki/Sorting_algorithms/Quicksort#Forth
1 cells negate constant -CELL

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


\ Append word from wordlist to array at given offset.
: append-word ( addr offset nt -- addr offset+cell true )
    dup name>string lower-in-place
    >r  2dup + r> swap !
    cell+ true ;

\ Show "word count" line for each word, most frequent first.
: show-words ( -- )
    num-uniques @ cells allocate throw
    0 ['] append-word counts traverse-wordlist drop
    dup num-uniques @ sort
    num-uniques @ 0 ?do
        dup i cells + @
        dup name>string type space
        name>interpret >body @ . cr
    loop
    drop ;

\ Find last LF character in string, or return -1.
: find-eol ( addr u -- eol-offset|-1 )
    begin
        1- dup 0>=
    while
        2dup + c@ 10 = if
            nip exit
        then
    repeat
    nip ;

: main ( -- )
    counts set-current  \ Define into counts wordlist
    0 >r  \ offset after remaining bytes
    begin
        \ Read from remaining bytes till end of buffer
        buf r@ + buf-size r@ - stdin read-file throw dup
    while
        \ Process till last LF
        buf over r@ + find-eol
        dup buf swap ['] process-string execute-parsing
        \ Move leftover bytes to start of buf, update offset
        dup buf + -rot  buf -rot  - r@ +
        r> drop dup >r  move
    repeat
    drop r> drop
    show-words ;

main
bye
