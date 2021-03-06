'' ***************************************
'' *  Multilabs ezDisplay 1.0 / 2.0      *
'' ***************************************
''
'' http://www.multilabs.net/ezDISPLAY.html
''
'' Created September 26, 2007
'' Written by Paul Deffenbaugh
'' Program Revision v1.0


CON  ' These constants should be copied to your top-level program

'------ezDisplay Constants------------ 
  baud          = 9600                                  ' 9600 baud, true/not inverted
  CharWidth     = 7                                     ' Characters are 7 pixels wide
  CharHeight    = 8                                     ' Characters are 8 pixels tall
  LCDwidth      = 160                                   ' LCD is 160 pixels wide
  LCDheight     = 80                                    ' LCD is 80 pixels tall
  LHS           = 1                                     ' Left hand side of screen is 1-referenced
  RHS           = LCDwidth - 7                          ' Right hand side of screen where a char can be placed

  Tab0          = LHS                                   ' Define tab-stops
  Tab1          = LHS + (charWidth* 5)                  ' Define tab-stops 
  Tab2          = LHS + (charWidth*10)                  ' Define tab-stops 
  Tab3          = LHS + (charWidth*15)                  ' Define tab-stops 
  Tab4          = LHS + (charWidth*20)                  ' Define tab-stops 
  Tab5          = LHS + (charWidth*25)                  ' Define tab-stops 
 
  Line0         = 1                                     ' Define ten lines on LCD
  Line1         = Line0 + (CharHeight * 1)
  Line2         = Line0 + (CharHeight * 2)
  Line3         = Line0 + (CharHeight * 3)
  Line4         = Line0 + (CharHeight * 4)
  Line5         = Line0 + (CharHeight * 5)
  Line6         = Line0 + (CharHeight * 6)
  Line7         = Line0 + (CharHeight * 7)
  Line8         = Line0 + (CharHeight * 8)
  Line9         = Line0 + (CharHeight * 9) 

VAR

  word  tx, bitTime, started
  byte TouchX, TouchY, ack, inverse
  byte CurX, CurY    

OBJ

  serial  : "FullDuplexSerial"   
  'serial : "simple_serial"
  num : "simple_numbers"                                ' number to string conversion

PUB start(rxPin,txPin)
                                       
  started~
    serial.start(rxpin, txpin, 0, baud)
    inverseOFF                                          ' inverse character mode is off
    started~~                                           ' mark started 
  return started


PUB stop

'' Makes serial pin an input

  if started
    serial.stop   
    started~                                            ' set to false

' Available Commands
    
'A,Char, byte 0, byte 1, byte 2, byte 3, byte 4, byte 5, byte 6, byte 7 
'B,Mode (0 or 1)                Backlight
'C,Mode,Char,X,Y                Place character
'D,bytes0-1599                  Download screen
'E,0,X1,Y1,X2,Y2                Erase rectangle of screen
'E,1                            Clear entire screen
'F,0..1,Char,X,Y                Place floating character (see user's guide)
'F,2..3,Char                    Place floating character (see user's guide) 
'G, Get Touchscreen             Get touch, returns 0 if no touch
'L,Mode,X1,Y1,X2,Y2             Draw 90-degree lines
'P,Mode,X,Y                     Place pixel
'R,Mode                         Retrieve Screen 0..3 screen num
'S,Mode                         Save Screen 0..3 screen num 
'T,                             Touchscreen Calibration (automatic by touchscreen controller)

PUB custom(char,byte0,byte1,byte2,byte3,byte4,byte5,byte6,byte7)

'' Installs custom character map
'' -- chrDataAddr is address of 8-byte character definition array

  if started
'    if lookdown(char : 0..127)                            ' make sure char in range
      serial.tx("A")
      serial.tx(char)
      serial.tx(byte0)
      serial.tx(byte1)
      serial.tx(byte2)
      serial.tx(byte3)
      serial.tx(byte4)
      serial.tx(byte5)
      serial.tx(byte6)
      serial.tx(byte7)
      ack := serial.rx

PUB backlightOff
  backlight(0)

PUB backlightOn
  backlight(1)

PUB backlight(OnOff)

'' Turn backlight on or off (1 or 0)
  serial.tx("B")
  serial.tx(OnOff)
  ack := serial.rx 
    
PUB putc(txByte)

'' Transmit a byte
  ezDisplay("C",inverse,txByte,curX,curY)
  curX += charWidth

PUB cls

'' Clears LCD screen
  serial.tx("E")
  serial.tx(1)
  ack := serial.rx
  curX := LHS
  curY := Line0
  waitcnt(clkfreq + cnt)                              ' pause one second for LCD to clear


PUB Erase(X1,Y1,X2,Y2)

'' Erase rectangular area of screen
  ezDisplay2D("E",1,X1,Y1,X2,Y2)

PUB CursorOff
  if started
    serial.tx("F")
    serial.tx(0)   ' Turn off floating cursor
    serial.tx(0)   ' Floating cursor = character number 0
    ack := serial.rx 

PUB Cursor(Char,X,Y)
  serial.tx("F")
  serial.tx(1)
  serial.tx(X)
  serial.tx(Y)
  ack := serial.rx 

PUB AutoCursor(Char)
  serial.tx("F")
  serial.tx(3)   ' Turn on automatic floating cursor
  serial.tx(Char)   ' Floating cursor = character number 0
  ack := serial.rx 

PUB GetTouchX
  serial.tx("G")
  TouchX := serial.rx
  TouchY := serial.rx 
  return TouchX

PUB GetTouchY
  return TouchY

PUB waitTouchX | x, y
  x := 0
  y := 0
  repeat until (!(x == 0) & !(y == 0))
    x := getTouchX
    y := getTouchY
  return TouchX

PUB touched
  if getTouchX > 0
    debounce
    return true
  return false

PUB debounce | x, y
  x := -1
  y := -1
  repeat until ((x == 0) & (y == 0))
    x := getTouchX
    y := getTouchY

PUB Line(X1,Y1,X2,Y2)
  ezDisplay2D("L",1,X1,Y1,X2,Y2)

PUB Pixel(X,Y)
  if started  
    serial.tx("P")
    serial.tx(1)
    serial.tx(X)
    serial.tx(Y)
    ack := serial.rx 
    
PUB Screen(screenNum)           ' Retrieve saved screen (takes about 2 seconds) 
  serial.tx("R")
  serial.tx(screenNum)          ' screenNum 0..3
  ack := serial.rx 

PUB Save(Mode)                  ' Save current screen as bitmap to screen memory 
  serial.tx("S")
  serial.tx(Mode)               ' screenNum 0..3 
  ack := serial.rx 

PUB Calibrate                   ' Starts touchscreen calibration mode (onscreen only) 
  serial.tx("T")
  ack := serial.rx  
    
PRI ezDisplay(Code,Mode,txByte,X,Y)
  serial.tx(Code)
  serial.tx(Mode)
  serial.tx(txByte)             ' Talk to ezDisplay (only one set of x and y)
  serial.tx(X)
  serial.tx(Y)
  ack := serial.rx

PRI ezDisplay2D(Code,Mode,X1,Y1,X2,Y2)
  serial.tx(Code)
  serial.tx(Mode)
  serial.tx(X1)
  serial.tx(Y1)                 ' Talk to ezDisplay (two sets of x and y)  
  serial.tx(X2)
  serial.tx(Y2)
  ack := serial.rx         

PUB Goto(X,Y)                   ' Goto a point on the screen
  CurX := X
  CurY := Y
  
PUB CRLF(X)                     ' Go to beginning of next line
  CurX := X
  CurY += CharHeight

PUB whiteSpace(n)               ' Jump ahead by 1 chars w/o placing space char
  CurX += (n * CharWidth)

PUB bksp(n)                     ' Jump back by 1 chars w/o placing space char  
  CurX -= (n * CharWidth)  

PUB debug(strAddr)              ' Print string, then go to next line
  str(strAddr)
  CRLF(LHS)

PUB TF(value)                   ' Print true or false ("T" or "F")
  if value
    putc("T")
  else
    putc("F")

PUB putXY(char,x,y)             ' Place character at specific x and y coordinates
  goto(x,y)
  putc(char)

PUB putB(char)                  ' Put Byte: if non-printable, display 3-digit decimal ascii code
  if char == 10 or char == 13
    crlf(LHS)
  elseif (char < " " OR char > "}")
    dec(char)
  else
    putc(char)

PUB inverseOFF                  ' Turn off inverse character mode (black letters on white background) 
  inverse := 0
  
PUB inverseON                   ' Turn on inverse character mode (white letters on black background)
  inverse := 2
    
PUB dec(value)                  ' Print a signed decimal number     
  str(num.dec(value))  

PUB decf(value, width)          ' Prints signed decimal value in space-padded, fixed-width field
   str(num.decf(value, width))   
  
PUB decx(value, digits)         ' Prints zero-padded, signed-decimal string, if value is neg, field is digits+1
  str(num.decx(value, digits)) 

PUB decXY(x, y)                 ' Print decimal number at specific coordinates
  str(num.decx(x, 3))
  whitespace(1)
  str(num.decx(y, 3))
   
PUB str(strAddr)                ' Print a string of characters
  if started
    repeat strsize(strAddr)     ' for each character in string
      putc(byte[strAddr++])     ' write the character
      if CurX > (RHS - CharWidth + 1) ' if end of line, go to next line
        CurX := LHS
        CurY += CharHeight
      waitcnt(clkfreq/100 + cnt)' Possibly not needed?  

PUB rectangle(x1,y1,x2,y2,thickness) ' Draw a border-only rectangle
  repeat thickness              ' Make rectangle as thick as desired
    Line(x1,y1,x2,y1)  ' Top
    Line(x2,y1,x2,y2)  ' Right
    Line(x1,y2,x2,y2)  ' Bottom
    Line(x1,y1,x1,y2)  ' Left
                       
    x1++               ' Move corners inwards, repeat for thicker border
    y1++                        
    x2--
    y2--
    
PUB fill(x1,y1,x2,y2) | i       ' Fill a rectangle with blackness using individual lines
  if (x2-x1) < (y2-y1)
    repeat i from x1 to x2
      Line(i,y1,i,y2)
  else
    repeat i from y1 to y2
      Line(x1,i,x2,i)        