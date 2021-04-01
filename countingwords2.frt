\ Marcel Hendrix 29mar2021
\ iForth6
\ pahihu 30mar2021
\    file mapped to memory
\    64K hash size
\    FNV1 hash
\    bl-scan calculates index
\    don't ALLOT space for words
\    ~ 430ms
\
ANEW -countingwords2

2 CELLS =: DATASZ 

#65536 =: hsize ( -- maxsize ) -- a power of two
0 VALUE hcount ( -- actsize ) 
CREATE htable PRIVATE hsize CELLS ALLOT 
htable hsize CELLS ERASE 

: .key ; PRIVATE ( node -- 'addr ) 
: .next CELL+ ; PRIVATE ( node -- 'addr ) 
: .addr 2 CELL[] ; PRIVATE ( node -- addr ) 
: .count 3 CELL[] ; PRIVATE ( node -- addr ) 

: hashcode ( index -- u ) [ hsize 1- ] LITERAL AND ; PRIVATE
: >index ( c-addr u -- index ) \ FNV1 hash
   #2166136261 SWAP 0 ?DO
      >R C@+ >LWC R> XOR #16777619 *
   LOOP SWAP DROP ; PRIVATE

0 VALUE the-index
: addnode ( c-addr u -- node ) 
DROP LOCAL str
the-index
ALIGN 
HERE 2 CELLS DATASZ + ALLOT LOCAL node 
hcount hsize >= IF CR ." addnode :: too many objects, maximum = " hsize DEC. ABORT 
ELSE 1 +TO hcount 
ENDIF 
node .key ! 
node .next OFF 
node .addr str SWAP ! 
node .count 1 SWAP ! 
node ; PRIVATE 

: hfind ( c-addr u -- node ) 
DLOCAL str 
the-index
DUP hashcode 0 0 LOCALS| node prev hash_code index | 
htable hash_code CELL[] @ TO node 
BEGIN node 
WHILE node .key @ index = IF 1 node .count +! node EXIT ENDIF 
node TO prev 
node .next @ TO node 
REPEAT ( node is 0 ) 
str addnode ( -- node ) DUP 
prev IF prev .next ! 
ELSE htable hash_code CELL[] ! 
ENDIF ; 

: bl-skip BEGIN DUP WHILE OVER C@ BL U<= WHILE 1 /STRING REPEAT THEN ; ( addr1 n1 -- addr2 n2 ) 

: bl-scan ( addr1 n1 -- addr2 n2 )
   0 #2166136261 LOCALS| idx ch |
   BEGIN DUP WHILE
      OVER C@ TO ch  ch BL U> WHILE
         ch >LWC idx XOR #16777619 * TO idx
         1 /STRING
      REPEAT
   THEN  idx TO the-index ;

: PARSE-NAME2 ( c-addr u -- c-addr2 u2 c-addr1 u1 ) 
bl-skip OVER >R 
bl-scan ( end-input len r: start-input ) 
2DUP DROP R> TUCK - ; 

: process-words ( c-addr u -- ) 
BEGIN PARSE-NAME2 DUP 
WHILE hfind DROP 
REPEAT 4DROP ; 

: .words ( -- ) 
htable 
hsize 0 ?DO @+ DUP IF ( node ) DUP .addr @ CR .$ 
( node ) #20 HTAB .count @ DEC. 
ELSE DROP 
ENDIF 
LOOP DROP ; 

VARIABLE FID
: my-slurp-file ( -- c-addr u )
   R/O OPEN-FILE THROW
   DUP FID !
   MAP-FILE THROW ;

: count-biblewords ( -- ) 
TIMER-RESET 
S" kjvbible_x10.txt" my-slurp-file
process-words 
\ .words 
.ELAPSED SPACE hcount DEC. ." words found"
FID @ CLOSE-FILE DROP ;
