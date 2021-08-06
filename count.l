(gc 256)
(setq *Delim " ^I^J^M")
(setq *Skip (chop *Delim))
 
(de word+ NIL
   (prog1
      (lowc (till *Delim T))
      (while (member (peek) *Skip) (char)) ) )
 
#  input on cmdline
(off B)
(argv Arg)
(in Arg
   (until (eof)
      (let W (word+)
         (if (idx 'B W T) (inc (car @)) (set W 1)) ) ) )
(for L (flip (by val sort (idx 'B)))
   (println L (val L)) )
(bye)
