{{ LCD_16x2_4Bit-VMA203H.spin


┌──────────────────────┐
│ Parallel LCD Driver  │
├──────────────────────┴───────────────────────┐
│  Width      : 16 Characters                  │
│  Height     :  2 Lines                       │
│  Interface  :  4 Bit                         │
│  Controller :  HD44780-based                 │
├──────────────────────────────────────────────┤
│  Original By      : Simon Ampleman           │
│                     sa@infodev.ca            │
│  Date    :          2006-11-18               │
│  Version :          1.0                      │
└──────────────────────────────────────────────┘
' Modified by Miro Kefurt  (mirox@aol.com)

''See Chapter 7   PARALLAX PROPELLER                    by Miro Kefurt
' Tested OK     2018-08-24      PAB and VMA203

' Version B     2018-08-24 OK   Replace timing with waitcnt(clkfreq/1_000 + cnt)  
' Version C     2018-08-24 OK   Eliminate OBJ Timing
' Version E     2018-08-24 OK   Correct Pin assignment for VMA203
' Version F     2018-08-25 OK     Add Blink PUB
' Version G     2018-08-25 OK     Add License
' Version H     2018-08-25      Change PRI to PUB CHAR (LCD_DATA)    

Hardware used : Valleman VMA203                   

Schematics
                         P8X32A
                       ┌────┬────┐ 
                       ┤0      31├              
                       ┤1      30├             
                       ┤2      29├                                           
                       ┤3      28├            
                       ┤4      27├            ┌────────────────────────────────────────────────┐  LCD TC1602
                       ┤5      26├            │ 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16│  LCD 16X2
                       ┤6      25├            │ 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16│  HD44780-BASED
                       ┤7      24├            └────────────────────────────────────────────────┘  Valleman VMA203
                       ┤VSS   VDD├              
                       ┤BOEn   XO├                          
                       ┤RESn   XI├             
                       ┤VDD   VSS├            
                   DB7 ┤8      23├ 
                   DB6 ┤9      22├ 
                   DB5 ┤10     21├ 
                   DB4 ┤11     20├
                       ┤12     19├ 
                       ┤13     18├ 
                   R/S ┤14     17├ RW (Not Connected)
                    E  ┤15     16├ 
                       └─────────┘ 


PIN ASSIGNMENT                                        P8X32A                    VMA203                TC1602
   VSS  - POWER SUPPLY (GND)                                                    J4-2/3                  Vss
   VCC  - POWER SUPPLY (+5V)                                                    J4-4                    Vdd
   VO   - CONTRAST ADJUST (0-5V)                                                                        V0
   R/S  - FLAG TO RECEIVE INSTRUCTION OR DATA           P14                     J2-8                    D8
            0 - INSTRUCTION
            1 - DATA
   R/W  - INPUT OR OUTPUT MODE                          P17                     N/C                     GND
            0 - WRITE TO LCD MODULE
            1 - READ FROM LCD MODULE
   E    - ENABLE SIGNAL                                 P15                     J2-7                    D9
   DB4  - DATA BUS LINE 4                               P11                     J1-4                    D4
   DB5  - DATA BUS LINE 5                               P10                     J1-3                    D5
   DB6  - DATA BUS LINE 6                               P9                      J1-2                    D6
   DB7  - DATA BUS LINE 7 (MSB)                         P8                      J1-1                    D7
   A(+) - BACKLIGHT 5V                                                                                  A
   K(-) - BACKLIGHT GND                                                                                 K
        - BACKLIGHT DISABLE (if Grounded)                                                               D10


INSTRUCTION SET
   ┌──────────────────────┬───┬───┬─────┬───┬───┬───┬───┬───┬───┬───┬───┬─────┬─────────────────────────────────────────────────────────────────────┐
   │  INSTRUCTION         │R/S│R/W│     │DB7│DB6│DB5│DB4│DB3│DB2│DB1│DB0│     │ Description                                                         │
   ├──────────────────────┼───┼───┼─────┼───┼───┼───┼───┼───┼───┼───┼───┼─────┼─────────────────────────────────────────────────────────────────────┤
   │ CLEAR DISPLAY        │ 0 │ 0 │     │ 0 │ 0 │ 0 │ 0 │ 0 │ 0 │ 0 │ 1 │     │ Clears display and returns cursor to the home position (address 0). │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │ CURSOR HOME          │ 0 │ 0 │     │ 0 │ 0 │ 0 │ 0 │ 0 │ 0 │ 1 │ * │     │ Returns cursor to home position (address 0). Also returns display   │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │ being shifted to the original position.                             │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │ ENTRY MODE SET       │ 0 │ 0 │     │ 0 │ 0 │ 0 │ 0 │ 0 │ 1 │I/D│ S │     │ Sets cursor move direction (I/D), specifies to shift the display(S) │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │ These operations are performed during data read/write.              │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │ DISPLAY ON/OFF       │ 0 │ 0 │     │ 0 │ 0 │ 0 │ 0 │ 1 │ D │ C │ B │     │ Sets On/Off of all display (D), cursor On/Off (C) and blink of      │
   │ CONTROL              │   │   │     │   │   │   │   │   │   │   │   │     │ cursor position character (B).                                      │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │ CURSOR/DISPLAY       │ 0 │ 0 │     │ 0 │ 0 │ 0 │ 1 │S/C│R/L│ * │ * │     │ Sets cursor-move or display-shift (S/C), shift direction (R/L).     │
   │ SHIFT                │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │ FUNCTION SET         │ 0 │ 0 │     │ 0 │ 0 │ 1 │ DL│ N │ F │ * │ * │     │ Sets interface data length (DL), number of display line (N) and     │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │ character font(F).                                                  │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │ SET CGRAM ADDRESS    │ 0 │ 0 │     │ 0 │ 1 │      CGRAM ADDRESS    │     │ Sets the CGRAM address. CGRAM data is sent and received after       │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │ this setting.                                                       │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │ SET DDRAM ADDRESS    │ 0 │ 0 │     │ 1 │       DDRAM ADDRESS       │     │ Sets the DDRAM address. DDRAM data is sent and received after       │                                                             
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │ this setting.                                                       │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │ READ BUSY FLAG AND   │ 0 │ 1 │     │ BF│    CGRAM/DDRAM ADDRESS    │     │ Reads Busy-flag (BF) indicating internal operation is being         │
   │ ADDRESS COUNTER      │   │   │     │   │   │   │   │   │   │   │   │     │ performed and reads CGRAM or DDRAM address counter contents.        │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │ WRITE TO CGRAM OR    │ 1 │ 0 │     │         WRITE DATA            │     │ Writes data to CGRAM or DDRAM.                                      │
   │ DDRAM                │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │ READ FROM CGRAM OR   │ 1 │ 1 │     │          READ DATA            │     │ Reads data from CGRAM or DDRAM.                                     │
   │ DDRAM                │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   │                      │   │   │     │   │   │   │   │   │   │   │   │     │                                                                     │
   └──────────────────────┴───┴───┴─────┴───┴───┴───┴───┴───┴───┴───┴───┴─────┴─────────────────────────────────────────────────────────────────────┘
   Remarks :
            * = 0 OR 1
        DDRAM = Display Data Ram
                Corresponds to cursor position                  
        CGRAM = Character Generator Ram        

   ┌──────────┬──────────────────────────────────────────────────────────────────────┐
   │ BIT NAME │                          SETTING STATUS                              │                                                              
   ├──────────┼─────────────────────────────────┬────────────────────────────────────┤
   │  I/D     │ 0 = Decrement cursor position   │ 1 = Increment cursor position      │
   │  S       │ 0 = No display shift            │ 1 = Display shift                  │
   │  D       │ 0 = Display off                 │ 1 = Display on                     │
   │  C       │ 0 = Cursor off                  │ 1 = Cursor on                      │
   │  B       │ 0 = Cursor blink off            │ 1 = Cursor blink on                │
   │  S/C     │ 0 = Move cursor                 │ 1 = Shift display                  │
   │  R/L     │ 0 = Shift left                  │ 1 = Shift right                    │
   │  DL      │ 0 = 4-bit interface             │ 1 = 8-bit interface                │
   │  N       │ 0 = 1/8 or 1/11 Duty (1 line)   │ 1 = 1/16 Duty (2 lines)            │
   │  F       │ 0 = 5x7 dots                    │ 1 = 5x10 dots                      │
   │  BF      │ 0 = Can accept instruction      │ 1 = Internal operation in progress │
   └──────────┴─────────────────────────────────┴────────────────────────────────────┘

   DDRAM ADDRESS USAGE FOR A 1-LINE DISPLAY
   
    00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39   <- CHARACTER POSITION
   ┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐
   │00│01│02│03│04│05│06│07│08│09│0A│0B│0C│0D│0E│0F│10│11│12│13│14│15│16│17│18│19│1A│1B│1C│1D│1E│1F│20│21│22│23│24│25│26│27│  <- ROW0 DDRAM ADDRESS
   └──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┘

   DDRAM ADDRESS USAGE FOR A 2-LINE DISPLAY

    00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39   <- CHARACTER POSITION
   ┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐
   │00│01│02│03│04│05│06│07│08│09│0A│0B│0C│0D│0E│0F│10│11│12│13│14│15│16│17│18│19│1A│1B│1C│1D│1E│1F│20│21│22│23│24│25│26│27│  <- ROW0 DDRAM ADDRESS
   │40│41│42│43│44│45│46│47│48│49│4A│4B│4C│4D│4E│4F│50│51│52│53│54│55│56│57│58│59│5A│5B│5C│5D│5E│5F│60│61│62│63│64│65│66│67│  <- ROW1 DDRAM ADDRESS
   └──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┘

   DDRAM ADDRESS USAGE FOR A 4-LINE DISPLAY

    00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19   <- CHARACTER POSITION
   ┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐
   │00│01│02│03│04│05│06│07│08│09│0A│0B│0C│0D│0E│0F│10│11│12│13│  <- ROW0 DDRAM ADDRESS
   │40│41│42│43│44│45│46│47│48│49│4A│4B│4C│4D│4E│4F│50│51│52│53│  <- ROW1 DDRAM ADDRESS
   │14│15│16│17│18│19│1A│1B│1C│1D│1E│1F│20│21│22│23│24│25│26│27│  <- ROW2 DDRAM ADDRESS
   │54│55│56│57│58│59│5A│5B│5C│5D│5E│5F│60│61│62│63│64│65│66│67│  <- ROW3 DDRAM ADDRESS
   └──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┴──┘
  
}}      
        
        
        
CON

  ' Pin assignment
  RS = 14     '16       = D8       
  RW = 17     '         N/C      
  E  = 15     '18       = D9

  DB4 = 11    '         = D4
  DB7 = 8     '         = D7
   

PUB START                         ' Starts LCD Display

  DIRA[DB7..DB4] := %1111                               ' Set everything to output              
  DIRA[RS] := 1
  DIRA[RW] := 1
  DIRA[E] := 1

  INIT 

PRI INIT                          ' Initializes LCD Display

  waitcnt((clkfreq/1_000*15) + cnt)                     ' Rest 15miliseconds 
  
  OUTA[DB7..DB4] := %0000                               ' Output low on all pins
  OUTA[RS] := 0
  OUTA[RW] := 0

  OUTA[E]  := 1
  OUTA[DB7..DB4] := %0010                               ' Set to DL=4 bits
  OUTA[E]  := 0

  INST4 (%0010_1000)                                    ' Now that we're in 4 bits, add N=2 lines, F=5x7 fonts                                              
  CLEAR
  INST4 (%0000_1100)                                    ' Display on, Cursor off, Blink off                                             
  INST4 (%0000_0110)                                    ' Increment Cursor + No-Display Shift                                             

PRI BUSY | IS_BUSY

  waitcnt((clkfreq/1_000*5) + cnt)                      ' I did not find a way to read busy flag in 4 bit correctly

PRI INST4 (LCD_DATA)        ' Sends DATA in 4-Bit Mode    

  BUSY

  OUTA[RW] := 0                              
  OUTA[RS] := 0                              
  OUTA[E]  := 1
  OUTA[DB7..DB4] := LCD_DATA >> 4
  OUTA[E]  := 0                              

  BUSY

  OUTA[E]  := 1
  OUTA[DB7..DB4] := LCD_DATA
  OUTA[E]  := 0                              

PUB CHAR (LCD_DATA)      ' Prints ASCII Character
    
  BUSY

  OUTA[RW] := 0                              
  OUTA[RS] := 1                              

  OUTA[E]  := 1
  OUTA[DB7..DB4] := LCD_DATA >> 4
  OUTA[E]  := 0  

  BUSY

  OUTA[E]  := 1
  OUTA[DB7..DB4] := LCD_DATA
  OUTA[E]  := 0  
  
PUB CLEAR         'Clears display and returns cursor to the home position (address 0)
  
  INST4 (%0000_0001)                                                                               

PUB MOVE (X,Y) | ADR        ' Moves cursor to specified X,Y position
  ' X : Horizontal Position : 1 to 16
  ' Y : Line Number         : 1 or 2
  ADR := (Y-1) * 64
  ADR += (X-1) + 128
  INST4 (ADR)

PUB STR (STRINGPTR)         ' Prints String
  REPEAT STRSIZE(STRINGPTR)
    CHAR(BYTE[STRINGPTR++])
                              
PUB DEC (VALUE) | TEMP       ' Prints Decimal Number
  IF (VALUE < 0)
    -VALUE
    CHAR("-")

  TEMP := 1_000_000_000

  REPEAT 10
    IF (VALUE => TEMP)
      CHAR(VALUE / TEMP + "0")
      VALUE //= TEMP
      RESULT~~
    ELSEIF (RESULT OR TEMP == 1)
      CHAR("0")
    TEMP /= 10

PUB HEX (VALUE, DIGITS)      ' Prints Hex Number

  VALUE <<= (8 - DIGITS) << 2
  REPEAT DIGITS
    CHAR(LOOKUPZ((VALUE <-= 4) & $F : "0".."9", "A".."F"))

PUB BIN (VALUE, DIGITS)       ' Prints Binary Number

  VALUE <<= 32 - DIGITS
  REPEAT DIGITS
    CHAR((VALUE <-= 1) & 1 + "0")

PUB END                       ' Ends LCD Display

  INST4 (%0000_1000)                                    ' Display off, Cursor off, Blink off   

  DIRA[DB7..DB4] := %0000                               ' Set everything to ZERO              
  DIRA[RS] := 0
  DIRA[RW] := 0
  DIRA[E] := 0

PUB DOFF  

  INST4 (%0000_1000)                                    ' Display off, Cursor off, Blink off

PUB DON  

  INST4 (%0000_1100)                                    ' Display on, Cursor off, Blink off

PUB Blink(count)
{{
  Blink the display at a 1Hz rate
  Parameters: count = number of times to blink the display
                       0 causes the display to blink indefinitely
  example usage: LCD.Blink(10)
}}

  repeat while Count := --Count #> -1                                                                   ' While not 0 (make min -1)  <- Shamelessly taken from the tutorials 
    waitcnt(clkfreq / 2 + cnt)                                                                          
    INST4(%0000_1000)                       ' Display OFF, Cursor off, Blink off                                                          
    waitcnt(clkfreq / 2 + cnt)
    INST4(%0000_1100)                       ' Display ON, Cursor off, Blink off

DAT
{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                   TERMS OF USE: MIT License                                                  │                                                            
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation    │ 
│files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,    │
│modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software│
│is furnished to do so, subject to the following conditions:                                                                   │
│                                                                                                                              │
│The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.│
│                                                                                                                              │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE          │
│WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR         │
│COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,   │
│ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                         │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘
}}                          