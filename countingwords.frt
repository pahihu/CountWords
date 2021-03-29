\ Marcel Hendrix 29mar2021
ANEW -countingwords 

-- 3583rd prime is 33469 which is enough for this Bible 
2 CELLS =: DATASZ 

#33469 =: hsize ( -- maxsize ) -- a prime number 
0 VALUE hcount ( -- actsize ) 
CREATE htable PRIVATE hsize CELLS ALLOT 
htable hsize CELLS ERASE 

: .key ; PRIVATE ( node -- 'addr ) 
: .next CELL+ ; PRIVATE ( node -- 'addr ) 
: .addr 2 CELL[] ; PRIVATE ( node -- addr ) 
: .count 3 CELL[] ; PRIVATE ( node -- addr ) 

: hashcode ( index -- u ) U>D hsize UM/MOD DROP ; PRIVATE 
: >index ( c-addr u -- index ) 0 >S 0 ?DO C@+ S> 3 ROL XOR >S LOOP DROP S> ; PRIVATE 

: addnode ( c-addr u -- node ) 
HERE LOCAL str 
DUP 1+ ALLOT str PACK COUNT >index ( -- index ) 
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
DLOCAL str str >index ( -- index ) 
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
: bl-scan BEGIN DUP WHILE OVER C@ BL U> WHILE 1 /STRING REPEAT THEN ; ( addr1 n1 -- addr2 n2 ) 

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

: count-biblewords ( -- ) 
TIMER-RESET 
S" kjvbible.txt" SLURP-FILE(2) 
process-words 
\ .words 
.ELAPSED SPACE hcount DEC. ." words found" ;
