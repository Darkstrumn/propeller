{{ 20.09.2013

   Hartley-Transformation(HT) mit Berechnung des Fourier-Spektrums(SP)

   ======================================
   Copyright(C) 2008..2013 by G. Pillmann
   ======================================

var

  Q, H, Re, Im, Be, Ph: array [0..n-1] mit n=2^p

Aufruf

  HT(0,n)
  HTsp(n)

procedure HT(o,n)

    if
    n = 2
    then

      H[o+0]:= (q[rev(o+0,p)] + q[rev(o+1,p)]) / 2
      H[o+1]:= (q[rev(o+0,p)] - q[rev(o+1,p)]) / 2

    else

    if
    n = 4
    then

      H[o+0]:= q[rev(o+0,p)] + q[rev(o+2,p)] + q[rev(o+1,p)] + q[rev(o+3,p)] / 4
      H[o+1]:= q[rev(o+0,p)] - q[rev(o+2,p)] + q[rev(o+1,p)] - q[rev(o+3,p)] / 4
      H[o+2]:= q[rev(o+0,p)] + q[rev(o+2,p)] - q[rev(o+1,p)] - q[rev(o+3,p)] / 4
      H[o+3]:= q[rev(o+0,p)] - q[rev(o+2,p)] - q[rev(o+1,p)] + q[rev(o+3,p)] / 4

    else

      a:= o
      b:= o+n/2
      
      HT(a,n/2)
      HT(b,n/2)
      
      HTab(a,b,n/2)

    end

end


procedure HTab(a,b,n)

    H[a]':= (H[a] + H[b]) / 2
    H[b]':= (H[a] - H[b]) / 2
                  
    z2:= 180°/n

    for
    i:= 1 to n/2 - 1
    do begin

       x:=  H[b+i]
       y:= -H[b+n-i]
       z:=  i*z2
       Cordic_z0
       x = H[b+i]*Cos[i*z2] + H[b+n-i]*Sin[i*z2]
       y = H[b+i]*Sin[i*z2] - H[b+n-i]*Cos[i*z2]
       z = 0

       H[a+i]':= (H[a+i] + x) / 2
       H[b+i]':= (H[a+i] - x) / 2

       H[a+n-i]':= (H[a+n-i] + y) / 2
       H[b+n-i]':= (H[a+n-i] - y) / 2

    end
                
    H[a+n/2]':= (H[a+n/2] + H[b+n/2]) / 2
    H[b+n/2]':= (H[a+n/2] - H[b+n/2]) / 2

end


procedure HTsp(n)

  Re[0]:= H[0]
  Im[0]:= 0
  Be[0]:= abs(Re[0])
  Ph[0]:= if Re[0]<0 then 180° else 0°
    
  for
  i:= 1 to n/2-1
  do begin

    Re[i]:= (H[i] + H[n-i]) / 2
    Im[i]:= (H[i] - H[n-i]) / 2

    x:= Re[i]
    y:= Im[i]
    z:= 0
    Cordic_y0
    x = Be[i]
    y = 0
    z = Ph[i]
                 
    Re[n-i]:=  Re[i]
    Im[n-i]:= -Im[i]
    Be[n-i]:=  Be[i]
    Ph[n-i]:= -Ph[i]

  end

  Re[n/2]:= H[n/2]        
  Im[n/2]:= 0
  Be[n/2]:= abs(Re[n/2])
  Ph[n/2]:= if Re[n/2]<0 then 180° else 0°           

end
  
}}


CON {definiert}
  
  Sp = 0                        'Ausgabe der HT als Spektrum               Be/Ph
  Fo = 1                        'Ausgabe der HT als Fourier-Transformierte Re/Im
  Ha = 2                        'Ausgabe der HT als Hartley-Transformierte We

  Ge{ä} = 16 {8..21}            'Genauigkeit der Berechnung in Bits

  sWord = 1
  sLong = 2
  iWord = 1<<sWord
  iLong = 1<<sLong


VAR { Im Hauptprogramm zu deklarieren
  
  long H [NH]                    ±B.(31-B) Hartley-Werte                                 {± = Bit 31}
                                
                                           oder
                                                      
         [   0..NH/2  ]          ±B.(31-B) Fourier-Beträge                               {± = Bit 31}
                                           und
         [NH-1..NH/2+1]          ±8.23     Fourier-Phasen (-180° <= Phase < +180°)       {± = Bit 31}

                      
  word Q [NQ]                    ±B        Eingangsdaten mit  Vorzeichen                 {-2^B..2^B-1}
                                           oder
                                  B        Eingangsdaten ohne Vorzeichen                 {   0..2^B-1}
                         
  word s                                   Startadresse der Meßwerte im Ringpuffer       {   0..NQ-1 } }

                   
PUB Init (ard_H, ard_Q, adr_s, val_cfg{=$TTABCD}) | NC,i          

 { Initialisieren der Hartley-Transformation } 

  NH            := ard_H >> 16
  NHsub1        := NH - 1
  NHdiv2        := NH >> 1
  NHdiv2sub1    := NHdiv2 - 1
  NQ            := ard_Q >> 16
  NC            := val_cfg >> 4 & $F

  TrigPin       := val_cfg >> 16 & $1F 
  TrigMsk       := |< TrigPin
  dira[TrigPin] := 1 
       
  aH            := ard_H
  aQ            := ard_Q
  as            := adr_s
  HTcfg         := val_cfg

  Cogs := -1
  repeat i from 0 to NC-1
    Cogs.byte[i] := cognew ( @Hartley_Transformation, i << sLong )


PUB Stop | Cog,i

 { Anhalten der in Init gestarteten Cogs } 

  repeat i from 0 to 3
    if (Cog := Cogs.byte[i]) <> 255
      cogstop(Cog)

  
PUB Trig

 { Starten der Hartley-Transformation } 

  outa[TrigPin] := 1
  outa[TrigPin] := 0

    
PUB Wait

 { Warten auf das Ende der Hartley-Transformation }
  
  waitpne( TrigMsk, TrigMsk, 0 )

    
PUB Sync

 { Synchronisieren auf das Ende der Hartley-Transformation }
  
  waitpeq( TrigMsk, TrigMsk, 0 )
  waitpne( TrigMsk, TrigMsk, 0 )

    
PUB We (i)

  {Wert der Hartley-Transformierten, i=0..NH-1, ±B.(31-B) }

  Result := long [aH] [i]
  

PUB Be (i)

  {Betrag der Fourier-Transformierten, i=0..NH-1, +B.(31-B) }

  if i =< NHdiv2
    Result := || long [aH] [ i         ]
  else
    Result := || long [aH] [-i & NHsub1] {=[NH-i]} 
  

PUB Ph (i)

  {Phase der Fourier-Transformierten, i=0..NH-1, ±8.23 Bit, -180° <= Phase <= +180°}

  if i & NHdiv2sub1 == 0
      Result :=  (long [aH] [i] < 0) & c180deg
  else
    if i < NHdiv2
      Result :=   long [aH] [-i & NHsub1] {=[NH-i]}
    else
      Result := - long [aH] [ i         ]
 

PUB Re (i)

  {Realteil der Fourier-Transformierten, i=0..NH-1, ±B.(31-B) }

  Result := long [aH] [i] ~> 1 + long [aH] [-i & NHsub1] {=[NH-i]} ~> 1
  

PUB Im (i)

  {Imaginärteil der Fourier-Transformierten, i=0..NH-1, ±B.(31-B) }

  Result := long [aH] [i] ~> 1 - long [aH] [-i & NHsub1] {=[NH-i]} ~> 1
  

DAT                   { Schnelle Hartley-Transformation rekursiv durchführen }

Hartley_Transformation

cAtan                  'Cordic-Arcustangens-Tabelle, ±2+6.23 Bit=Atan(2^0)..Atan(2^-16), gerundet, in Grad, nach Volder 1959  

                        jmp     #HT_start               '16800000=45°                   p=3        
                        long    $0D485399               '0B400000=22.5°                 p=4
                        long    $0704A3A0               '05A00000=11.25°                p=5
                        long    $03900089               '02D00000= 5.625°               p=6
                        long    $01C9C553               '01680000= 2.8125°              p=7
                        long    $00E51BCA               '00B40000= 1.40625°             p=8
                        long    $0072950D               '005A0000= 0.703125             p=9
                        long    $00394B6C               '002D0000= 0.3515625            p=10
                        long    $001CA5D3               '00168000= 0.17578125           p=11
                        long    $000E52ED               '000B4000= 0.087890625          p=12
                        long    $00072977               
                        long    $000394BB              
                        long    $0001CA5E             
                        long    $0000E52F              
                        long    $00007297               
                        long    $0000394C              
                        long    $00001CA6

                       'Kc = π(k=0,16)√(1+4^-k) = 1,64676025403, 16-Bit-Näherung für 1/Kc: $0.9B75 für k=8..
                       
                        long    $00000E53
                        long    $00000729
                        long    $00000395
                        long    $000001CA
                        long    $000000E5
                        
                       'Kc = π(k=0,21)√(1+4^-k) = 1,64676025807
                       
c45deg                  long    $16800000
c90deg                  long    $16800000*2
c180deg                 long    $16800000*4    


DAT                  

HT_start                mov     cAtan,c45deg            'Sprungbefehl aus der Atan-Tabelle entfernen
                                           
                        mov     P, #0                   'P := {3..12} = ld(NH={8,16..4096})
                        mov     t, NH
                        :repeat
                        shr     t, #1 wz
              if_nz     djnz    P, #(:repeat)           'P := (32-P)

                        mov     D, HTcfg                'D := {0..2}
                        and     D, #$F    
                        
                        mov     C, HTcfg                'C := {0..2}  = ld(NC={1,2,4})
                        shr     C, #4+1
                        and     C, #$7

                        mov     B, HTcfg                'B := {1..16}
                        shr     B, #8
                        and     B, #$F wz
                        muxz    B, #$10
                        xor     B, #$1F                 'B := (31-B)

                        mov     A, HTcfg                'A := {0..7}
                        shr     A, #12
                        and     A, #$F
                        sub     A, #Ge                  'A := (32-Ge+R)

                        or      dira,TrigMsk            'Trigger einrichten


HT_0                    andn    outa,TrigMsk            'Startsignal abwarten
                        waitpne TrigMsk,TrigMsk             
                        waitpeq TrigMsk,TrigMsk             
                        rdword  s, as                   'Startadresse der A/D-Werte in Q holen
                        or      outa,TrigMsk

                        neg     np,P                    'np := P-C = ld(NH/NC)
                        sub     np,C

                        mov     t, par                  'Verteilung der Meßwerte auf die Cogs bestimmen aus Cognummer(=0..3) und Coganzahl(=1,2,4) 
                        shr     t, #sLong               '  t := Cognummer     
                        shr     t, #1 nr,wc,wz          '  n := NH/NC     
                        mov     n, NH                   '  o := 0|n|2n|3n für t=0|1|2|3
                        shr     n, C                    
                        mov     o, #0                   
              if_c      add     o, n
              if_nz     add     o, n                   
              if_nz     add     o, n                    

                        neg     rs,#2                   'Returnstack (30 Bit tief, 0|1=Rücksprung hinter HT_a|HT_b) initialisieren ($FFFFFFFE = -2)

                        mov     i0,#0           
                        mov     i2,#iLong
                   
                       'Rekursion terminieren
HT_a
HT_b                    test    n, #4 wc
              if_nc     jmp     #HT_n


HT_4                    movd   :q, #q4                  
                        add     o, #4
                        mov     k, #4
                        :repeat
                        subx   :q, #511                 'Carry muß für "subx" gesetzt sein
                        sub     o, #1 
                        mov     t, o
                        rev     t, P                    '(32-P)
                        add     t, s
                        cmpsub  t, NQ 
                        shl     t, #sWord
                        add     t, aQ
                       {nop}  
                       {nop}  
                        rdword  t, t
                        shl     t, B                    '(31-B)
                        sar     t, #2
                     :q mov     0, t
                        djnz    k, #(:repeat)           'q[rev(o+3..0)]/4

                        mov     H0,q0
                        adds    H0,q2
                        mov     H1,H0

                        mov     H2,q0
                        subs    H2,q2
                        mov     H3,H2

                        mov     t, q1
                        adds    t, q3
                        adds    H0,t
                        subs    H1,t
                        
                        mov     t, q1
                        subs    t, q3
                        adds    H2,t
                        subs    H3,t

                        mov     t, o                    'Die Vertauschung von q2 und q1 muß rückgängig gemacht werden, da die Eingangsdaten vertauscht werden!
                        shl     t, #sLong
                        add     t, aH

                        wrlong  H0,t                    'H[o+0]:= ( q[rev(o)] + q[rev(o+2)] + q[rev(o+1)] + q[rev(o+3)] )/4
                        add     t, #iLong
                       {nop}  
                        wrlong  H1,t                    'H[o+1]:= ( q[rev(o)] + q[rev(o+2)] - q[rev(o+1)] - q[rev(o+3)] )/4
                        add     t, #iLong
                       {nop}  
                        wrlong  H2,t                    'H[o+2]:= ( q[rev(o)] - q[rev(o+2)] + q[rev(o+1)] - q[rev(o+3)] )/4
                        add     t, #iLong
                       {nop}  
                        wrlong  H3,t                    'H[o+3]:= ( q[rev(o)] - q[rev(o+2)] - q[rev(o+1)] + q[rev(o+3)] )/4
                        
                                              
HT___ret                sar     rs,#1 wc
HT_a_ret      if_nc     ret       
HT_b_ret      if_c      ret       
               
                       'Rekursion durchführen 

HT_n                    sub     np,#1
                        shr     n, #1                   'n:= n/2 (Variable geändert)
                        shl     rs,#1
                        call    #HT_a{o,n/2}
                        add     o, n                    'o:= o+n (Variable geändert)
                        rol     rs,#1
                        call    #HT_b{o+n/2,n/2}
                        sub     o, n                    'o:= o-n (Variable wiederhergestellt)
                        call    #HTab{o,n/2,i0,i2}
                        shl     n, #1                   'n:= n*2 (Variable wiederhergestellt)
                        add     np,#1
                        
                        add     rs,#2 nr,wz
              if_nz     jmp     #HT___ret

                       'Ergebnisse der Parallelverarbeitung zusammenführen 

                        mov     i0,par                  'i0:= Cognummer*iLong
                        shl     i2,C                    'i2:= Coganzahl*iLong

                        cmp     i2,#(2*iLong) wc,wz
              if_b      jmp     #(:i2_eq_1)
              if_e      jmp     #(:i2_eq_2)
              
                        :i2_eq_4
                        
                        mov     o, #0                   'o:=0 muß ausgeführt werden, da o für jeden Cog unterschiedlich war!
                        call    #HTab{0,n/4,i0,i2}
                        mov     o, NHdiv2
                        call    #HTab{n/2,n/4,i0,i2}
                        shl     n, #1
                        add     np,#1
                        
                        :i2_eq_2
                        
                        mov     o, #0                   'o:=0 muß ausgeführt werden, da o für jeden Cog unterschiedlich war!
                        call    #HTab{0,n/2,i0,i2}
                       {shl     n, #1
                        add     np,#1}
                        
                        :i2_eq_1
                        
                        cmp     D, #Sp wz
              if_e      call    #HTsp{i0,i2}
                        jmp     #HT_0
                         

DAT                   { b-Folge verschieben, b- und a-Folge dehnen, b- und a-Folge addieren, Cordic-Verfahren nach Volder }


                       'i-Schleife: Adressen initialisieren 

HTab                    mov     t, n                    
                        shl     t, #sLong
                        
                        mov     ai,o                    
                        shl     ai,#sLong                     
                        add     ai,aH
                        mov     aj,ai
                        add     aj,t
                        mov     bi,aj
                        mov     bj,bi
                        add     bj,t
                        
                        add     ai,i0
                        sub     aj,i0
                        add     bi,i0
                        sub     bj,i0

                       'i-Schleife: Winkel initialisieren 
                  
                        mov     z2,c180deg              'z2:= 180°/n
                        sar     z2,np

                        mov     t, i0
                        shr     t, #sLong
                        shr     t, #1 nr,wc,wz
                        mov     zi,#0
              if_c      adds    zi,z2
              if_nz     adds    zi,z2
              if_nz     adds    zi,z2

                        cmp     i2,#iLong wz
              if_nz     shl     z2,C


HTab0                   cmp     bi,aj wz                'i=0
              if_ne     jmp     #HTab2                  
                                                        
                        rdlong  H0,ai
                        sar     H0,#1                   'H[a]/2
                        mov     H1,H0
                        rdlong  t, bi
                        sar     t, #1                   'H[b]/2
                        adds    H0,t
                        wrlong  H0,ai                   'H[a]:= (H[a] + H[b])/2
                        subs    H1,t
                       {nop}  
                        wrlong  H1,bi                   'H[b]:= (H[a] - H[b])/2


HTab1                   add     ai,i2                   'inc(i)
                        sub     aj,i2
                        add     bi,i2
                        sub     bj,i2
                        adds    zi,z2


HTab2                   cmp     bi,bj wc,wz             'i>=n/2
              if_ae     jmp     #HTab3
              
                        mov     z, zi
                        
                        rdlong  y, bj                   'y:= -H[b+n-i]/2
                        neg     y, y
                        sar     y, #(1+1)               'und Überlaufbit einrichten
                        
                        rdlong  x, bi                   'x:=  H[b+i]/2
                        sar     x, #(1+1)               'und Überlaufbit einrichten

                        movs   :Atan,#cAtan
                        mov     k, #(Ge+1)
                        :repeat
                        cmps    z, #0 wc                'c:= z < 0
                        mov     tx,x                    'x:= x -(nc) y*2^-k
                        mov     ty,y                    'y:= y +(nc) x*2^-k
                        sar     tx,:Atan                'z:= z -(nc) atan(2^-k)
                        sar     ty,:Atan
                        sumnc   x, ty                   'x = Kc * (x*cos(z) - y*sin(z)) 
                        sumc    y, tx                   'y = Kc * (y*cos(z) + x*sin(z))
              :Atan     sumnc   z, 0                    'z = 0              
                        add    :Atan,#1
                        djnz    k, #(:repeat)

                        rdlong  H0,ai
                        sar     H0,#1                   'H[a+i]/2
                        mov     H1,H0

                        neg     t, x                    'x:= x * (1/Kc ≈ $0.9B74F = $0.A0050-$0.04901 = 0,60725403074646 | 0,23 ppm)  
                        sar     t, #4
                        adds    t, x
                        sar     t, #2
                        adds    t, x
                        sar     t, #2
                        subs    t, x
                        sar     t, #3
                        subs    t, x
                        sar     t, #3
                        subs    t, x
                        sar     t, #3
                        adds    t, x
                        sar     t, #2
                        adds    x, t
                       {sar     x, #1}                  'Überlaufbit entfernen, indem "sar" nicht ausgeführt wird            
                        
                        adds    H0,x
                        wrlong  H0,ai                   'H[a+i]  := (H[a+i] + x)/2
                        subs    H1,x
                       {nop}  
                        wrlong  H1,bi                   'H[b+i]  := (H[a+i] - x)/2
                        
                       {nop}  
                       {nop}
                         
                        rdlong  H0,aj
                        sar     H0,#1                   'H[a+n-i]/2
                        mov     H1,H0

                        neg     t, y                    'y:= y * (1/Kc ≈ $0.9B74F = $0.A0050-$0.04901 = 0,60725403074646 | 0,23 ppm)  
                        sar     t, #4
                        adds    t, y
                        sar     t, #2
                        adds    t, y
                        sar     t, #2
                        subs    t, y
                        sar     t, #3
                        subs    t, y
                        sar     t, #3
                        subs    t, y
                        sar     t, #3
                        adds    t, y
                        sar     t, #2
                        adds    y, t
                       {sar     y, #1}                  'Überlaufbit entfernen, indem "sar" nicht ausgeführt wird            
                        
                        adds    H0,y
                        wrlong  H0,aj                   'H[a+n-i]:= (H[a+n-i] + y)/2   
                        subs    H1,y
                       {nop}  
                        wrlong  H1,bj                   'H[b+n-i]:= (H[a+n-i] - y)/2

                        jmp     #HTab1


HTab3         if_ne     jmp     #HTab_ret               'i=n/2

                        rdlong  H0,ai
                        sar     H0,#1                   'H[a+n/2]/2
                        mov     H1,H0
                        rdlong  t, bi
                        sar     t, #1                   'H[b+n/2]/2
                        adds    H0,t
                        wrlong  H0,ai                   'H[a+n/2]:= (H[a+n/2] + H[b+n/2])/2
                        subs    H1,t
                       {nop}  
                        wrlong  H1,bi                   'H[b+n/2]:= (H[a+n/2] - H[b+n/2])/2 


HTab_ret                ret


DAT                   { Fourier-Spektrum aus der Hartley-Transformierten berechnen }


HTsp                    mov     hi,aH
                        mov     hj,NH
                        shl     hj,#sLong
                        add     hj,aH
                        
                        add     hi,i0
                        sub     hj,i0


HTsp0                   cmp     hi,aH wz
              if_ne     jmp     #HTsp2                  'i=0
             
                       {Realisiert in Spin}             'Re[0] = H[0]
                                                        'Im[0] = 0
                                                        'Be[0] = abs(H[0])
                                                        'Ph[0] = if H[0]<0 then 180° else 0°

HTsp1                   add     hi,i2                   'inc(i)
                        sub     hj,i2
                        
HTsp2                   cmp     hi,hj wc,wz             'i>=n/2
              if_ae     jmp     #HTsp3

                        rdlong  x, hi                   'x:= Re[i]:= (H[i] + H[n-i])/2
                        sar     x, #1                   'y:= Im[i]:= (H[i] - H[n-i])/2
                        mov     y, x                    'x:= Be[i]                            
                        rdlong  t, hj                   'z:= Ph[i]                                          
                        sar     t, #1                                          
                        adds    x, t                           
                        subs    y, t                    
                        call    #XYtoBePh                      
                        wrlong  x, hi                                                            
                       {nop} 
                       {nop} 
                        wrlong  z, hj                   
                                                 
                       {Realisiert in Spin}             'Re[n-i] =  Re[i]
                                                        'Im[n-i] = -Im[i]
                                                        'Be[n-i] =  Be[i]
                                                        'Ph[n-i] = -Ph[i]
                        jmp     #HTsp1
                                                 

HTsp3         if_ne     jmp     #HTsp_ret               'i=n/2
                        
                       {Realisiert in Spin}             'Re[n/2] = H[n/2]
                                                        'Im[n/2] = 0
                                                        'Be[n/2] = abs(H[n/2])
                                                        'Ph[n/2] = if H[n/2]<0 then 180° else 0°     

HTsp_ret                ret


DAT                   { Real- und Imaginärteil mittels Cordic-Vektorisierung in Betrag und Phase umwandeln }
                        
XYtoBePh                mov     z, #0                   'z:= 0°

                        abs     t, y                    'y:= if abs(y)<2^-(Ge-Ra) then 0 else y
                        shr     t, A wz                 '(32-Ge+Ra)
              if_z      mov     y, #0

                        abs     t, x                    'x:= if abs(x)<2^-(Ge-Ra) then 0 else x
                        shr     t, A wz                 '(32-Ge+Ra)
              if_z      mov     x, #0

                        or      x, y nr,wz
              if_z      jmp     #XYtoBePh_ret


                        sar     y, #31 nr,wz            'nz:= y < 0
                        abs     x, x wc                 ' c:= x < 0
              if_c      neg     y, y
              if_c      negnz   z, c180deg              'z:= if x<0 then -180° else +180°

                        sar     x,#1                    'Überlaufbit einrichten
                        sar     y,#1
              
                        movs   :Atan,#cAtan
                        mov     k, #(Ge+1)
                        :repeat                 
                       {cmps    y, #0 wc}               'c:= y < 0
                        mov     tx,x                    'x:= x -(c) y*2^-k
                        mov     ty,y wc                 'y:= y +(c) x*2^-k
                        sar     tx,:Atan                'z:= z -(c) atan(2^-k)
                        sar     ty,:Atan
                        sumc    x, ty                   'x = sign(x) * Kc * √(x²+ y²)           
                        sumnc   y, tx                   'y = 0
              :Atan     sumc    z, 0                    'z = atan(y/x)              
                        add    :Atan,#1
                        djnz    k, #(:repeat)

                        neg     t, x                    'x:= x * (1/Kc ≈ $0.9B74F = $0.A0050-$0.04901 = 0,60725403074646 | 0,23 ppm)  
                        sar     t, #4
                        adds    t, x                    'x:= x * (1/Kc ≈ $0.9B75  = $0.A005-$0.0490   = 0,60725402832    | 1,80 ppm)
                        sar     t, #2
                        adds    t, x
                        sar     t, #2
                        subs    t, x
                        sar     t, #3
                        subs    t, x
                        sar     t, #3
                        subs    t, x
                        sar     t, #3
                        adds    t, x
                        sar     t, #2                   'x = √(x²+ y²) = Betrag
                        adds    x, t                    'z = atan(y/x) = Phase
                        
                       {sar     x, #1}                  'Überlaufbit entfernen, indem "sar" nicht ausgeführt wird

                        abs     t, z                    'y:= if abs(z)<2^-(Ge-Ra) then 0 else z
                        shr     t, A wz                 '(32-Ge+Ra)
              if_z      mov     z, #0 

XYtoBePh_ret            ret


DAT                   { Initialisierte Konstanten und Variablen }

Cogs                    long    0                       'ByteArray[0..3] der IDs der beteiligten Cogs {0..7,$FF}

TrigPin                 long    0                       'Auslöse- und Synchronisations-Pin für die Hartley-Transformation {0..31}
TrigMsk                 long    0                       'Maske für den TrigPin (1<<TrigPin)

NH                      long    0                       'Länge des H-Feldes
NHsub1                  long    0
NHdiv2                  long    0
NHdiv2sub1              long    0
NQ                      long    0                       'Länge des Q-Feldes

HTcfg                   long    0                       'Hartley-Konfiguration

aH                      long    0                       'Adresse des H-Feldes
aQ                      long    0                       'Adresse des Q-Feldes
as                      long    0                       'Adresse der s-Variablen


DAT                   { Reservierte Konstanten und Variablen }

A                       res     1                       'Anzahl der auszublendenden Bits {0..15}
B                       res     1                       '1er-negierte Anzahl der Bits ohne Vorzeichen für die Meßwertdarstellung {1..16}
C                       res     1                       'Zweierpotenz der Anzahl der verwendeten Cogs {0..2}
D                       res     1                       'Darstellung der Hartley-Transformierten {0=Sp,1=Fo,2=Ha}

P                       res     1                       '2er-negierte Zweierpotenz der Anzahl der zu bearbeitetenden Meßwerte {3+C..12}

rs                      res     1                       'Returnstack
np                      res     1                       'Zweierpotenz der Länge des zu bearbeitenden Teil-Feldes
n                       res     1                       'Länge des zu bearbeitenden Teil-Feldes
o                       res     1                       'Offset des zu bearbeitenden Teil-Feldes
s                       res     1                       'Offset des zu bearbeitenden Feldes

                       'Schleifenvariablen 

k                       res     1                       'k-Schleife
i0                      res     1                       'i-Schleife Startwert 
i2                      res     1                       'i-Schleife Schrittweite
z2                      res     1                       'z-Schleife Schrittweite
ai{=a+i  }              res     1                       'i-Wert auf Adresse umgerechnet
aj{=a+n-i}              res     1 
bi{=b+i  }              res     1
bj{=b+n-i}              res     1
hi{=i    }              res     1
hj{=n-i  }              res     1
zi{=z    }              res     1                       'i-Wert auf Winkel umgerechnet

                       'Hilfsvariablen 
                        
t                       res     1
x                       res     1
y                       res     1
z                       res     1
q0                      res     1
q1                      res     1
q2                      res     1
q3                      res     1
q4
H0                      res     1
H1                      res     1
H2                      res     1
H3                      res     1
tx                      res     1
ty                      res     1


                        fit     496
                                                
{
***********************************************************************************************************************
*                                                                                                                     *
* Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated        *
* documentation files (the "Software"), to deal in the Software without restriction, including without limitation     *
* the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and    *
* to permit persons to whom the Software is furnished to do so, subject to the following conditions:                  *
*                                                                                                                     *
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO    *
* THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE      *
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, *
* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE      *
* SOFTWARE.                                                                                                           *
*                                                                                                                     *
***********************************************************************************************************************
}

