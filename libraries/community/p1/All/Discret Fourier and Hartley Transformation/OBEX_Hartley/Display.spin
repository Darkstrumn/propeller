{{ 27.08.2013

   PAL Vierfarben-Grafik-Display 256×128 Punkte mit 8×8 Zeichenmatrix

   ===================================
   Copyright 2008..2013 by G. Pillmann
   ===================================

}}


CON {änderbar}

 _CLKMODE  = XTAL1 + PLL16x
 _XINFREQ  = 6144000

  TVpin    =  23 {3,7,..,31}                            'Propeller-Pin für den TV-Anschluß
                                                      
  Ny       = 128 {0,8,..,280}                           'Anzahl Pixelzeilen
  Sy       =   2 {1..}                                  'Skalierfaktor Pixelzeilen in Perioden pro 16 Pixel
  Nx       = 256 {0,16,..,512}                          'Anzahl Pixelspalten
  Sx{Gx}   =  14 {7(528)..11(336)..21(176)..33(112)}    'Skalierfaktor Pixelspalten in Perioden pro 16 Pixel     

  Positiv  = " " {"+ "}                                 'Vorzeichensymbol für positive Zahlen
  Komma    = "." {",."}                                 'Kommasymbol für Fest- und Gleitkommazahlen
  Exponent =   1 {0=NIEDZ,1=?∞×÷×}                      'Exponentsymbolsatz für Gleitkommazahlen
  

CON {berechnet}

  Vmode   = ((TVpin//8)/4) << 6                         'TV-Anschlußkonfiguration
  Vgroup  = TVpin/8                                     '  Widerstände = ∞/196Ω/392Ω/787Ω
  Vpins   = %0111 << (TVpin//8 - TVpin//4)              
  Vdir    = %1111 << (TVpin - TVpin//4)                 

  Gy      = (625-50)/2 {= NyO + Sy*Ny + NyU}            'Gesamtanzahl Pixelzeilen inklusive oberen und unteren Rand
  Gx      = 231*16/Sx  {= NxL +    Nx + NxR}            'Gesamtanzahl Pixelspalten inklusive linken und rechten Rand
  
  NyO     = (Gy/Sy - Ny)/2 + 8                          'Anzahl leere Pixelzeilen am oberen Rand
  NyU     = Gy/Sy - Ny - NyO                            'Anzahl leere Pixelzeilen am unteren Rand
  NxL     = (Gx - Nx)/2                                 'Anzahl leere Pixelspalten am linken Rand        
  NxR     = Gx - Nx - NxL                               'Anzahl leere Pixelspalten am rechten Rand

  SxD     = 231 - Nx*Sx/16                              'Anzahl leerer Perioden
  SxL     = SxD/2                                       '  für den linken Rand
  SxR     = SxD - SxL                                   '  für den rechten Rand

  BitMapN = Ny*Nx*2/8                                   'Anzahl Bytes für die Vierfarben-BitMap

  Ex0   = (Exponent == 0)                               'Exponentsymbolsatz
  NaN   = "N" & Ex0 | "?" & !Ex0                        '  0: Exponent = 10er Komplement
  Inf   = "I" & Ex0 | "∞" & !Ex0                        '  1: Exponent = ×/÷ Absolutwert
  Num   = "E" & Ex0 | "×" & !Ex0
  DnN   = "D" & Ex0 | "÷" & !Ex0
  Zer   = "Z" & Ex0 | "×" & !Ex0

  
CON {definiert}

   Idx  = %00_0_00000<<24                               'Indexzahl      (Unsigned Integer with leading zeros)
  uInt  = %01_0_00000<<24                               'Ganzzahl       (Unsigned Integer)
  sInt  = %01_1_00000<<24                               'Ganzzahl       (Signed Integer)
  wInt  =   sInt + 16<<24                               'Ganzzahl       (Word Signed Integer)
  bInt  =   sInt + 24<<24                               'Ganzzahl       (Byte Signed Integer)
  uFix  = %10_0_00000<<24                               'Festkommazahl  (Unsigned Fixed Point Number)
  sFix  = %10_1_00000<<24                               'Festkommazahl  (Signed Fixed Point Number)
  wFix  =   sFix + 16<<24                               'Festkommazahl  (Word Signed Fixed Point Number)
  bFix  =   sFix + 24<<24                               'Festkommazahl  (Byte Signed Fixed Point Number)
   Flt  = %11_1_00000<<24 + 28<<16                      'Gleitkommazahl (Floating Point Number)
   Sci  =    Flt +  6<< 8 + 12                          'Standardausgabeformat für Gleitkommazahlen (Scientific Notation)

  sByte = 0
  sWord = 1
  sLong = 2
  iByte = 1
  iWord = 2
  iLong = 4


VAR

  long BitMap [BitMapN/iLong]
  long DspPar [8]
  word DspFun


PUB Demo | k

  Init
  Pen(-3)
  Pix(0,79)
  Str(string("DISPLAY-TEST"))
  Pen(1)
  Pix(10,60)
  Lin(128,-40)
  Pen(2)
  Pix(10,20)
  Lin(128,40)
  Pen(3)
  Lin(0,-40)

  Pix(0,0)
  Lin(0,127)
  Lin(255,0)
  Lin(0,-127)
  Lin(-255,0)

  Wait(2)
  repeat k from 0 to 127
    if k//16 == 0
      Lf
    Chr(256+k)
    
  Wait(2)
  Pen(-1)
  Lf
  LfStr(string("øÀÁÂß→↓←Δ±µ×÷πÃ"))
  LfStr(string("ÒΩ²³ÓÄäÖöÜü≈ΣÔÕ°"))
  LfChr("∞")

  Wait(2)
  Pen(2) 
  LfDec(0.01,sci)
  LfDec(0.02,sci)
  LfDec(0.03,sci)
  LfDec(0.04,sci)
  LfDec(0.05,sci)
  LfDec(0.06,sci)
  LfDec(0.07,sci)
  LfDec(0.08,sci)
  LfDec(0.09,sci)
  LfDec(0.10,sci)
  
  Wait(2)
  Pen(-2)
  LfStr(string("01234567890123456780"))

  Wait(2)
  Pen(3)
  Lf
  LfStr(string("±NAN=  "))
    Dec(255<<23+1234567,Sci-1)
  Pen(2)
  LfStr(string("±INF=  "))
    Dec(255<<23        ,Sci-1)
  Pen(3)
  LfStr(string("±MAX=  "))
    Dec(254<<23+$7FFFFF,Sci-1)
  Pen(1)
  LfStr(string("±MIN=  "))
    Dec(001<<23        ,Sci-1)
  Pen(2)
  LfStr(string("±DNN=  "))
    Dec(1.175493e-38   ,Sci-1)
  Pen(3)
  LfStr(string("±DNN=  "))
    Dec(0.000001e-38   ,Sci-1)
  Pen(1)
  LfStr(string("±ZER=  "))
    Dec(              0,Sci-1)
  Pen(2)
  LfStr(string(" NUM= " ))
    Dec(+2.718281828   ,Sci  )
  Pen(3)
  LfStr(string(" NUM= " ))
    Dec(-3.141592654   ,Sci  )
  Pen(1)
  LfStr(string(" NUM= " ))
    Dec(+9.999999e33   ,Sci  )

    
PUB Init     

  aChrTab := @ChrTab
  aLogTab := @LogTab
  aBitMap := @BitMap
  aDspPar := @DspPar
  aDspFun := @DspFun
   DspFun := @Dsp_Ff
  cognew( @PAL_Display, @PAL_Display )


PUB Wait( Sekunden )
  repeat Sekunden
    waitcnt( clkfreq + cnt )

  
PUB Ff {Formfeed}
  DspRdy
  DspFun := @Dsp_Ff


PUB Lf {Linefeed}
  DspRdy
  DspFun := @Dsp_Lf
  

PUB Cr {Carriage return}
  DspRdy
  DspFun := @Dsp_Cr


PUB Bs {Backspace}
  DspRdy
  DspFun := @Dsp_Bs


PUB Rdy( Nil ): Result {= Nil}
  DspRdy
  Result := Nil


PUB Chr( Zeichen )
  DspRdy
  DspPar := Zeichen
  DspFun := @Dsp_Chr


PUB Str( adr_String )
  DspRdy
  DspPar := adr_String
  DspFun := @Dsp_Str

    
PUB Pen( Farbe )
  DspRdy
  DspPar := Farbe
  DspFun := @Dsp_Pen


PUB Pix( x, y )
  DspRdy
  DspPar[1] := constant(Ny-1) - y
  DspPar{0} :=                  x
  DspFun    := @Dsp_Pix

  
PUB Lin( dx, dy )
  DspRdy
  DspPar[1] := -dy
  DspPar{0} :=  dx
  DspFun    := @Dsp_Lin


PUB Sig( Zahl ): Result {= Absolutwert der Zahl}
  Chr( "," + (Zahl => 0) | 1 )
  Result := ||Zahl


PUB Dec( Zahl, Format ) | aStr
  if (Format & 15) <> 0
    Str( DecToStr( Zahl, Format ) )
  else  
    aStr := Rdy( DecToStr( Zahl, Format + 15 ) )
    repeat while byte [aStr++] < "-"
    Str( --aStr )


PUB Bin( Zahl, Stellen )
  Zahl <-= ( 32 - Stellen )
  repeat Stellen
    Chr( "0" + ( Zahl <-= 1 ) & 1 )


PUB Hex( Zahl, Stellen )
  Zahl <-= (( 8 - Stellen ) << 2)
  repeat Stellen 
    Chr( lookupz( ( Zahl <-= 4 ) & 15 : "0".."9", "A".."F" ) )


PUB LfChr( Zeichen )
  Lf
  Chr( Zeichen )


PUB LfStr( adr_String )
  Lf
  Str( adr_String )


PUB LfDec( Zahl, Format )
  Lf
  Dec( Zahl, Format )


PUB LfHex( Zahl, Stellen )
  Lf
  Hex( Zahl, Stellen )


PUB DecToStr( Zahl, Format ): Result {= Adresse des Ergebnisstrings}

  { Zahl         = Za
    Format
      Bit 31..30 = Ty = Indexzahl(Idx)/Ganzzahl(Int)/Festkommazahl(Fix)/Gleitkommazahl(Flt)
      Bit     29      = Mit/Ohne Vorzeichen
      Bit 28..24      = Vorzeichenerweiterungsstellen    {1..31}
      Bit 21..16 = Bk = Binäre Nachkommastellen          {1..32}
      Bit 11.. 8 = Dk = Dezimale Nachkommastellen        {1..10}
      Bit  3.. 0      = Insgesamt darzustellende Zeichen {1..15}
  
    Die Zahlendarstellung darf nicht mehr als 9 1/2 Dezimalziffern und nicht mehr als 15 Zeichen beanspruchen
  
    DecToStr( Zahl,  Idx                    Stellen ) Index Number = Unsigned Integer with leading zeros
    DecToStr( Zahl, uInt                  + Stellen ) Unsigned Integer
    DecToStr( Zahl, sInt                  + Stellen ) Signed Integer
    DecToStr( Zahl, uFix + Bk<<16 + Dk<<8 + Stellen ) Unsigned Fixed Point Number
    DecToStr( Zahl, sFix + Bk<<16 + Dk<<8 + Stellen ) Signed Fixed Point Number
    DecToStr( Zahl,  Flt          + Dk<<8 + Stellen ) Floating Point Number
  }
  
  DspRdy
  DspPar[2] := @DspPar[4]
  DspPar[1] := Format
  DspPar{0} := Zahl
  DspFun    := lookupz( Format>>30 : @Dsp_IdxToStr, @Dsp_IntToStr, @Dsp_FixToStr, @Dsp_FltToStr )
  Result    := @DspPar[4]


PRI DspRdy
  repeat until DspFun == 0


CON      {{ Tabellen }}


DAT                  {{ 8×8 Zeichentabelle }}

  byte "ø","",192,193,194,"ß","→","↓"                  'Korrespondenztabelle zum Propeller-Zeichensatz
  byte "←","Δ","±","µ","×","÷","π",195
  byte 210,"Ω","²","³",211,"Ä","ä","Ö"
  byte "ö","Ü","ü","≈","Σ",212,213,"°"

  ChrTab                                                'HP41C-Zeichensatz
       
  'yte $00,$00,$10,$38,$7C,$38,$10,$00                  'Raute
  'yte $18,$24,$70,$20,$70,$24,$18,$00                  '== €
  byte $00,$08,$38,$54,$54,$38,$20,$00                  '== ø
  byte $04,$0C,$E4,$04,$04,$00,$00,$00                  '           
  byte $0C,$02,$E4,$08,$0E,$00,$00,$00                  'hoch -2
  byte $0C,$02,$E4,$02,$0C,$00,$00,$00                  'hoch -3
  byte $0A,$0A,$EE,$02,$02,$00,$00,$00                  'hoch -4
  byte $00,$30,$48,$78,$44,$78,$40,$40                  'ß           
  byte $00,$00,$10,$08,$F4,$08,$10,$00                  '→
  byte $00,$10,$10,$10,$54,$28,$10,$00                  '↓
  byte $00,$00,$10,$20,$5E,$20,$10,$00                  '←
  byte $00,$00,$00,$10,$28,$44,$FE,$00                  'Δ
  'yte $00,$40,$40,$4C,$48,$6C,$08,$08                  'Lf                     
  byte $00,$10,$10,$7C,$10,$10,$7C,$00                  '== ±
  byte $00,$00,$00,$44,$44,$78,$40,$40                  'µ
  'yte $00,$60,$40,$6C,$48,$4C,$08,$08                  'Ff
  byte $00,$00,$00,$28,$10,$28,$00,$00                  '== ×
  'yte $00,$C0,$80,$98,$94,$D8,$14,$14                  'Cr
  byte $00,$00,$10,$00,$38,$00,$10,$00                  '== ÷
  byte $00,$00,$00,$7C,$A8,$28,$44,$00                  'π
  byte $00,$00,$28,$54,$54,$38,$10,$10                  'phi

  byte $00,$00,$00,$44,$92,$92,$6C,$00                  'omega
  byte $00,$38,$44,$44,$28,$28,$6C,$00                  'Ω
  byte $60,$10,$20,$40,$70,$00,$00,$00                  '²
  byte $60,$10,$20,$10,$60,$00,$00,$00                  '³
  byte $50,$50,$70,$10,$10,$00,$00,$00                  'hoch 4
  byte $44,$38,$44,$7C,$44,$44,$44,$00                  'Ä
  byte $00,$28,$00,$38,$48,$48,$3C,$00                  'ä
  byte $44,$38,$44,$44,$44,$44,$38,$00                  'Ö
  byte $00,$28,$00,$38,$44,$44,$38,$00                  'ö
  byte $28,$44,$44,$44,$44,$44,$38,$00                  'Ü
  byte $00,$28,$00,$44,$44,$44,$38,$00                  'ü
  'yte $00,$60,$40,$6C,$48,$68,$08,$0C                  'Esc
  byte $00,$00,$32,$4C,$00,$32,$4C,$00                  '== ≈
  byte $00,$7C,$20,$10,$20,$40,$7C,$00                  'Σ
  byte $00,$00,$08,$7C,$10,$7C,$20,$00                  'ungleich
  byte $00,$00,$04,$08,$10,$20,$7C,$00                  'Winkel
  byte $30,$48,$48,$30,$00,$00,$00,$00                  '°

  byte $00,$00,$00,$00,$00,$00,$00,$00                  'Blank
  byte $00,$10,$10,$10,$10,$00,$10,$00                  '!
  byte $00,$28,$28,$28,$00,$00,$00,$00                  '"
  byte $00,$00,$28,$7C,$28,$7C,$28,$00                  '#
  byte $00,$10,$3C,$50,$38,$14,$78,$10                  '$
  byte $00,$00,$44,$08,$10,$20,$44,$00                  '%
  byte $00,$20,$50,$20,$54,$48,$34,$00                  '&
  byte $00,$10,$10,$10,$00,$00,$00,$00                  ''
  byte $00,$10,$20,$20,$20,$20,$10,$00                  '(
  byte $00,$10,$08,$08,$08,$08,$10,$00                  ')
  byte $00,$00,$10,$54,$38,$54,$10,$00                  '*
  byte $00,$00,$10,$10,$7C,$10,$10,$00                  '+
  byte $00,$00,$00,$00,$00,$10,$10,$20                  ',
  byte $00,$00,$00,$00,$7C,$00,$00,$00                  '-
  byte $00,$00,$00,$00,$00,$00,$10,$00                  '.
  byte $00,$00,$04,$08,$10,$20,$40,$00                  '/

  byte $00,$30,$48,$48,$48,$48,$30,$00                  '0
  byte $00,$18,$28,$48,$08,$08,$08,$00                  '1
  byte $00,$38,$44,$08,$10,$20,$7C,$00                  '2
  byte $00,$38,$44,$18,$04,$44,$38,$00                  '3
  byte $00,$40,$48,$48,$7C,$08,$08,$00                  '4
  byte $00,$7C,$40,$78,$04,$44,$38,$00                  '5
  byte $00,$38,$40,$78,$44,$44,$38,$00                  '6
  byte $00,$7C,$44,$08,$10,$10,$10,$00                  '7
  byte $00,$38,$44,$38,$44,$44,$38,$00                  '8
  byte $00,$38,$44,$44,$3C,$04,$38,$00                  '9
  byte $00,$00,$00,$10,$00,$10,$00,$00                  ':
  byte $00,$00,$00,$10,$00,$10,$10,$00                  ';
  byte $00,$00,$08,$10,$20,$10,$08,$00                  '<
  byte $00,$00,$00,$7C,$00,$7C,$00,$00                  '=
  byte $00,$00,$20,$10,$08,$10,$20,$00                  '>
  byte $00,$38,$44,$08,$10,$00,$10,$00                  '?
                                                         
  byte $00,$38,$44,$54,$5C,$40,$38,$00                  '@
  byte $00,$38,$44,$7C,$44,$44,$44,$00                  'A
  byte $00,$78,$24,$38,$24,$24,$78,$00                  'B
  byte $00,$3C,$40,$40,$40,$40,$3C,$00                  'C
  byte $00,$78,$24,$24,$24,$24,$78,$00                  'D
  byte $00,$7C,$40,$78,$40,$40,$7C,$00                  'E
  byte $00,$7C,$40,$78,$40,$40,$40,$00                  'F
  byte $00,$38,$40,$40,$4C,$44,$3C,$00                  'G
  byte $00,$44,$44,$7C,$44,$44,$44,$00                  'H
  byte $00,$7C,$10,$10,$10,$10,$7C,$00                  'I
  byte $00,$3C,$04,$04,$04,$44,$38,$00                  'J
  byte $00,$48,$50,$60,$50,$48,$44,$00                  'K
  byte $00,$40,$40,$40,$40,$40,$7C,$00                  'L
  byte $00,$44,$6C,$54,$44,$44,$44,$00                  'M
  byte $00,$44,$64,$54,$4C,$44,$44,$00                  'N
  byte $00,$38,$44,$44,$44,$44,$38,$00                  'O

  byte $00,$78,$44,$78,$40,$40,$40,$00                  'P
  byte $00,$38,$44,$44,$54,$48,$34,$00                  'Q
  byte $00,$78,$44,$78,$50,$48,$44,$00                  'R
  byte $00,$38,$44,$30,$08,$44,$38,$00                  'S
  byte $00,$7C,$10,$10,$10,$10,$10,$00                  'T
  byte $00,$44,$44,$44,$44,$44,$38,$00                  'U
  byte $00,$44,$44,$44,$44,$28,$10,$00                  'V
  byte $00,$44,$44,$54,$54,$54,$28,$00                  'W
  byte $00,$44,$28,$10,$28,$44,$44,$00                  'X
  byte $00,$44,$28,$10,$10,$10,$10,$00                  'Y
  byte $00,$78,$08,$10,$20,$40,$78,$00                  'Z
  byte $00,$38,$20,$20,$20,$20,$38,$00                  '[
  byte $00,$00,$40,$20,$10,$08,$04,$00                  '\
  byte $00,$38,$08,$08,$08,$08,$38,$00                  ']
  byte $00,$10,$28,$54,$10,$10,$10,$00                  '↑
  byte $00,$00,$00,$00,$00,$00,$7C,$00                  '_

  byte $00,$20,$10,$08,$00,$00,$00,$00                  '`
  byte $00,$00,$00,$38,$48,$48,$3C,$00                  'a
  byte $00,$40,$40,$7C,$44,$44,$7C,$00                  'b
  byte $00,$00,$00,$3C,$40,$40,$3C,$00                  'c
  byte $00,$04,$04,$3C,$44,$44,$3C,$00                  'd
  byte $00,$00,$00,$30,$48,$50,$3C,$00                  'e
  byte $00,$18,$24,$20,$70,$20,$20,$20                  'f
  byte $00,$00,$00,$3C,$44,$3C,$04,$38                  'g
  byte $00,$40,$40,$78,$44,$44,$44,$00                  'h
  byte $00,$20,$00,$60,$20,$20,$18,$00                  'i
  byte $00,$08,$00,$18,$08,$08,$48,$30                  'j
  byte $00,$40,$40,$48,$70,$48,$44,$00                  'k
  byte $00,$60,$20,$20,$20,$20,$18,$00                  'l
  byte $00,$00,$00,$68,$54,$54,$54,$00                  'm
  byte $00,$00,$00,$58,$64,$44,$44,$00                  'n
  byte $00,$00,$00,$38,$44,$44,$38,$00                  'o

  byte $00,$00,$00,$78,$44,$78,$40,$40                  'p
  byte $00,$00,$00,$3C,$44,$3C,$04,$04                  'q
  byte $00,$00,$00,$58,$60,$40,$40,$00                  'r
  byte $00,$00,$00,$38,$20,$10,$70,$00                  'S
  byte $00,$20,$20,$70,$20,$20,$18,$00                  't
  byte $00,$00,$00,$44,$44,$44,$38,$00                  'u
  byte $00,$00,$00,$44,$44,$28,$10,$00                  'v
  byte $00,$00,$00,$44,$54,$54,$28,$00                  'w
  byte $00,$00,$00,$48,$30,$48,$48,$00                  'x
  byte $00,$00,$00,$44,$44,$3C,$04,$38                  'y
  byte $00,$00,$00,$78,$10,$20,$78,$00                  'z
  byte $00,$08,$10,$10,$20,$10,$10,$08                  '{
  byte $00,$10,$10,$10,$10,$10,$10,$10                  '|
  byte $00,$20,$10,$10,$08,$10,$10,$20                  '}
  byte $00,$24,$54,$48,$00,$00,$00,$00                  '~
  'yte $00,$00,$40,$40,$7C,$40,$40,$00                  '
  byte $00,$00,$00,$6C,$92,$6C,$00,$00                  '== ∞

  
DAT                  {{ Logarithmus-Tabelle für die Berechnung von 10^X mit 0 <= X < 1 }}

  LogTab             

  long $2D145116'7   { /2^32 = lg(1 + 2^-1) ... lg(1 + 2^-31) nicht gerundet! (0.32) }
  long $18CF1838'9
  long $0D1854EB 
  long $06BD7E4A'B
  long $036BD211'2
  long $01B9476A
  long $00DD7EA3'4
  long $006EF67A
  long $00378915
  long $001BC802 
  long $000DE4DF
  long $0006F2A7
  long $00037961
  long $0001BCB4
  long $0000DE5A'B
  long $00006F2D'E
  long $00003796'7
  long $00001BCB
  long $00000DE5'6
  long $000006F2'3
  long $00000379
  long $000001BC'D
  long $000000DE
  long $0000006F
  long $00000037'8
  long $0000001B'C
  long $0000000D'E
  long $00000006'7
  long $00000003 
  long $00000001'2
  long $00000000'1
  

CON      {{ Vordergrund-Prozeß "Anzeige" }}

{{  PAL-Parameter:

    Tz = Ts + Td = (4433618,75 Hz - 25 Hz) / 15625 Hz = 283,75 ≈ 284 Perioden

    Tz = 64 µs = 284 Perioden pro Zeile  
    Ts = 12 µs =  53 Perioden pro Synchronbereich 
    Td = 52 µs = 231 Perioden pro Datenbereich

    1 Periode = 16 Pixel

    Gy     = (625-50)/2 = Gesamtanzahl Pixelzeilen
    Gx(Sx) = Td/(Sx/16) = Gesamtanzahl Pixelspalten {Skalierfaktor Sx in Perioden pro 16 Pixel}


    Farben:

    Bit 7654=0: Blau             3210=0: Synchronisation                                
             1:                       1: (nicht verwendbar)                             
             2:                       2: Schwarz                                        
             3: Zyan                  3: .                                              
             4:                       4: .                                              
             5:                       5: .                                              
             6: Grün                  6: .                                              
             7: Gelbgrün              7: Weiß                           
             8: Gelb                  8: Synchronisation                                
             9: Braun                 9: (nicht verwendbar)                             
             A: Orange                a: Dunkel                                         
             B: Rot                   b: .                                              
             C:                       c: .                                              
             D: Magenta               d: .                                              
             E: Purpur                e: Hell                                           
             F:                       f: (nicht verwendbar)
                          

    Zweifarbenpaletten (Vordergrund/Hintergrund):              
                             
         $070a: Weiß / Dunkelblau     
         $07Bb: Weiß / Rot            
         $9e9b: Gelb / Braun          
         $0407: Grau / Weiß           
         $3d3b: Zyan / Dunkelzyan     
         $6b6e: Grün / Graugrün       
         $BbCe: Rot  / Pink           
         $3c0a: Zyan / Blau                    
}}


DAT                  {{ PAL Vierfarben-Grafik-Display }}

                        org

PAL_Display

                        movi    ctra,#%00001_111        'Zählermode auf Video einstellen
                                    
_a                      mov    _a, cPALfreq             '_a := PAL-Farbträgerfrequenz
_b                      rdlong _b, #0                   '_b := CLKFREQ
_c                      mov    _t, #32+1                '_c := 2^32 * _a / _b
                        _repeat
_x                      cmpsub _a, _b wc
_y                      rcl    _c, #1
 a                      shl    _a, #1
 b                      djnz   _t, #(_repeat)
 c                      mov     frqa,_c                 'Zählerfrequenz:= PAL-Farbträgerfrequenz
                                                                                          
 d                      movi    vcfg,#%10101_000+Vmode  'Basisband auf unteren/oberen Pins
 e                      movd    vcfg,#VGroup            'Vierfarbendarstellung                                      
 f                      movs    vcfg,#VPins             'Farbsignal im Basisband aktiviert                          
 i                      or      dira,cVDir
 j                      andn    outa,cVDir

 n                      mov     Dsp_Fun,#Dsp_Funktion                       
                                                        
Display_0               mov    _a, aBitMap
                        neg    _y, #NyO

Display_1               mov    _b, _a
                        mov    _c, #Sy

Display_2               mov     vscl,cTdata_R           
                        waitvid cDspPal,#0              'Rechten leeren Rand erzeugen
                        call    #Hsyn                   'Horizontalen Zeilenrücksprung durchführen
                        mov     vscl,cTdata_L           'Linken leeren Rand erzeugen
                        waitvid cDspPal,#0

                        mov    _a, _b
                        mov    _x, #0
                        mov     vscl,cTdata
                                     
Display_3               cmp    _y, #Ny wc               'Datenbereich der Zeile darstellen
                        mov    _t, #0
              if_c      rdlong _t, _a                   
              if_c      add    _a, #iLong
                        waitvid cDspPal,_t
                        
                        add    _x, #1
                        cmp    _x, #Nx/16 wz
              if_ne     jmp    #Display_3

                        djnz   _c, #Display_2

                        add    _y, #1
                        cmp    _y, #Ny+NyU wz
              if_ne     jmp    #Display_1

                        call   #Vsyn                    'Vertikalen Zeilenrücksprung durchführen

                        jmp     #Display_0


DAT                  {{ Horizontalen Zeilenrücksprung erzeugen }}

Hsyn                    xor     cDspPal,cPALmask        'PAL erzeugen
                        xor     cSynPal,cPALmask
                        mov     vscl,cTHsyn             'Zeilenrücksprung erzeugen
                        waitvid cSynPal,cHsyn
                        
                        mov     Dsp_Tim,cnt             'Hintergrund-Prozeß aus-/fortführen
                        add     Dsp_Tim,#511 wc
              if_nc     add     Dsp_Tim,#511 wc         'Zählerüberlauf berücksichtigen
              if_nc     sub     Dsp_Tim,#511          
                        jmpret  Dsp_Ret,Dsp_Fun         
                        cmp     Dsp_Tim,cnt wc
              if_a      jmp     Dsp_Fun
                        
Hsyn_ret                ret


DAT                  {{ Vertikalen Zeilenrücksprung (8 Zeilen) mit Austastlücke (18 Zeilen) erzeugen }}

Vsyn                    mov    _t, #5                   'Kurze Impulse erzeugen
                        mov     vscl,cTVsyn_K
                        :repeat_1                       
                        waitvid cSynPal,cVsyn_K
                        djnz   _t, #(:repeat_1)

                        mov    _t, #5                   'Lange Impulse erzeugen
                        mov     vscl,cTVsyn_L
                        :repeat_2    
                        waitvid cSynPal,cVsyn_L
                        djnz   _t, #(:repeat_2)

                        mov    _t, #5                   'Kurze Impulse erzeugen
                        mov     vscl,cTVsyn_K
                        :repeat_3         
                        waitvid cSynPal,cVsyn_K
                        djnz   _t, #(:repeat_3)

                        mov     vscl,cTVsyn_H           'Halbe Zeile erzeugen
                        waitvid cSynPal,#0
                        
                        mov    _t, #18                  'Austastlücke erzeugen
                        :repeat_4
                        call   #Hsyn
                        mov     vscl,cTVsyn_A
                        waitvid cSynPal,#0
                        djnz   _t, #(:repeat_4)

Vsyn_ret                ret


DAT                  {{ Konstanten, Variablen }}

cVdir                   long    Vdir               {Datenrichtungsregister für den TV-Ausgang}

cPALfreq                long    4433619            {4.433.618,75 Hz}
cPALmask                long    $F0F0F0F0          {Phasenalternierung}

cTdata                  long    Sx <<12 + Sx *16   {Zeit für 16 Bit des Datenbereichs}
cTdata_L                long    SxL<<12 + SxL*16   {Zeit für den linken Rand des Datenbereichs}
cTdata_R                long    SxR<<12 + SxR*16   {Zeit für den rechten Rand des Datenbereichs}
cTHsyn                  long     53<<12 +  53*16   {Zeit für den horizontalen Synchronisationsimpuls}
cTVsyn_K                long     53<<12 + 142*16   {Zeit für die kurzen Impulse}
cTVsyn_L                long    132<<12 + 142*16   {Zeit für die langen Impulse}
cTVsyn_H                long    142<<12 + 142*16   {Zeit für eine halbe Zeile}
cTVsyn_A                long    231<<12 + 231*16   {Zeit für den Datenbereich in der Austastlücke}

cHsyn                   long    %%0000222011111100 {Horizontaler Synchronisationsimpuls}
cVsyn_K                 long    %%0000000000000111 {Kurzer Impuls}
cVsyn_L                 long    %%0111111111111111 {Langer Impuls}

cSynPal                 long    $00_Aa_00_02       {Synchronisationspalette}
cDspPal                 long    $2e_Ce_6e_02       {Anzeigepalette}
'DspPal                 long    $8e_Ce_6e_1a       {Anzeigepalette}

_t                      long    0                  {Hilfsvariablen}
 {
_a                      long    0
_b                      long    0
_c                      long    0
_x                      long    0
_y                      long    0
 }


CON      {{ Hintergrund-Prozeß "Text" }}


DAT                  {{ Display-Funktionen "Ff,Lf,Cr,Bs,Chr,Str" }}

Dsp_Funktion_Ready      mov     t, #0
                        wrword  t, aDspFun

Dsp_Funktion_Wait       jmpret  Dsp_Fun,Dsp_Ret
                        
Dsp_Funktion            rdword  t, aDspFun wz
              if_z      jmp    #Dsp_Funktion_Wait
                        sub     t, par
                        shr     t, #sLong
                        jmp     t


Dsp_Ff                  mov     Fa,#1
                        mov     a, aBitMap
                        mov     n, cBitMapN
                        jmp    #Dsp_Lf_1


Dsp_Lf                  mov     a, aBitMap
                        mov     b, cBitMapNdivZeilen
                        add     b, aBitMap
                        mov     n, cBitMapN
                        sub     n, cBitMapNdivZeilen
                        call   #Copy{a,b,n}
                        mov     n, cBitMapNdivZeilen
Dsp_Lf_1                call   #Clear{a,n}
                        mov     Ze,#(Ny-8)

                        
Dsp_Cr                  mov     Sp,#0
                        jmp    #Dsp_Funktion_Ready


Dsp_Bs                  cmpsub  Sp,#8
                        jmp    #Dsp_Funktion_Ready


Dsp_Chr                 rdlong  d, aDspPar 
                        call   #ChrPix{d}
                        jmp    #Dsp_Funktion_Ready


Dsp_Str                 rdlong  Pa,aDspPar
                        :repeat
                        rdByte  d, Pa wz
              if_z      jmp    #Dsp_Funktion_Ready
                        call   #ChrPix{d}
                        add     Pa,#iByte
                        jmp    #(:repeat)


DAT                  {{ Textzeilen kopieren }}

Copy{a,b,n}             shr     n, #sLong
                        :repeat
                        jmpret Dsp_Fun,Dsp_Ret
                        rdlong  t, b             
                        add     b, #iLong
                        wrlong  t, a
                        add     a, #iLong
                        djnz    n, #(:repeat)
                        
Copy_ret                ret


DAT                  {{ Textzeilen löschen }}

Clear{a,n}              shr     n, #sLong
                        :repeat
                        jmpret  Dsp_Fun,Dsp_Ret
                        mov     t, #0             
                        wrlong  t, a                    
                        add     a, #iLong
                        djnz    n, #(:repeat)
                        
Clear_ret               ret


DAT                  {{ Textzeichen in Pixel umwandeln }}

ChrPix{d}               call   #AdrPix{Sp,Ze}           'Zeichenadresse in Bitmap berechnen

                        mov     e, aChrTab              'Propeller- in Display-Zeichensatz übersetzen       
                        mov     n, #32
                        :repeat_0
                        jmpret  Dsp_Fun,Dsp_Ret
                        sub     e, #iByte
                        rdbyte  t, e
                        cmp     d, t wz
              if_nz     djnz    n, #(:repeat_0)
              if_z      sub     n, #1
              if_z      mov     d, n
              
                        and     d, #$7F                 'Zeichenadresse in Zeichenmatrix berechnen              
                        shl     d, #3                   
                        add     d, aChrTab
                        
                        neg     e, #1                   'Zeichen von oben nach unten von links nach rechts schreiben
                        mov     j, #8
                        :repeat_1
                        neg     e, e wc
                        rdbyte  f, d
              if_c      rev     f, #32-8
                        
                        mov     i, #8
                        :repeat_2
                        shr     f, #1 wc
                        muxnc   Fa,#%00000100 
                        call   #SetPix{a,b,c,Fa}
                        cmp     i, #1 wz
              if_nz     call   #AdrInH{a,b,c,e}
                        djnz    i, #(:repeat_2)
                        
                        add     d, #iByte
                        add     a, #Nx/16*iLong
                        djnz    j, #(:repeat_1)

                        add     Sp,#8
                        cmpsub  Sp,#Nx

ChrPix_ret              ret


CON      {{ Hintergrund-Prozeß "Grafik" }}

{{  Fa            = Farbe

    Bit 7    : 0  = Pixeladresse horizontal inkrementieren
             : 1  = Pixeladresse vertikal inkrementieren 
    Bit 3..2 : 00 = Textpixel setzen
             : 01 = Textpixel löschen
             : 10 = Textpixel invertiert setzen
             : 11 = Textpixel invertiert löschen
    Bit 1..0 : 00 = Hintergrund
             : 01 = Farbe 1
             : 10 = Farbe 2
             : 11 = Farbe 3      
}}     


DAT                  {{ Display-Funktionen "Pen,Pix,Lin" }}

Dsp_Pen                 rdlong  Fa,aDspPar              'Stiftfarbe setzen
                        abs     Fa,Fa wc
                        muxc    Fa,#%1<<3 
                        call   #ColPix
                        jmp    #Dsp_Funktion_Ready


Dsp_Pix                 mov     t, aDspPar              'Pixel an Position (Sp,Ze) zeichnen
                        rdlong  Sp,t                    
                        add     t, #iLong               
                        rdlong  Ze,t                    
                        call   #AdrPix
                        call   #SetPix
                        jmp    #Dsp_Funktion_Ready

                        
Dsp_Lin                 mov     t, aDspPar              'Linie inkrementell vom letzten gezeichneten Pixel ab zeichnen
                        rdlong  e, t                    'e := Spalteninkrement
                        add     t, #iLong               
                        rdlong  f, t                    'f := Zeileninkrement

                        abs     i, e
                        abs     j, f
                        cmp     i, j wc
                        muxc    Fa,#%1<<7
              if_c      xor     i, j
              if_c      xor     j, i
              if_c      xor     i, j 

                        mov     n, i wz
              if_z      jmp    #Dsp_Funktion_Ready

                        mov     d, i                   
                        shr     d, #1
                        :repeat
                        add     d, j                    
                        cmpsub  d, i   nr,wc
        if_nc           test    Fa,#%1<<7 wz
        if_c_or_nz      call   #AdrInV
                        cmpsub  d, i      wc
        if_nc           test    Fa,#%1<<7 wz
        if_c_or_z       call   #AdrInH
                        call   #SetPix
                        djnz    n, #(:repeat)
                        
                        jmp    #Dsp_Funktion_Ready


DAT                  {{ Pixeladresse berechnen }}

AdrPix{Sp,Ze}           jmpret Dsp_Fun,Dsp_Ret

                        mov     a, Sp                   'a :=  aBitMap + (Ze*Nx/16 + Sp/16)*iLong    
                        sar     a, #4
                        shl     a, #5+1
                        or      a, #Nx/16
                        mov     t, Ze
                        shl     t, #5
                        mov     n, #5
                        :repeat
                        sar     a, #1 wc
              if_c      add     a, t
                        djnz    n, #(:repeat)
                        shl     a, #sLong-1
                        add     a, aBitMap              'a := Adresse der den Punkt enthaltenden Long-Variablen
                        
ColPix{Sp}              mov     t, Sp                   't := (Sp mod 16) * 2
                        and     t, #15
                        shl     t, #1
                        mov     b, #%11                 'b := Maske auf Position des Punktes in der Long-Variablen              
                        shl     b, t
                        mov     c, Fa                   'c := Farbe auf Position des Punktes in der Long-Variablen 
                        and     c, #%11
                        shl     c, t
AdrPix_ret{a,b,c}
ColPix_ret{b,c}         ret


DAT                  {{ Pixeladresse horizontal inkrementieren }}

AdrInH{a,b,c,e,Sp}
                        tjz     e, AdrInH_ret

                        sar     e, #31 nr,wz
              if_z      rol     c, #2
              if_nz     ror     c, #2
              if_z      rol     b, #2 wc
              if_nz     ror     b, #2 wc
              if_c      sumnz   a, #iLong
                        sumnz   Sp,#1

AdrInH_ret{a,b,c,Sp}    ret


DAT                  {{ Pixeladresse vertikal inkrementieren }}

AdrInV{a,f,Ze}
                        cmps    f, #0 wc,wz
              if_nz     sumc    a, #Nx/16*iLong         'C=0/1=add/sub
              if_nz     sumc    Ze,#1                   'C=0/1=add/sub
        
AdrInV_ret{a,Ze}        ret

        
DAT                  {{ Pixel setzen }}

SetPix{a,b,c,Sp,Ze,Fa}  jmpret  Dsp_Fun,Dsp_Ret

                        cmp     Sp,#Nx wc
              if_c      cmp     Ze,#Ny wc
              if_nc     jmp     SetPix_ret

                        test    Fa,#%11<<2 wc
                        rdlong  t, a
                        andn    t, b
              if_nc     xor     t, c
                        wrlong  t, a
                        
SetPix_ret              ret


CON      {{ Hintergrund-Prozeß "Zahlen" }}


DAT                  {{ Display-Funktionen "IdxToStr,IntToStr,FixToStr,FltToStr" }}

Dsp_IdxToStr            call   #ParToReg
                        mov     Vz,#"0"                
                        jmp    #IntToStr


Dsp_IntToStr            call   #ParToReg
        if_nz           abs     Za,Za wc
        if_nz_and_c     mov     Vz,#"-"              
                        jmp    #IntToStr


Dsp_FixToStr            call   #ParToReg
                        sub     Pk,#1
        if_nz           abs     Za,Za wc
        if_nz_and_c     mov     Vz,#"-" 
                        jmp    #FixToInt


Dsp_FltToStr            call   #ParToReg
                        sub     Pe,#3
                        sub     Pk,#4
                        shl     Za,#1 wc
              if_c      mov     Vz,#"-" 
                       {jmp    #FltToFix}


DAT                  {{ Gleitkommazahl in Festpunktzahl umwandeln }}

FltToFix {Eingang: Za | Ausgang: Za,De}

                        'Grundlage (Ma=Mantisse,Ex=Exponent):  
                        'Za = Ma * 2^Ex
                        '   = Ma * 10^(Ex*lg2)
                        '   = Ma * 10^(De.f)
                        '   = Ma * 10^f * 10^De

                        cmp     Za,#0   wc,wz                  
        if_nz           cmpsub  Za,c255 wc,wz
        
        if_nz_and_c     shr     Za,#1
        if_nz_and_c     mov     Ez,#NaN                 'Za = NaN      = ±a.bcNde
        if_z_and_nc     mov     Ez,#Zer                 'Za = Zero     = ±0.00Z00
        if_z_and_c      mov     Ez,#Inf                 'Za = Infinity = ±0.00I00
        if_z_or_c       jmp    #IntToStr{Za}

                        mov     De,Za                   'De := Exponent         (±7.0)
                        shr     De,#24 wz
                        sub     De,#126{!}              
                        shl     Za,#8                   'Za := Mantisse         (0.24+4)
              if_nz     add     Za,#1
                        ror     Za,#1
                        shr     Za,#4
              if_z      shl     Za,#1

              if_nz     mov     Ez,#Num                 'Za = Normalized   = ±a.bcEde
              if_z      mov     Ez,#DnN                 'Za = Denormalized = ±a.bcDde

                        'Berechnung: Ex*lg2 = De.f

                        abs     b, De wc                'De.f := lg2(±.31)*De(8.0)
                        negc    a, clg2
                        mov     n, #8
                        call   #aMULb
                        mov     De,a                    'De := int(De.f)        (±7.0)
                        sar     De,#24                  'f  := frc(De.f)        (0.32)
                        mov     f, a
                        shl     f, #8
                        shr     b, #24
                        add     f, b

                        'Berechnung: Ma * 10^f = Za

                        mov     a, Za                   'Za := Za * 10^f        (4.28)
                        call   #aMULexp10f              
                        mov     Za,a
                                            
                        shr     Za,#28 nr,wz            'Za := Za * 10 falls 0.5 <= Za < 1 und Za = normalisiert 
              if_z      cmp     Ez,#Num wz              
              if_z      shl     Za,#2
              if_z      add     Za,a
              if_z      shl     Za,#1
              if_z      sub     De,#1


DAT                  {{ Festpunktzahl in Ganzzahl umwandeln }}

FixToInt {Eingang: Za,De,Bk,Dk,Pk | Ausgang: Za}

                        mov     b, Za                   'Za := Ganzzahliger Anteil
                        shr     Za,Bk                   'b  := Gebrochener Anteil
                        neg     t, Bk
                        shl     b, t

                        mov     n, Dk wz
              if_z      jmp    #FixToInt_1
              
                        :repeat_1                       'Za := rnd(Za.b * 10^Dk)
                        shl     b, #1 wc
                        rcl     Za,#1
                        mov     d, b
                        mov     c, Za
                        shl     b, #1 wc
                        rcl     Za,#1
                        shl     b, #1 wc
                        rcl     Za,#1
                        add     b, d  wc
                        addx    Za,c
                        djnz    n, #(:repeat_1)
                        
FixToInt_1              jmpret Dsp_Fun,Dsp_Ret

                        shl     b, #1 wc                
              if_c      add     Za,#1
                        
                        cmp     Ty,#%111<<5 wc,wz       'Gleitkommazahl behandeln
              if_b      jmp    #IntToStr

                        mov     a, #1                   'a := 10^(Dk+1) 
                        mov     n, Dk                   'b := 10^Dk
                        add     n, #1                   
                        :repeat_2                                                      
                        shl     a, #1                                       
                        mov     b, a
                        shl     a, #2
                        add     a, b
                        djnz    n, #(:repeat_2)
                        shr     b, #1

                        cmp     Za,a wc,wz              'Rundungsüberlauf ( Za = 10^(Dk+1) ) korrigieren
              if_ae     mov     Za,b
              if_ae     add     De,#1                   
                                                                                                                   
                        mov     n, #2                   'Exponent hinzufügen
                        :repeat_3
                        shl     Za,#1                   'Za := 100 * Za + De
                        mov     t, Za
                        shl     Za,#2
                        add     Za,t
                        djnz    n, #(:repeat_3)

                        mov     t, #Exponent wz
        if_z            add     De,#100                 'Exponent als 10er-Komplement-Wert         
        if_z            cmpsub  De,#100
        if_nz           abs     De,De        wc         'Exponent als Absolutwert
        if_nz_and_c     mov     Ez,#"÷"
                        add     Za,De                    
             

DAT                  {{ Ganzzahl in String umwandeln }}

IntToStr {Eingang: Za,Pa,Pe,Pk,Ps,Ez,Vz | Ausgang: Ergebnisstring}

                        mov     t, #0                   'Null-Byte des Ergebnisstrings schreiben
                        wrbyte  t, Pa
                        sub     Pa,#iByte                   

                        mov     d, c10            
                        mov     n, #28
                        
IntToStr_1              jmpret Dsp_Fun,Dsp_Ret

                        tjz     n, #IntToStr_2          'Divisor justieren
                        :repeat
                        cmpsub  Za,d  nr,wc
              if_nc     shr     d, #1
              if_nc     djnz    n, #(:repeat)
                 
IntToStr_2              mov     t, n  wc                'Division durchführen
                        add     t, #1
                        :repeat
              if_c      sub     Za,d
              if_nc     cmpsub  Za,d  wc
                        rcl     Za,#1 wc
                        djnz    t, #(:repeat)

                        mov     t, Za                   't  := Za mod 10
                        rcr     t, #1                                                       
                        shr     t, n                                                        
                        mov     a, t                    'a  := Zifferzeichen(t)                           
                        add     a, #"0"                        
                        shl     t, n
                        shl     t, #1
                        xor     Za,t                    'Za := Za div 10

IntToStr_3              cmp     Pa,Pe wz                'Exponentzeichen in den Ergebnisstring schreiben
              if_e      wrbyte  Ez,Pa
              if_e      sub     Pa,#iByte

                        cmp     Pa,Pk wz                'Kommazeichen in den Ergebnisstring schreiben
              if_e      mov     t, #Komma               
              if_e      wrbyte  t, Pa
              if_e      sub     Pa,#iByte
                        
                        wrbyte  a, Pa                   'Zifferzeichen in den Ergebnisstring schreiben
                        sub     Pa,#iByte

                        testn   Za,#0 wz
              if_z      cmp     Pa,Pk wc,wz             'Vorkommanull sowie Nachkommanullen berücksichtigen                   
              if_ae     jmp    #IntToStr_1

                        :repeat
                        cmp     Pa,Ps wc
              if_b      jmp    #Dsp_Funktion_Ready
                        wrbyte  Vz,Pa                   'Vorzeichen in den Ergebnisstring schreiben 
                        sub     Pa,#iByte                   
                        and     Vz,#%00110000           'Vorzeichen in Füllzeichen umwandeln
                        jmp    #(:repeat)               'Füllzeichen in den Ergebnisstring schreiben
                        

DAT                  {{ Funktionsparameter einlesen }}

ParToReg {Eingang: DspPar | Ausgang: Za,Bk,Dk,Pa,Pe,Pk,Ps,Vz,Z-Flag}

                        mov     t, aDspPar              
                        rdlong  Za,t                    'Za := Zahl
                        add     t, #iLong                                                 
                        rdbyte  Pa,t                    'Pa := Anzahl aller darzustellender Zeichen     
                        add     t, #iByte
                        rdbyte  Dk,t                    'Dk := Anzahl dezimaler Nachkommastellen
                        add     t, #iByte               
                        rdbyte  Bk,t                    'Bk := Anzahl binärer Nachkommastellen
                        add     t, #iByte                                         
                        rdbyte  Ty,t                    'Ty := Zahlentyp
                        add     t, #iByte                                         
                        rdlong  Ps,t                    'Ps := Zeiger auf den Anfang des Ergebnisstrings
                        
                        add     Pa,Ps                   'Pa := Zeiger auf die aktuelle Zeichenposition
                        mov     Pe,Pa                   'Pe := Zeiger auf die Exponentposition
                        mov     Pk,Pa                   'Pk := Zeiger auf die Kommaposition
                        sub     Pk,Dk
                        
                        test    Ty,#1<<5 wz             'Z  := 1=ohne / 0=mit Vorzeichen
              if_z      mov     Vz,#" "                 'Vz := Vorzeichensymbol
              if_nz     mov     Vz,#Positiv
              if_nz     shl     Za,Ty                   'Vorzeichenerweiterung auf 32 Bit
              if_nz     sar     Za,Ty

ParToReg_ret            ret


DAT                  {{ a × b }}

aMULb                   mov     c, #0                   'a.b := a(Vz+Cy+ia.fa) * b(ib.fb)
                        :repeat                         '       mit
                        sar     c, #1 wc                '       n = ib+fb für ib > 0
                        rcr     b, #1 wc                '       n =  1+fb für ib = 0
              if_c      adds    c, a
                        djnz    n, #(:repeat)
                        mov     a, c
                        
aMULb_ret               ret 


DAT                  {{ a × 10^f }}

aMULexp10f              jmpret  Dsp_Fun,Dsp_Ret

                        mov     t, f                    'a := a * Exp10(f) = a * 10^f
                        mov     n, #27
                        :repeat
                        shl     t, #1 wc,wz
        if_nc_and_nz    djnz    n, #(:repeat)
        if_nc           jmp    #aMULexp10f_ret
              
                        neg     i, n                    'i := Anzahl der Nullen vor der ersten 1 in f      
                        add     i, #27
                        mov     t, a                    'a := rnd(a*(1+2^-i))   (4.28)
                        shr     t, i
                        shr     t, #1 wc
                        addx    a, t
                        shl     i, #sLong               'f := f - lg(1+2^-i)    (0.32)
                        add     i, aLogTab
                        rdlong  t, i
                        sub     f, t
                        jmp    #aMULexp10f
              
aMULexp10f_ret          ret


DAT                  {{ Konstanten, Variablen }}

cBitMapN                long    BitMapN
cBitMapNdivZeilen       long    BitMapN/(Ny/8)

c10                     long    10<<28
c255                    long    255<<24
clg2                    long    $268826A1 {/2^31 = 0.301029995549 ≈ 0.301029995664 = lg2 }

aChrTab                 long    0                       'Konstante Adressen
aBitMap                 long    0
aLogTab                 long    0
aDspPar                 long    0
aDspFun                 long    0

Dsp_Fun                 long    0                       'Sprungadresse für den Hintergrund-Prozeß 
Dsp_Ret                 long    0                       'Sprungadresse für den Vordergrund-Prozeß
Dsp_Tim                 long    0                       'Zähler für die Zeitüberwachung des Hintergrund-Prozesses

Ze                      long    0                       'Zeile
Sp                      long    0                       'Spalte
Fa                      long    0                       'Stiftfarbe

Za                      long    0                       'Zahl (Binär/Dezimal)
De                      long    0                       'Dezimalexponent
Ty                      long    0                       'Zahlentyp
Bk                      long    0                       'Anzahl der binären Nachkommastellen
Dk                      long    0                       'Anzahl der dezimalen Nachkommastellen
Ps                      long    0                       'Zeiger auf die Startposition des Ergebnisstrings
Pa                      long    0                       'Zeiger auf die aktuelle Position
Pk                      long    0                       'Zeiger auf die Kommaposition
Pe                      long    0                       'Zeiger auf die Exponentposition
Ez                      long    0                       'Exponentzeichen
Vz                      long    0                       'Vorzeichen

t                       long    0                       'Hilfsvariablen
{
a                       long    0
b                       long    0
c                       long    0
d                       long    0
e                       long    0
f                       long    0
i                       long    0
j                       long    0
n                       long    0
}

                        fit     496-28
                        
                        
                                                       