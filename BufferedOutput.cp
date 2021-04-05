MODULE BufferedOutput;
   IMPORT GPTextFiles, RTS;
   CONST BufSize = 65536;
   TYPE FILE* = POINTER TO RECORD
           buf: POINTER TO ARRAY OF CHAR;
           nbuf: INTEGER;
           file: GPTextFiles.FILE;
        END;
   VAR tmp: ARRAY 32 OF CHAR;

   PROCEDURE Open*(IN str: ARRAY OF CHAR): FILE;
      VAR fout: FILE;
   BEGIN NEW(fout);
      NEW(fout^.buf, BufSize + 1);
      fout^.nbuf := 0;
      fout^.file := GPTextFiles.createFile(str);
      RETURN fout
   END Open;

   PROCEDURE Flush*(fout: FILE);
   BEGIN
      IF fout^.nbuf # 0 THEN
         fout^.buf[fout^.nbuf] := 0X;
         GPTextFiles.WriteNChars(fout^.file, fout^.buf, fout^.nbuf);
         fout^.nbuf := 0
      END
   END Flush;

   PROCEDURE Close*(fout: FILE);
   BEGIN Flush(fout);
      GPTextFiles.CloseFile(fout^.file);
      fout^.file := NIL
   END Close;

   PROCEDURE Append(fout: FILE; IN str: ARRAY OF CHAR);
      VAR i: INTEGER;
   BEGIN
      i := 0;
      WHILE str[i] # 0X DO
         IF fout^.nbuf = BufSize THEN Flush(fout) END;
         fout^.buf[fout^.nbuf] := str[i]; INC(fout^.nbuf);
         INC(i)
      END
   END Append;

   PROCEDURE Write*(fout: FILE; ch: CHAR);
   BEGIN tmp[0] := ch; tmp[1] := 0X; Append(fout, tmp)
   END Write;

   PROCEDURE WriteString*(fout: FILE; IN str: ARRAY OF CHAR);
   BEGIN Append(fout, str)
   END WriteString;

   PROCEDURE WriteInt*(fout: FILE; val: INTEGER);
   BEGIN RTS.IntToStr(val, tmp); Append(fout, tmp)
   END WriteInt;

   PROCEDURE WriteLn*(fout: FILE);
   BEGIN tmp[0] := 0AX; tmp[1] := 0X; Append(fout, tmp)
   END WriteLn;

END BufferedOutput.
