{{
   ┌──────────────────────────────────────────┐
   │ Copyright (c) <2008> <Stephen Holland>   │               
   │   See end of file for terms of use.      │               
   └──────────────────────────────────────────┘

ezLCD-002 display demo

}}
CON

  _CLKMODE      = XTAL1 + PLL16X
  _XINFREQ      = 5_000_000
 
  Led_pin0      = 0                                     ' bicolor LED anode
  Led_pin1      = 1                                     ' bicolor LED cathode 
  RX_PIN        = 22
  TX_PIN        = 23
  MODE          = %0000                                 ' see FullDuplexSerial.spin for description
  BAUD          = 115200   '9600                                  ' 9600 baud, true

  'Color table
  BLACK     = %00000000 
  RED       = %00000111
  YELLOW    = %00111111
  GREEN     = %00111000
  BLUE      = %11000000        
  NAVY      = %10000000
  PURPLE    = %11000100 
  WHITE     = %11111111

  'Drawing Commands
  Arc = $2F
  Box = $42
  Box_fill = $43
  Circle_r = $29
  Circle_r_fill = $39
  Cls = $21
  H_line = $40
  Light_off = $23
  Light_on = $22
  Line_to_xy = $28
  Picture = $2A
  Plot = $26
  Plot_xy = $27
  Print_char = $2C
  Print_char_bg = $3C
  Print_string = $2D
  Print_string_bg = $3D
  Put_bitmap = $2E
  Put_icon = $57
  Put_sf_icon = $58
  Select_font = $2B
  Set_bg_color = $34
  Set_color = $24
  Set_xy = $25
  Text_north = $60                                     '- default (landscape)
  Text_east = $61                                      '- portrait
  Text_south = $62                                     '- landscape upside down
  Text_west = $63                                      '- portrait upside down
  V_line = $41
  'Touch Screen commands
  touch_cell_x = 30
  touch_cell_y = 27

var
  long  cog                                             'cog flag/id
  long  offsetx,offsety,xy,count,lasttouch 
  long  Stack[16]                                       'Stack space for new cog
  long  demo
  
OBJ
  serial : "fullduplexserial"                           ' use buffered serial
   delay : "timing" 
        
PUB Start : okay
{{Start new ezLCD-002 process in a new cog.}}

  okay := cog := cognew(initDisplay, @Stack) + 1

  stop
  if serial.start(RX_PIN, TX_PIN, MODE, BAUD)           ' initialize serial object
    initDisplay
     
PUB Stop
{{Stop ezLCD-002 process, if any.}}
  if Cog
    cogstop(Cog~ - 1)  

PRI initDisplay

  serial.tx(light_on)
  serial.tx(set_color)
  serial.tx(black)                                 
  serial.tx(cls)
  offsetx := 0  
  offsety := 0  
{    
  repeat
    lasttouch := checkTouch(FALSE)  
    delay.pause1mS(100)
}
    
PUB returntouch | rtouch
  rtouch := lasttouch 
  return rtouch

PUB checkTouch(touchfeedback) : touch
{{Gets touch coordinates, and returns them. touchfeedback = TRUE displays the touched cell in blue.}} 
  touch := serial.rxcheck

  if touchfeedback == TRUE
    ifnot (touch & $80)                ' check for bit 7
     
      serial.tx(set_color)
      serial.tx(blue)                                 
      offsetx := touch & $07
      offsety := touch >> 4
     
      ' Highlight each touched cell
      serial.tx(Set_xy)
      xy := 0
      count := offsetx
      repeat 8
        if count > 0 
          xy += touch_cell_x
          count -= 1
      serial.tx(xy)                                          
      xy := 0
      count := offsety
      repeat 6
        if count > 0
          xy += touch_cell_y
          count -= 1
      serial.tx(xy)                                          
      serial.tx(box_fill)
      xy := touch_cell_x
      count := offsetx
      repeat 8
        if count > 0
          xy += touch_cell_x
          count -= 1
      serial.tx(xy)                                          
      xy := touch_cell_y
      count := offsety
      repeat 6
        if count > 0
          xy += touch_cell_y
          count -= 1 
      serial.tx(xy)                                          
      'touch := 0 
    else
     
   
PUB drawBox(x1,y1,x2,y2,bt,bcolor,fcolor)

  serial.tx(set_color)
  serial.tx(fcolor)                                 
  serial.tx(set_xy)
  serial.tx(x1)        
  serial.tx(y1)
  serial.tx(box_fill)
  serial.tx(x2)
  serial.tx(y2)

  count := bt
  repeat while count <> 0
    serial.tx(set_color)
    serial.tx(bcolor)                                 
    serial.tx(set_xy)
    serial.tx(count+x1)        
    serial.tx(count+y1)
    serial.tx(box)
    serial.tx(count+x2)
    serial.tx(count+y2)    
    count -= 1

PUB drawArc(x1,y1,r,begangle,endangle,thickness,color)

  serial.tx(set_color)
  serial.tx(color)                                 
  serial.tx(set_xy)
  serial.tx(x1)        
  serial.tx(y1)
  serial.tx(arc)
  serial.tx(r)
  serial.tx(begangle)
  serial.tx(endangle)

  count := thickness
  repeat while count <> 0
    serial.tx(arc)
    serial.tx(r-count)
    serial.tx(begangle)
    serial.tx(endangle)
    count -= 1

PUB writeString(x,y,fs,dir,color,strAddr)

  serial.tx(select_font)
  serial.tx(fs)
  serial.tx(set_color)
  serial.tx(color)
  serial.tx(set_xy)
  serial.tx(x)                                          
  serial.tx(y)
  serial.tx(text_north) 
  serial.tx(print_string)
  serial.str(strAddr)
  serial.tx(0)

PUB writeHex(x,y,fs,dir,color,value,size)

  serial.tx(select_font)
  serial.tx(fs)
  serial.tx(set_color)
  serial.tx(color)
  serial.tx(set_xy)
  serial.tx(x)                                          
  serial.tx(y)
  serial.tx(text_north) 
  serial.tx(print_string)
  serial.hex(value,size)
  serial.tx(0)
             
PUB writeDec(x,y,fs,dir,color,value)

  serial.tx(select_font)
  serial.tx(fs)
  serial.tx(set_color)
  serial.tx(color)
  serial.tx(set_xy)
  serial.tx(x)                                          
  serial.tx(y)
  serial.tx(text_north) 
  serial.tx(print_string)
  serial.dec(value)
  serial.tx(0)
             
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