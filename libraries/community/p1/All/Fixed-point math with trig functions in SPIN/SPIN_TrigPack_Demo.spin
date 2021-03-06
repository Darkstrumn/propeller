{{
┌───────────────────────────────┬───────────────────┬────────────────────┐
│ SPIN_TrigPack_Demo.spin v3.0  │ Author: I.Kövesdi │  Rel.: 17.10.2011  │
├───────────────────────────────┴───────────────────┴────────────────────┤
│                    Copyright (c) 2011 CompElit Inc.                    │               
│                   See end of file for terms of use.                    │               
├────────────────────────────────────────────────────────────────────────┤
│  This PST application shows the first Fixed-point arithmetic library   │
│ object on OBEX. The small "SPIN_TrigPack" object is a complete Fixed-  │
│ point package in spin lanquage with the basic trigonometric functions  │
│ for robot and navigatin projects. You can do ATAN2 without enlisting   │
│ extra COGs to run a full Floating-point library for that function. The │
│ object has string conversion utilities to make Fixed-point math easy in│
│ your SPIN language based applications.                                 │
│  This object contains the first True Random Number Generator (TRNG)    │
│ with the Propeller microcontroller using only SPIN code. This TRNG will│
│ repeat its sequence only after the End of Times.                       │
│                                                                        │ 
├────────────────────────────────────────────────────────────────────────┤
│ Background and Detail:                                                 │
│  32-bit Fixed-point arithmetic with SPIN is done in Qs15_16 format.    │
│ The Qvalue numbers have a sign bit, 15 bits for the integer part and 16│
│ bits for the fraction. 15 bit integer part means that the Qvalue       │
│ numbers are between -37767 and +37768. When this is a concern in your  │
│ application, take care of it by downscaling larger numbers before the  │
│ arithmetic operations, then upscale the result accordingly.            │
│                                                                        │ 
├────────────────────────────────────────────────────────────────────────┤
│ Note:                                                                  │
│  The author thanks Timmoore and Chuck Taylor for bug reports and good  │
│ suggestions.                                                           │
│                                                                        │
└────────────────────────────────────────────────────────────────────────┘
}}


CON

_CLKMODE         = XTAL1 + PLL16x
_XINFREQ         = 5_000_000

 
VAR


OBJ

'PST----------------------------------------------------------------------
PST        : "Parallax Serial Terminal"  'From Parallax Inc. v1.0

F          : "FloatMath"                 'From Parallax Inc. v1.0

'SPIN TrigPack Qs15_16 32-bit Fixed-point package-------------------------
Q          : "SPIN_TrigPack"             'v2.0 CompElit Ltd.


PUB Start_Application | a, b, c, d, e, x, y, z, done, r, t1, t2
'-------------------------------------------------------------------------
'----------------------------┌───────────────────┐------------------------
'----------------------------│ Start_Application │------------------------
'----------------------------└───────────────────┘------------------------
'-------------------------------------------------------------------------
''     Action: - Loads PST driver
''             - Initialise SPIN_TrigPack driver 
''             - Demonstrates true randomness of SPIN code 
''             - Does some fixed point test calculations 
'' Parameters: None                                 
''     Result: None                    
''+Reads/Uses: PST CONs                  
''    +Writes: None                                    
''      Calls: Parallax Serial Terminal---------->PST.Star
''                                                PST.Char
''                                                PST.Str
''                                                PST.Dec
''             SPIN_TrigPack--------------------->Most of the procedures 
'-------------------------------------------------------------------------
'Start Parallax Serial Terminal. It will launch 1 COG 
PST.Start(57600)
WAITCNT(3 * CLKFREQ + CNT)

PST.Char(PST#CS)
PST.Str(STRING("SPIN TrigPack demo started..."))
PST.Chars(PST#NL, 2)
Q.Start_Driver 
WAITCNT(CLKFREQ + CNT)

'{TRNG DEMO CODE BLOCK Selector Button, pressed ON with 1st '
PST.Str(STRING("Check True Random (left) and Pseudo random (right)"))
PST.Char(PST#NL)
PST.Str(STRING("Generators after repeated reboot of the Propeller."))
PST.Char(PST#NL)
PST.Str(STRING("Please note that both RNGs work with SPIN code only!"))

PST.Chars(PST#NL, 2)

PST.Str(STRING("     TRNG sequence     PRNG sequence"))
PST.Char(PST#NL)
PST.Str(STRING("      will change        will not"))
PST.Chars(PST#NL, 2)

a := Q.StrToQval(STRING("0.0"))
b := Q.StrToQval(STRING("1000.0"))
REPEAT 12
  c := Q.Qint(Q.Q_TRNG(a, b))     
  d := Q.Qint(Q.Q_PRNG(a, b))
  PST.Char(PST#PX)
  PST.Char(10)  
  PST.Str(Q.QvalToStr(c))
  PST.Char(PST#PX)
  PST.Char(28)
  PST.Str(Q.QvalToStr(d))
  PST.Char(PST#NL)
PST.Char(PST#NL)  

QueryReboot
'}'END OF TRNG DEMO CODE BLOCK
         
'{QVAL ARITHMETICS DEMO CODE BLOCK Selector Button, pressed ON with 1st '
PST.Char(PST#CS)
PST.Str(STRING("Check some arithmetics with Qvalues"))
PST.Chars(PST#NL, 2)

a := Q.StrToQval(STRING("3.1416"))
b := Q.StrToQval(STRING("3.1416"))
c := a + b
d := Q.QvalToStr(c)
PST.Str(STRING("Addition :         3.1416 + 3.1416 = "))
PST.Str(d)
PST.Char(PST#NL)

a := Q.StrToQval(STRING("2000.2345"))
b := Q.StrToQval(STRING("1000.1234"))
c := a - b
d := Q.QvalToStr(c)
PST.Str(STRING("Subtraction:   2000.2345-1000.1234 = "))
PST.Str(d)
PST.Char(PST#NL)

a := Q.StrToQval(STRING("3.1416"))
c := Q.Qval(4)
d := Q.Qmul(c, -a)
e := Q.QvalToStr(d)
PST.Str(STRING("Multiplication:      4 x (-3.1416) = "))
PST.Str(e)
PST.Char(PST#NL)

a := Q.StrToQval(STRING("111.11"))
b := a
c := Q.Qmul(a, b) 
d := Q.QvalToStr(c)
PST.Str(STRING("Multiplication:    111.11 x 111.11 = "))
PST.Str(d)
PST.Char(PST#NL)

a := Q.StrToQval(STRING("3.1416"))
b := Q.StrToQval(STRING("2.7183"))
c := Q.Qdiv(a, b)
d := Q.QvalToStr(c)
PST.Str(STRING("Division:          3.1416 / 2.7183 = "))
PST.Str(d)
PST.Char(PST#NL)

a := Q.StrToQval(STRING("12345.4321"))
b := Q.StrToQval(STRING("111.11"))
c := Q.Qdiv(a, b)
d := Q.QvalToStr(c)
PST.Str(STRING("Division:      12345.4321 / 111.11 = "))
PST.Str(d)
PST.Chars(PST#NL, 2)

PST.Str(STRING("Calculate the following with Qdiv and Qmul:"))
PST.Chars(PST#NL, 2)

a := Q.StrToQval(STRING("12345.6789"))
b := Q.StrToQval(STRING("23456.7891"))
c := Q.StrToQval(STRING("-9876.5432"))
d := Q.Qdiv(a, c)
e := Q.Qmul(b, d)
x := Q.QvalToStr(e) 
PST.Str(STRING("(12345.6789/-9876.5432)x23456.7891 = "))
PST.Str(x)
PST.Char(PST#NL)
PST.Str(STRING("       Only 5 leading digits are correct!"))
PST.Chars(PST#NL, 2) 


PST.Str(STRING("Compute the same with the higher precision Qmuldiv:"))
PST.Chars(PST#NL, 2) 

d := Q.Qmuldiv(a, b, c)
e := Q.QvalToStr(d)
PST.Str(STRING("(12345.6789x23456.7891)/-9876.5432 = "))
PST.Str(e)
PST.Char(PST#NL)
PST.Str(STRING("           All 9 digits are correct!"))
PST.Chars(PST#NL, 2)

QueryReboot

PST.Char(PST#CS)
PST.Str(STRING("INT, FRAC and ROUND check"))
PST.Chars(PST#NL, 2) 

a := Q.StrToQval(STRING("2.754"))
b := Q.StrToQval(STRING("-2.754"))
c := Q.StrToQval(STRING("0"))

PST.Str(STRING("Integer part             INT(0) = "))
PST.Str(Q.QvalToStr(Q.Qint(c)))
PST.Char(PST#NL)
PST.Str(STRING("Integer part         INT(2.754) = "))
PST.Str(Q.QvalToStr(Q.Qint(a)))
PST.Char(PST#NL)
PST.Str(STRING("Integer part        INT(-2.754) = "))
PST.Str(Q.QvalToStr(Q.Qint(b)))
PST.Char(PST#NL)
PST.Str(STRING("Fraction part           FRAC(0) = "))
PST.Str(Q.QvalToStr(Q.Qfrac(c)))
PST.Char(PST#NL)
PST.Str(STRING("Fraction part       FRAC(2.754) = "))
PST.Str(Q.QvalToStr(Q.Qfrac(a)))
PST.Char(PST#NL)
PST.Str(STRING("Fraction part      FRAC(-2.754) = "))
PST.Str(Q.QvalToStr(Q.Qfrac(b)))

PST.Chars(PST#NL, 2)

a := Q.StrToQval(STRING("2.754"))
b := Q.StrToQval(STRING("4.335"))
c := Q.StrToQval(STRING("-2.754"))
d := Q.StrToQval(STRING("-4.335"))
e := Q.StrToQval(STRING("0"))
PST.Str(STRING("Rounding               ROUND(0) = "))
PST.Str(Q.QvalToStr(Q.Qround(e)))
PST.Char(PST#NL)
PST.Str(STRING("Rounding           ROUND(2.754) = "))
PST.Str(Q.QvalToStr(Q.Qround(a)))
PST.Char(PST#NL)
PST.Str(STRING("Rounding           ROUND(4.335) = "))
PST.Str(Q.QvalToStr(Q.Qround(b)))
PST.Char(PST#NL)
PST.Str(STRING("Rounding          ROUND(-2.754) = "))
PST.Str(Q.QvalToStr(Q.Qround(c)))
PST.Char(PST#NL)
PST.Str(STRING("Rounding          ROUND(-4.335) = "))
PST.Str(Q.QvalToStr(Q.Qround(d)))

PST.Chars(PST#NL, 2) 

QueryReboot

PST.Char(PST#CS)
PST.Str(STRING("SIN, COS, TAN  value check"))
PST.Chars(PST#NL, 2)

a := Q.Qval(15)
PST.Str(STRING("SIN(15) = "))
PST.Str(Q.QvalToStr(Q.Sin_Deg(a)))
PST.Str(STRING("   "))
PST.Str(STRING("COS(15) = "))
PST.Str(Q.QvalToStr(Q.Cos_Deg(a)))
PST.Str(STRING("   "))
PST.Str(STRING("TAN(15) = "))
PST.Str(Q.QvalToStr(Q.Tan_Deg(a)))
PST.Char(PST#NL)

a := Q.Qval(30)
PST.Str(STRING("SIN(30) = "))
PST.Str(Q.QvalToStr(Q.Sin_Deg(a)))
PST.Str(STRING("   "))
PST.Str(STRING("COS(30) = "))
PST.Str(Q.QvalToStr(Q.Cos_Deg(a)))
PST.Str(STRING("   "))
PST.Str(STRING("TAN(30) = "))
PST.Str(Q.QvalToStr(Q.Tan_Deg(a)))
PST.Char(PST#NL)

a := Q.Qval(45)
PST.Str(STRING("SIN(45) = "))
PST.Str(Q.QvalToStr(Q.Sin_Deg(a)))
PST.Str(STRING("   "))
PST.Str(STRING("COS(45) = "))
PST.Str(Q.QvalToStr(Q.Cos_Deg(a)))
PST.Str(STRING("   "))
PST.Str(STRING("TAN(45) = "))
PST.Str(Q.QvalToStr(Q.Tan_Deg(a)))
PST.Char(PST#NL)

a := Q.Qval(60)
PST.Str(STRING("SIN(60) = "))
PST.Str(Q.QvalToStr(Q.Sin_Deg(a)))
PST.Str(STRING("   "))
PST.Str(STRING("COS(60) = "))
PST.Str(Q.QvalToStr(Q.Cos_Deg(a)))
PST.Str(STRING("   "))
PST.Str(STRING("TAN(60) = "))
PST.Str(Q.QvalToStr(Q.Tan_Deg(a)))
PST.Char(PST#NL)

a := Q.Qval(75)
PST.Str(STRING("SIN(75) = "))
PST.Str(Q.QvalToStr(Q.Sin_Deg(a)))
PST.Str(STRING("   "))
PST.Str(STRING("COS(75) = "))
PST.Str(Q.QvalToStr(Q.Cos_Deg(a)))
PST.Str(STRING("   "))
PST.Str(STRING("TAN(75) = "))
PST.Str(Q.QvalToStr(Q.Tan_Deg(a)))
PST.Chars(PST#NL, 2)

QueryReboot

PST.Char(PST#CS)
PST.Str(STRING("SIN, COS quadrant check"))
PST.Chars(PST#NL, 2)

a := Q.Qval(0)
PST.Str(STRING("SIN(  0) = "))
PST.Str(Q.QvalToStr(Q.Sin_Deg(a)))
PST.Str(STRING("   "))
PST.Str(STRING("COS(  0) = "))
PST.Str(Q.QvalToStr(Q.Cos_Deg(a)))
PST.Char(PST#NL)

a := Q.Qval(90)
PST.Str(STRING("SIN( 90) = "))
PST.Str(Q.QvalToStr(Q.Sin_Deg(a)))
PST.Str(STRING("   "))
PST.Str(STRING("COS( 90) = "))
PST.Str(Q.QvalToStr(Q.Cos_Deg(a)))
PST.Char(PST#NL)

a := Q.Qval(180)
PST.Str(STRING("SIN(180) = "))
PST.Str(Q.QvalToStr(Q.Sin_Deg(a)))
PST.Str(STRING("   "))
PST.Str(STRING("COS(180) = "))
PST.Str(Q.QvalToStr(Q.Cos_Deg(a)))
PST.Char(PST#NL)

a := Q.Qval(270)
PST.Str(STRING("SIN(270) = "))
PST.Str(Q.QvalToStr(Q.Sin_Deg(a)))
PST.Str(STRING("   "))
PST.Str(STRING("COS(270) = "))
PST.Str(Q.QvalToStr(Q.Cos_Deg(a)))
PST.Chars(PST#NL, 2)

QueryReboot

PST.Char(PST#CS)
PST.Str(STRING("ATAN2 quadrants, ASIN, ACOS, SQRT and RADIUS check"))
PST.Chars(PST#NL, 2)

x := Q.StrToQval(STRING("0.7071"))
y := Q.StrToQval(STRING("0.7071"))
PST.Str(STRING("ATAN2(  0.7071,  0.7071) = "))
PST.Str(Q.QvalToStr(Q.Deg_ATAN2(x, y)))
PST.Char(PST#NL)

x := Q.StrToQval(STRING("-0.7071"))
y := Q.StrToQval(STRING("0.7071"))
PST.Str(STRING("ATAN2( -0.7071,  0.7071) = "))
PST.Str(Q.QvalToStr(Q.Deg_ATAN2(x, y)))
PST.Char(PST#NL)

x := Q.StrToQval(STRING("0.7071"))
y := Q.StrToQval(STRING("-0.7071"))
PST.Str(STRING("ATAN2(  0.7071, -0.7071) = "))
PST.Str(Q.QvalToStr(Q.Deg_ATAN2(x, y)))
PST.Char(PST#NL)

x := Q.StrToQval(STRING("-0.7071"))
y := Q.StrToQval(STRING("-0.7071"))
PST.Str(STRING("ATAN2( -0.7071, -0.7071) = "))
PST.Str(Q.QvalToStr(Q.Deg_ATAN2(x, y)))
PST.Chars(PST#NL, 2)

x := Q.StrToQval(STRING("0.0"))
PST.Str(STRING("ASIN(0.0) = "))
PST.Str(Q.QvalToStr(Q.Deg_ASIN(x)))
PST.Str(STRING("        ACOS(0.0) = "))
PST.Str(Q.QvalToStr(Q.Deg_ACOS(x)))
PST.Char(PST#NL)

x := Q.StrToQval(STRING("0.5"))
PST.Str(STRING("ASIN(0.5) = "))
PST.Str(Q.QvalToStr(Q.Deg_ASIN(x)))
PST.Str(STRING("  ACOS(0.5) = "))
PST.Str(Q.QvalToStr(Q.Deg_ACOS(x)))
PST.Char(PST#NL)

x := Q.StrToQval(STRING("1.0"))
PST.Str(STRING("ASIN(1.0) = "))
PST.Str(Q.QvalToStr(Q.Deg_ASIN(x)))
PST.Str(STRING("       ACOS(1.0) = "))
PST.Str(Q.QvalToStr(Q.Deg_ACOS(x)))
PST.Chars(PST#NL, 2)

PST.Str(STRING("Length of vector (X=100,Y=100) computes as"))
PST.Char(PST#NL)
x := Q.StrToQval(STRING("20000.0"))
PST.Str(STRING(" SQRT(20000) = "))
PST.Str(Q.QvalToStr(Q.Qsqr(x)))
PST.Char(PST#NL)
PST.Str(STRING("SQRT does not compute length of (X=10000,Y=10000), as"))
PST.Char(PST#NL)
PST.Str(STRING("SQRT(200000000) fails, but RADIUS gives the result"))
PST.Char(PST#NL)
x := Q.StrToQval(STRING("10000.0"))
y := Q.StrToQval(STRING("10000.0"))
PST.Str(STRING("           X = "))
PST.Str(Q.QvalToStr(x))
PST.Char(PST#NL)
PST.Str(STRING("           Y = "))
PST.Str(Q.QvalToStr(y))
PST.Char(PST#NL)
PST.Str(STRING("      RADIUS = "))
a := Q.Qradius(x, y)
PST.Str(Q.QvalToStr(a))
PST.Char(PST#NL)
PST.Str(STRING("Note the increased range and precision of RADIUS.")) 
PST.Chars(PST#NL, 2)

QueryReboot
'}'END OF QVAL ARITHMETICS DEMO CODE BLOCK


{SPEED TEST CODE BLOCK Selector Button, pressed ON with 1st '
PST.Char(PST#CS)
PST.Str(STRING("Comparison of speed of SPIN_TrigPack and FloatMath"))
PST.Chars(PST#NL, 2)

PST.Str(STRING("With addition (Pi + Pi) :"))
PST.Chars(PST#NL, 2)
x := PI
t1 := CNT
REPEAT 1000
  y := F.FAdd(x, x)
t1 := CNT - t1
x := Q.StrToQval(STRING("3.14159")) 
t2 := CNT
REPEAT 1000
  y := x + x
t2 := CNT - t2
PST.Str(STRING("SPIN_TrigPack is faster "))
z := Q.Qdiv(t1, t2)
PST.Str(Q.QvalToStr(z))  
PST.Str(STRING(" times."))
PST.Chars(PST#NL,  2)    

PST.Str(STRING("With multiplication (Pi * Pi) :"))
PST.Chars(PST#NL, 2)
x := PI
t1 := CNT
REPEAT 100
  y := F.FMul(x, x)
t1 := CNT - t1
x := Q.StrToQval(STRING("3.14159")) 
t2 := CNT
REPEAT 100
  y := d := Q.Qmul(x, x)
t2 := CNT - t2
PST.Str(STRING("SPIN_TrigPack is faster "))
z := Q.Qdiv(t1, t2)
PST.Str(Q.QvalToStr(z))  
PST.Str(STRING(" times."))
PST.Chars(PST#NL, 2)  

PST.Str(STRING("With division (Pi / 2.71828) :"))
PST.Chars(PST#NL, 2)
x := 2.71282
y := PI
t1 := CNT
REPEAT 100
  z := F.FDiv(y, x)
t1 := CNT - t1
x := Q.StrToQval(STRING("2.71828"))
y := Q.StrToQval(STRING("3.14159"))
t2 := CNT
REPEAT 100
  z := Q.Qdiv(y, x)
t2 := CNT - t2
PST.Str(STRING("SPIN_TrigPack is faster "))
z := Q.Qdiv(t1, t2)
PST.Str(Q.QvalToStr(z))  
PST.Str(STRING(" times."))
PST.Chars(PST#NL, 2)  

QueryReboot
}'END OF SPEED TEST CODE BLOCK     

PST.Char(PST#NL)
PST.Str(STRING("SPIN TrigPack demo terminated normaly..."))
WAITCNT(CLKFREQ + CNT)   
PST.Stop
'------------------------End of Start_Application-------------------------


PRI QueryReboot | done, r
'-------------------------------------------------------------------------
'------------------------------┌─────────────┐----------------------------
'------------------------------│ QueryReboot │----------------------------
'------------------------------└─────────────┘----------------------------
'-------------------------------------------------------------------------
''     Action: Asks to reboot
'' Parameters: None                                
''    Returns: None                
''+Reads/Uses: PST#NL, PST#PX                     (OBJ/CON)
''             highB                              (VAR/BYTE)
''    +Writes: None                                    
''      Calls: "Parallax Serial Terminal"--------->PST.Str
''                                                 PST.Char
''                                                 PST.RxFlush
'------------------------------------------------------------------------
PST.Str(STRING("[R]eboot to test RNGs or press any other key to "))
PST.Str(STRING("continue..."))
PST.Char(PST#NL)
done := FALSE
REPEAT UNTIL done
  PST.RxFlush
  r := PST.CharIn
  IF ((r == "R") OR (r == "r"))
    PST.Char(PST#PX)
    PST.Char(0)
    PST.Char(32)
    PST.Char(PST#NL) 
    PST.Str(STRING("Rebooting..."))
    WAITCNT((CLKFREQ / 10) + CNT) 
    REBOOT
  ELSE
    done := TRUE
'---------------------------End of QueryReboot----------------------------


DAT '---------------------------MIT License-------------------------------


{{
┌────────────────────────────────────────────────────────────────────────┐
│                        TERMS OF USE: MIT License                       │                                                            
├────────────────────────────────────────────────────────────────────────┤
│  Permission is hereby granted, free of charge, to any person obtaining │
│ a copy of this software and associated documentation files (the        │ 
│ "Software"), to deal in the Software without restriction, including    │
│ without limitation the rights to use, copy, modify, merge, publish,    │
│ distribute, sublicense, and/or sell copies of the Software, and to     │
│ permit persons to whom the Software is furnished to do so, subject to  │
│ the following conditions:                                              │
│                                                                        │
│  The above copyright notice and this permission notice shall be        │
│ included in all copies or substantial portions of the Software.        │  
│                                                                        │
│  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND        │
│ EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF     │
│ MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. │
│ IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY   │
│ CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,   │
│ TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE      │
│ SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                 │
└────────────────────────────────────────────────────────────────────────┘
}}                  