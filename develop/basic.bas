100 CLS
110 screen = 15 * 65536 : width = 64 : height = 32
115 DIM pattern$(5 )
120 pattern$(0 )  = "FRRDFDFDRFD"
121 pattern$(1 )  = "FRRDFDFDLFD"
122 pattern$(2 )  = "FFRRDFDFDFD"
123 pattern$(3 )  = "DFDRFDRFD"
124 pattern$(4 )  = "FRRDFDRFDLFD"
125 pattern$(5 )  = "FRRDFDLFDRFD"
130 pattern$ = pattern$(4 )
200 FOR dir = 0 TO 3
210 x = dir * 10 + 10 : y = 10
220 GOSUB 5000
230 NEXT dir
240 END
4997 REM
4998 REM "5000-draw 5010-erase 5020-test"
4999 REM
5000 c = 233 :  GOTO 5030
5010 c = 32 :  GOTO 5030
5020 c =  - 1 : hit = 0
5030 x1 = x : y1 = y : d1 = dir
5040 FOR i = 1 TO  LEN( pattern$ )
5050 c$ =  UPPER$(  MID$( pattern$ , i , 1 )  )
5060 IF c$ = "L" THEN d1 =  ( d1 - 1 )  & 3
5070 IF c$ = "R" THEN d1 =  ( d1 + 1 )  & 3
5080 IF c$ = "F"
5090 IF d1 = 0 | d1 = 2 THEN x1 = x1 + d1 - 1
5100 IF d1 = 1 | d1 = 3 THEN y1 = y1 - d1 + 2
5110 ENDIF
5120 IF c$ = "D"
5125 addr = x1 + y1 * width + screen
5130 IF c >= 0
5140 POKE addr , c
5150 ELSE
5160 IF  PEEK( addr )  <> 32 THEN hit = 1
5180 ENDIF
5185 ENDIF
5190 NEXT i
5200 RETURN