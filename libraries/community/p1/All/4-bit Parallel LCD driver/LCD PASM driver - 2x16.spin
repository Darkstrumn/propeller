{{┌──────────────────────────────────────────┐
  │ Parallel 2x16 LCD driver, 4-bit mode     │   
  │ Author: Chris Gadd                       │   
  │ Copyright (c) 2013 Chris Gadd            │   
  │ See end of file for terms of use.        │   
  └──────────────────────────────────────────┘

  Spin methods based on FullDuplexSerial:                             
   Send:    Sends one byte - can be a command or a charcter              LCD.Send("A")
   Str:     Sends a string of command and text bytes                     LCD.Str(string($01,"top line",$C0,"bottom line"))
   Dec:     Displays an ASCII string equivalent of a decimal value       LCD.Dec(1234)
   Hex:     Display the ASCII string equivalent of a hexadecimal number  LCD.Hex($1234, 4)
   Bin:     Display the ASCII string equivalent of a binary number       LCD.Bin(%0001_0010_0011_0100, 16)

  LCD command methods:
   Clear:   Clears the LCD display and sets the cursor to home position  LCD.Clear
   Home:    Moves the cursor and display to the home position            LCD.Home
   Move:    Moves the cursor to specified position                       LCD.Move(2,1) <- Line 2 column 1
   Shift_R: Shifts the display to the right (scrolls display left)       LCD.Shift_R
   Shift_L: Shifts the display to the left (scrolls display right)       LCD.Shift_L
   Shift:   Shifts the display an arbitrary number of positions          LCD.Shift(-2) <- Shifts display left two positions

   The command to turn the display on and off also controls the cursor on/off and blinking on/off
    Display is on, and cursor and blinking are off by default.
     To turn display off: LCD.Send(%0000_1000)
     To turn display on:  LCD.Send(%0000_1100)
       
  ┌─Hitachi HD44780 LCD─────────────────────────────────────────────┐          Send high nibble                           D7 is high in 1st nibble if LCD is busy
  │                                                                 │          │ Send low nibble     Max rate if             Busy flag set   Clear
  │ $00 $01 $02 $03 $04 $05 $06 $07 $08 $09 $0A $0B $0C $0D $0E $0F │          │ │ Read busy flag     busy flag low          │   │   │   │   │ Clock 2nd nibble through
  │                                                                 │                                                                  
  │ $40 $41 $42 $43 $44 $45 $46 $47 $48 $49 $4A $4B $4C $4D $4E $4F │    D7   ────────────       
  │                                                                 │    D6                     
  └┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬────┘    D5                     
   D7  D6  D5  D4  D3  D2  D1  D0  E   R/W Rs  V0  Vdd Vss NC  NC        D4                     
   │   │   │   │   │   │   │   │   │   │   │   │   │  │                                                                                                       
                   x   x   x   x               │   ┣─┘ │ 5V              E                      
                                               └──   │ 10KΩ-20KΩ       R/W         
                                                   ┣───┘                 RS          
   RS      - low for commands, high for text                                                        
   R/W     - low for write, high for read                                      │   Read busy flag      Send Text
   E       - clocks the data lines                                             Send command
   D7 - D4 - data input in 4-bit mode          
   D3 - D0 - not used in 4-bit mode            

   D7 through D4 must be connected to consecutive pins, D4 on low-pin

 Commands:
  Clear display           - %0000_0001
  Home display            - %0000_001x - x is don't care
  Entry mode              - %0000_01is - i sets display shift right(0) or shift left(1).  s sets no shift(0) or shift(1)
  Display on/off          - %0000_1dcb - d sets display off(0) or on(1), c sets cursor off(0) or on(1), b sets cursor blink off(0) or on(1)
  Cursor or display shift - %0001_srxx - moves cursor and shifts display without changing DDRAM contents
  Function set            - %001d_nfxx - Sets interface data length(D), number of display lines(N), and character font(F) - only used on initialization
  Set CGRAM address       - %01aa_aaaa -                                                                                  - used by display characters
  Set DDRAM address       - %1aaa_aaaa - move cursor to location $00 through $27 for top row, $40 through $67 for bottom row
                                         ($80 | (row * $40) | column) where row is 0 or 1, column is 0 through 39  
                                         column 40 is mapped to column 0 of the alternate row ($80 | $00 | 40) is mapped to ($80 | $40 | 0)

 Text:
  bytes from $20 to $7F are displayed as ASCII characters                                                                                                  
                                                                              
}}

CON
  CLS   = $01     ' Clear screen
  Hm    = $02     ' Home display and cursor
  CL    = $10     ' Shift cursor left one
  CR    = $14     ' Shift cursor right one
  DL    = $18     ' Shift display left one        
  DR    = $1C     ' Shift display right one

VAR
  byte  display_head
  byte  display_tail  
  byte  display_buffer[16]
  byte  pins[4]
  byte  cog                                     
  byte  shift_location

PUB start(E_pin, RW_pin, RS_pin, D4_pin) : okay
  stop
  pins[0] := E_pin
  pins[1] := RW_pin
  pins[2] := RS_pin
  pins[3] := D4_pin
                                                                        
  okay := cog := cognew(@entry, @display_head) + 1

PUB stop
  if cog
    cogstop(cog~ - 1)

PUB Send(_LCD_byte)
{{
   Displays a single byte
   Parameters: _LCD_byte = byte to be displayed
   example usage: LCD.Send("A")
}}
  repeat until (display_tail <> (display_head + 1) & $F)                                                ' wait until the buffer has room
  display_buffer[display_head] := _LCD_byte                                                             ' place the byte into the buffer
  display_head := (display_head + 1) & $F                                                               ' advance the buffer's pointer

PUB Str(stringPtr)
{{
   Transmit a string of bytes
   Parameters: stringPtr = the pointer address of the null-terminated string to be sent
   example usage: LCD.Str(@test_string)
}}
  repeat strsize(stringPtr)
    Send(byte[stringPtr++])                                                                             ' Display each byte in the string

PUB Dec(value) | i, x
{{
   Display the ASCII string equivalent of a decimal value
   Parameters: dec = the numeric value to be displayed
   example usage: LCD.Dec(-1_234_567_890)
}}

  x := value == NEGX                                                                                    ' Check for max negative
  if value < 0
    value := ||(value+x)                                                                                ' If negative, make positive; adjust for max negative
    Send("-")                                                                                           ' and output sign

  i := 1_000_000_000                                                                                    ' Initialize divisor

  repeat 10                                                                                             ' Loop for 10 digits
    if value => i                                                               
      Send(value / i + "0" + x*(i == 1))                                                                ' If non-zero digit, output digit; adjust for max negative
      value //= i                                                                                       ' and digit from value
      result~~                                                                                          ' flag non-zero found
    elseif result or i == 1
      Send("0")                                                                                         ' If zero digit (or only digit) output it
    i /= 10                                                                                             ' Update divisor

PUB Hex(value, digits)
{{
   Display the ASCII string equivalent of a hexadecimal number
   Parameters: value = the numeric hex value to be transmitted
               digits = the number of hex digits to print                 
   example usage: LCD.Hex($AA_FF_43_21, 8)
}}
         
  value <<= (8 - digits) << 2
  repeat digits                                                                                         ' do it for the number of hex digits being transmitted
    Send(lookupz((value <-= 4) & $F : "0".."9", "A".."F"))                                              ' Display the ASCII value of the hex characters

PUB Bin(value, digits)
{{
   Display the ASCII string equivalent of a binary number
   Parameters: value = the numeric binary value to be transmitted
               digits = the number of binary digits to print                 
   example usage: LCD.Bin(%1110_0011_0000_1100_1111_1010_0101_1111, 32)
}}

  value <<= 32 - digits
  repeat digits
    Send((value <-= 1) & 1 + "0")                                                                       ' Display the ASCII value of each binary digit

PUB Scroll(Topline,Bottomline) | top_ptr, bottom_ptr, n
{{
  Scroll two lines of text
  Parameters: Topline    = address of null-terminated string to display on the top line
              Bottomline = address of null-terminated string to display on the bottom line
  example usage: LCD.Scroll(@Topline,@Bottomline)
}}

  n := shift_location + 17                                                                              ' n is the cursor column position, which needs to be just off  
  if n > 39                                                                                             '  the right-most column to provide decent scrolling      
    n -= 39                                                                                              '  keeping in mind that the display might already be shifted  
  top_ptr := bottom_ptr := 0

  repeat while byte[Topline][top_ptr] or byte[Bottomline][bottom_ptr]                                   ' Both lines have their own pointers - 
    Move(1,n)                                                                                           '  Even though they both start at 0, they only increment together
    if byte[Topline][top_ptr]                                                                           '  until a null-termination is reached in the string    
      Send(byte[Topline][top_ptr++])
    else
      Send(" ")
    Move(2,n)
    if byte[Bottomline][bottom_ptr] 
      Send(byte[Bottomline][bottom_ptr++])
    else
      Send(" ")
    Send(DL)
    if Shift_location++ == 40
      shift_location := 0
    if n++ == 40
      n := 1
    waitcnt(cnt + clkfreq / 10)

PUB Scroll_ind(stringPtr, line) | column, i

  column := shift_location + 16
  if column > 40
    column -= 40

  column := 16
         
  repeat strsize(stringPtr)
    waitcnt(cnt + clkfreq / 10)
    move(line,column)
    i := 0
    repeat until i + column == 17
      if byte[stringPtr][i]
        Send(byte[stringPtr][i++])
    column -= 1
    if column == 0
      column := 1                            
      stringPtr++
      
PUB Blink(count)
{{
  Blink the display at a 1Hz rate
  Parameters: count = number of times to blink the display
                       0 causes the display to blink indefinitely
  example usage: LCD.Blink(10)
}}

  repeat while Count := --Count #> -1                                                                   ' While not 0 (make min -1)  <- Shamelessly taken from the tutorials 
    waitcnt(clkfreq / 2 + cnt)                                                                          
    Send(%0000_1000)                                                                                    
    waitcnt(clkfreq / 2 + cnt)
    Send(%0000_1100)
  
PUB Clear
{{
   Clears the display 
   Parameters: none
   example usage: LCD.Clear

   alternate to: LCD.Send(LCD#CLS)
}}

  Send(CLS)    

PUB Home
{{
   Unshifts the display and moves the cursor position to address 0
   Parameters: none
   example usage: LCD.Home

   alternative to: LCD.Send(LCD#Hm)
}}

  Send(Hm)

PUB Move(Line, Column)
{{
   Moves the cursor position to row,column
   Parameters: column = first(1), last(40)
               line   = top(1) or bottom(2)
   example usage: LCD.Move(2,1) moves cursor to line 2 column 1
}}

  Send(((Column - 1) + ((Line - 1) * 64) & %0111_0000) | %1000_0000)
  
PUB Shift_R
{{
   Shifts the display one position to the right
   Parameters: none
   example usage: LCD.Shift_R

   alternative to LCD.Send(LCD#DR)
}}

   Send(DR)

PUB Shift_L
{{
   Shifts the display one position to the left
   Parameters: none
   example usage: LCD.Shift_L

   alternative to LCD.Send(LCD#DL)
}}

   Send(DL)

PUB Shift(X)    
{{
   Shifts the display an arbitrary number of positions left or right
   Parameters: X = number of positions to shift left(negative) or right(positive)
   example usage: LCD.Shift_X(-5)
}}

  if X < 0
    repeat || X
      Send(DL)
  if X > 0
    repeat X
      Send(DR)
  
DAT                     org   
entry
                        mov       t1,par                                        ' Load addresses and pin masks
                        mov       head_address,t1
                        add       t1,#1
                        mov       tail_address,t1
                        add       t1,#1
                        mov       buffer_address,t1
                        add       t1,#16
                        rdbyte    t2,t1
                        mov       E_mask,#1
                        shl       E_mask,t2
                        add       t1,#1
                        rdbyte    t2,t1
                        mov       RW_mask,#1
                        shl       RW_mask,t2
                        add       t1,#1
                        rdbyte    t2,t1
                        mov       RS_mask,#1
                        shl       RS_mask,t2
                        add       t1,#1
                        rdbyte    t2,t1
                        mov       LCD_offset,t2                                                                                    
                        mov       LCD_mask,#$F
                        shl       LCD_mask,t2
                        mov       D7_mask,#1
                        add       t2,#3
                        shl       D7_mask,t2                           
                        or        dira,LCD_mask                                 
                        or        dira,E_mask
                        or        dira,RW_mask
                        or        dira,RS_mask
                        mov       cnt,_15ms                                     ' Initialize LCD per the datasheet
                        add       cnt,cnt
                        waitcnt   cnt,_4_1ms
                        mov       t1,#%0011
                        call      #LCD_Send_nibble
                        waitcnt   cnt,_100us
                        mov       t1,#%0011
                        call      #LCD_Send_nibble
                        waitcnt   cnt,_100us
                        mov       t1,#%0011
                        call      #LCD_Send_nibble
                        waitcnt   cnt,_100us
                        mov       t1,#%0010
                        call      #LCD_Send_nibble
                        mov       LCD_byte,#%0010_1000                          ' 4-bit mode, 2-line, 5x8 pixel characters
                        call      #LCD_Command
                        mov       LCD_byte,#%0000_1100                          ' Turn display on, no cursor, no blinking
                        call      #LCD_Command
                        mov       LCD_byte,#%0000_0001                          ' Clear LCD
                        call      #LCD_Command
Loop
                        rdbyte    t1,head_address                               ' Check circular buffer for new data
                        rdbyte    t2,tail_address                               
                        cmp       t1,t2                       wz                
          if_e          jmp       #Loop                                        
                        mov       t1,t2                                         
                        add       t2,buffer_address
                        rdbyte    LCD_byte,t2                                   ' Read byte from tail end of buffer
                        add       t1,#1                                         ' Increment tail                                  
                        and       t1,#$0F                                         
                        wrbyte    t1,tail_address
                        cmp       LCD_byte,#$20               wc                ' Any byte below $20 or above $7F is a command
          if_b          call      #LCD_Command                                  
          if_b          jmp       #Loop
                        cmp       LCD_byte,#$80               wc
          if_ae         call      #LCD_Command
          if_ae         jmp       #Loop
                        call      #LCD_Text
                        jmp       #Loop
'======================================================================================================================                        
LCD_Command
                        call      #Check_Busy_Flag
                        andn      outa,RS_mask                                  ' Send a command
                        jmp       #LCD_Prepare_Byte
LCD_Text
                        call      #Check_Busy_Flag
                        or        outa,RS_mask                                  ' Send text
LCD_Prepare_Byte
                        mov       t1,LCD_byte                                 
                        shr       t1,#4                                         ' Move high nibble into low nibble location
                        call      #LCD_Send_Nibble                              ' Send first nibble
                        mov       t1,LCD_byte                                   ' Reload LCD_Byte
                        call      #LCD_Send_Nibble                              ' Send second nibble
LCD_Command_ret
LCD_Text_ret            ret

LCD_Send_Nibble
                        and       t1,#$0F                                       ' Preserve the low nibble
                        shl       t1,LCD_offset                                 ' Move the low nibble to the LCD pin locations
                        andn      outa,LCD_mask                                 ' Clear the LCD pins
                        or        outa,t1                                       ' Update the LCD pins
                        call      #Clock           
LCD_Send_Nibble_ret     ret
'----------------------------------------------------------------------------------------------------------------------
Check_Busy_Flag
                        andn      dira,D7_mask
                        andn      outa,RS_mask
                        or        outa,RW_mask
:Loop
                        or        outa,E_mask
                        nop
                        test      D7_mask,ina           wz                      ' Busy flag should be checked while E is high
                        andn      outa,E_mask
                        call      #Clock
          if_ne         jmp       #:Loop                                  
                        or        dira,D7_mask
                        andn      outa,RW_mask
Check_Busy_Flag_ret     ret
'----------------------------------------------------------------------------------------------------------------------
Clock
                        or        outa,E_mask
                        mov       Delay_cnt,#1                                  ' Turns out not much delay at all is needed here                        
                        djnz      Delay_cnt,#$
                        andn      outa,E_mask
Clock_ret               ret
'======================================================================================================================
_15ms                   long      1_200_000                                     ' Used in initialization routine
_4_1ms                  long        328_000
_100us                  long          8_000                    

head_address            res       1
tail_address            res       1
buffer_address          res       1

E_mask                  res       1                                  
RW_mask                 res       1
RS_mask                 res       1                                 
D7_mask                 res       1
LCD_mask                res       1
LCD_offset              res       1

LCD_byte                res       1

t1                      res       1
t2                      res       1

Delay_cnt               res       1
                        fit

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