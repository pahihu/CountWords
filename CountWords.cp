MODULE CountWords;
   IMPORT CPmain, StdIn, Console, RTS, BufferedOutput;

   CONST Hsize = 65536;
   VAR line: ARRAY 1024 OF CHAR;
       Htable: POINTER TO ARRAY OF INTEGER;
       Hvalue: POINTER TO ARRAY OF RECORD
                  count: INTEGER;
                  str: POINTER TO ARRAY OF CHAR;
               END;
       Hcount: INTEGER;
       t0: LONGINT;

   PROCEDURE Elapsed(IN msg: ARRAY OF CHAR);
      VAR t1: LONGINT;
   BEGIN
      t1 := RTS.GetMillis();
      Console.WriteString(msg);
      Console.WriteInt(SHORT(t1 - t0), 5);
      Console.WriteLn;
      t0 := t1
   END Elapsed;

   PROCEDURE LowerCase(ch: CHAR): CHAR;
      VAR ret: CHAR;
   BEGIN
      IF ("A" <= ch) & (ch <= "Z") THEN
         ret := CHR(ORD(ch) + ORD("a") - ORD("A"))
      ELSE
         ret := ch
      END;
      RETURN ret
   END LowerCase;

   PROCEDURE Hash(from, to: INTEGER): INTEGER;
      VAR i: INTEGER;
          h: INTEGER;
   BEGIN
      h := -2128831035;
      FOR i:=from TO to-1 DO
         h := ORD(BITS(h) / BITS(ORD(CAP(line[i]))));
         h := 16777619 * h
      END;
      RETURN h
   END Hash;

   PROCEDURE Hfind(from, to: INTEGER): INTEGER;
      VAR i, j, hash: INTEGER;
          done: BOOLEAN;
   BEGIN
      hash := Hash(from, to); j := hash MOD Hsize;
      i := 0; done := FALSE;
      WHILE (i < Hsize) & ~done DO
         IF Htable[j] = 0 THEN
            Htable[j] := hash;
            done := TRUE
         ELSIF Htable[j] = hash THEN
            done := TRUE
         ELSE
            INC(j); IF j = Hsize THEN j := 0 END;
            INC(i)
         END
      END;
      IF ~done THEN
         Console.WriteString("Htable full!");
         HALT(1)
      END;
      RETURN j
   END Hfind;

   PROCEDURE ProcessWord(from, to: INTEGER);
      VAR i, j: INTEGER;
   BEGIN i := 0;
      i := Hfind(from, to);
      IF Hvalue[i].count = 0 THEN
         Hvalue[i].count := 1;
         NEW(Hvalue[i].str, to-from+1);
         FOR j:=from TO to-1 DO
            Hvalue[i].str[j-from] := LowerCase(line[j])
         END;
         Hvalue[i].str[to-from] := 0X;
         INC(Hcount)
      ELSE
         INC(Hvalue[i].count)
      END
   END ProcessWord;

   PROCEDURE ProcessInput;
      VAR i, j: INTEGER;
   BEGIN
      StdIn.ReadLn(line);
      WHILE StdIn.More() DO
         i := 0;
         WHILE line[i] # 0X DO
            WHILE (line[i] # 0X) & (line[i] <= " ") DO INC(i) END;
            j := i;
            WHILE (line[j] # 0X) & (line[j] > " ") DO INC(j) END;
            IF i < j THEN
               ProcessWord(i, j)
            END;
            i := j
         END;
         StdIn.ReadLn(line)
      END
   END ProcessInput;

   PROCEDURE Entry(VAR entries: ARRAY OF INTEGER; index: INTEGER): INTEGER;
   BEGIN RETURN -Hvalue[entries[index]].count
   END Entry;

   PROCEDURE Quicksort(VAR entries: ARRAY OF INTEGER; first, last: INTEGER);
      VAR pivot, left, right, tmp: INTEGER;
   BEGIN
      IF last-first+1 > 1 THEN
         pivot := Entry(entries, (first + last) DIV 2);
         left := first; right := last;
         WHILE left <= right DO
            WHILE Entry(entries,left) < pivot DO INC(left) END;
            WHILE Entry(entries,right) > pivot DO DEC(right) END;
            IF left <= right THEN
               tmp := entries[left];
               entries[left] := entries[right];
               entries[right] := tmp;
               INC(left); DEC(right)
            END
         END;
         Quicksort(entries, first, right);
         Quicksort(entries, left, last)
      END
   END Quicksort;

   PROCEDURE ShowWords;
      VAR entries: POINTER TO ARRAY OF INTEGER;
          i, j: INTEGER;
          fout: BufferedOutput.FILE;
   BEGIN 
      NEW(entries, Hcount);
      j := 0;
      FOR i:=0 TO Hsize-1 DO
         IF Htable[i] # 0 THEN
            entries[j] := i; INC(j)
         END
      END;
      Quicksort(entries, 0, Hcount-1);
      fout := BufferedOutput.Open("cp.result");
      FOR i:=0 TO Hcount-1 DO
         j := entries[i];
         BufferedOutput.WriteString(fout, Hvalue[j].str);
         BufferedOutput.Write(fout, " ");
         BufferedOutput.WriteInt(fout, Hvalue[j].count);
         BufferedOutput.WriteLn(fout)
      END;
      BufferedOutput.Close(fout)
   END ShowWords;

   PROCEDURE Init;
      VAR i: INTEGER;
   BEGIN
      NEW(Htable, Hsize);
      NEW(Hvalue, Hsize);
      FOR i:=0 TO Hsize-1 DO
         Htable[i] := 0;
         Hvalue[i].count := 0
      END
   END Init;

BEGIN
   Init;
   t0 := RTS.GetMillis();
   ProcessInput;
   ShowWords;
   Elapsed("###CountWords ")
END CountWords.
