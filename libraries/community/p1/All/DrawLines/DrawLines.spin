{{ 
  ┌──────────────────────────────────────────────────────┐
  │         Bresenham's Line Algorithm in Assembly       │
  ├──────────────────────────────────────────────────────┤
  │ The purpose of this project is to implement          │
  │ Bresenham's Line Algorithm using Propeller Assembly  │ 
  │ Language.                                            │
  │                                                      │
  │              by: Jim Pyne                            │
  │              ENT234                                  │
  │              Berkshire Community College             │
  │              Pittsfield, MA                          │
  │                                                      │
  ├──────────────────────────────────────────────────────┤
  │                     5 - 22 - 2010                    │
  └──────────────────────────────────────────────────────┘ 
}}
CON
{{
 
  ┌────────────────────────────────────────────────────┐
  │              Current List of COMMANDS              │
  ├────────────────────────────────────────────────────┤
  │                                                    │
  │                      SET_XY                        │
  │                     CLEAR_XY                       │
  │                                                    │ 
  │                     DRAW_LINE                      │
  │                    UNDRAW_LINE                     │
  │                                                    │
  │                     DRAW_RECT                      │
  │                    UNDRAW_RECT                     │
  │                                                    │
  ├────────────────────────────────────────────────────┤
  │ *** To add COMMANDS, please refer to detailed ***  │
  │ ***       instructions at end of program.     ***  │
  └────────────────────────────────────────────────────┘ 

}}
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  tiles    = vga#xtiles * vga#ytiles
  tiles32  = tiles * 32
                                  '%.......1   if this bit is set then  draw a pixel
                                  '%......1.      "    "      "         clear a pixel
  SET_XY           =               %00000001   'decimal = 1
  CLEAR_XY         =               %00000010   'decimal = 2
  DRAW_LINE        =               %00000101   'decimal = 5
  UNDRAW_LINE      =               %00000110   'decimal = 6
  DRAW_RECT        =               9
  UNDRAW_RECT      =              10
  DRAW_ARC         =              17

OBJ
{{
              Based on this code:
  ********************************************
  *  VGA 512x384 2-Color Bitmap Driver v1.0  *
  *  Author: Chip Gracey                     *
  *  Copyright (c) 2006 Parallax, Inc.       *
  *  See end of file for terms of use.       *
  ********************************************

}}
  vga : "vga_512x384_bitmap"
  
VAR
  word  colors[tiles]
  long  sync, pixels[tiles32]
'Param Block
  long  graphicCmd    ' <---- This is where ASSEMBLY grabs the commands from
  long  baseAdd       ' Address where SCREEN memory is located.
  long  stX
  long  stY           ' stX, stY are Start Location of pixel ( x,y )
  long  spX
  long  spY           ' spX, spY are Stop Location of pixel ( x,y )

PUB start | i, ts, lastx, lasty, newx, newy

  'start vga
  vga.start(16, @colors, @pixels, @sync)

  'init colors to cyan on blue
  repeat i from 0 to tiles - 1
'               Foreground Background 
'                 RRGGBB00 RRGGBB00 
'   colors[i] := %00101000_00000100
    colors[i] := %10101000_00010000

  graphicCmd := 99                ' Set graphicCmd to random hi number to pause spin first time  
  baseAdd := @pixels[0]           ' Set base address as the start of the pixel array  
  cognew(@plotDriver,@graphicCmd) ' Start the graphics code in another COG
  repeat while(graphicCmd <> 0)   ' Allow time for cog to return control to SPIN

' -----------------------------------  Begin DEMO MODE  ---------------------------------------
  'Clear the screen
  cls

  'Title screen
  ts := 2
  waitcnt(clkfreq*1+cnt)
  titleScreen(ts,1)    ' Pre Defined Title Screen for example purposes
  waitcnt(clkfreq*5+cnt)

  repeat 'forever
    'Clear the screen
    cls

    'Get new random x,y
    newx := || ?i//512 
    newy := || ?i//384 

    'Repeat for the number of random lines desired
    repeat 200
      'Save old x,y 
      lastx := newx
      lasty := newy
      'Get new x,y
      newx := || ?i//512 
      newy := || ?i//384 
      'Draw the line from old x,y to new x,y
      line(lastx,lasty,newx,newy,1)
      'Delay because the line code is so fast
      waitcnt(clkfreq/50+cnt)

    'Clear the screen
    cls

    'Repeat for the number of random rectangles desired
    repeat 100
      'Save old x,y 
      lastx := newx
      lasty := newy
      'Get new x,y
      newx := || ?i//512 
      newy := || ?i//384 
      'Draw the rectangle from old x,y to new x,y
      rect(lastx,lasty,newx,newy,1)
      'Delay because the line code is so fast
      waitcnt(clkfreq/50+cnt)

' -------------------------------------  End DEMO MODE  --------------------------------------- 
PUB line(sx0,sy0,sx1,sy1,k)
{{
  ┌─────────────────────────┐
  │  DETAILED INSTRUCTIONS  │
  └─────────────────────────┘
 
  ┌─────────────────────────────────────────────────────────────────────────────────────────────┐
  │                                         LINE FORMAT                                         │
  ├─────────────────────────────────────────────────────────────────────────────────────────────┤
  │                                                                                             │
  │     1.   Set the Coordinates you wish to use. In this example we will draw a                │
  │          line from ( 10 , 10 ) to ( 10 , 100 ).                                             │
  │                                                                                             │
  │     2.   ie:                                                                                │
  │             line( 10,10,10,100,1)  Draws a line from ( 10,10 ) to ( 10,100 )                │
  │                                ^                                                            │
  │                                └────────────────────────  0 = clear   1 = draw              │
  │                                                                                             │ 
  │                                                                                             │
  │                         (10,10) ────────>   │                                               │
  │                                             │                                               │
  │                                             │                                               │
  │                                             │                                               │
  │                                             │                                               │
  │                                             │                                               │
  │                                             │                                               │
  │                                             │                                               │
  │                                             │                                               │
  │                                             │  <─────(10,100)                               │
  │                                                                                             │
  └─────────────────────────────────────────────────────────────────────────────────────────────┘

}}
  stX := sx0
  stY := sy0
  spX := sx1
  spY := sy1

   if (k == 1)
     graphicCmd := DRAW_LINE
   else
     graphicCmd := UNDRAW_LINE

  repeat while(graphicCmd <> 0)
  
PUB rect(sx0,sy0,sx1,sy1,k)
{{

  ┌─────────────────────────────────────────────────────────────────────────────────────────────┐
  │                                      RECTANGLE FORMAT                                       │                                                            
  ├─────────────────────────────────────────────────────────────────────────────────────────────┤
  │                                                                                             │
  │     1.   Set the Coordinates you wish to use. In this example we will draw a                │
  │          rectangle from ( 10 , 10 ) to ( 100 , 100 ).                                       │
  │                                                                                             │
  │     2.   ie:                                                                                │
  │             rect( 10,10,100,100,1)  Draws a rectangle from ( 10,10 ) to ( 100,100 )         │
  │                                 ^                                                           │
  │                                 └────────────────────────  0 = clear   1 = draw             │
  │                                                                                             │
  │                                                                                             │ 
  │                    (10,10) ┌─────────────────────────────────┐                              │
  │                            │                                 │                              │
  │                            │                                 │                              │
  │                            │                                 │                              │
  │                            │                                 │                              │
  │                            │                                 │                              │
  │                            │                                 │                              │
  │                            │                                 │                              │
  │                            │                                 │                              │
  │                            └─────────────────────────────────┘ (100,100)                    │
  │                                                                                             │
  └─────────────────────────────────────────────────────────────────────────────────────────────┘
  
}}
  stX := sx0
  stY := sy0
  spX := sx1
  spY := sy1

   if (k == 1)
     graphicCmd := DRAW_RECT
   else
     graphicCmd := UNDRAW_RECT

  repeat while(graphicCmd <> 0)
  
PUB titleScreen(s,k) | i
{{
Used for DEMO.
}}
  
    repeat i from 0 to 511 step s
       line(i,0,(510-i),383,k)

    repeat i from 0 to 383 step s
       line(0,i,510,(383-i),k)

    repeat i from 0 to 10
       rect(180+i,130+i,330-i,250-i,0)

    repeat i from 0 to 80
       line(200,150+i,225,150+i,0)
       line(250,150+i,280,150+i,0)
       line(290,150+i,320,150+i,0)

    repeat i from 130 to 250
      line(235,i,240,i,0)
      line(275,i,280,i,0)

    repeat i from 180 to 190
      line(200,i,225,i,k)
      line(230,i,235,i,0)

PUB cls   | c
{{
Used for clearing the screen.
}}
  longfill(@pixels,0,tiles32)     
   
DAT
                        ORG     0
plotDriver              mov     pblock,par      'Go snag the address of the parameter block
Re_Entry                mov     gCmd, #0        'Clear the command register in the COG to start
                        wrlong  gCmd, pblock    'Clear command in main RAM                                    

'******************************************************
'**************  Check for a command  *****************
'******************************************************

getCmd                  rdlong  gCmd, pblock wz           ' Read a new command from main memory
           if_z         jmp     #getCmd                   ' No command (zero) then keep looking
                        cmp     gCmd, #SET_XY  wz          'If command is SET_XY
           if_e         jmp     #plotXY
                        cmp     gCmd, #CLEAR_XY  wz        'If command is CLEAR_XY
           if_e         jmp     #plotXY
                        cmp     gCmd, #DRAW_LINE  wz       'If command is DRAW_LINE
           if_e         call    #drawLine
                        cmp     gCmd, #UNDRAW_LINE  wz     'If command is UNDRAW_LINE
           if_e         call    #drawLine
                        cmp     gCmd, #DRAW_RECT  wz       'If command is DRAW_RECT
           if_e         call    #drawRect
                        cmp     gCmd, #UNDRAW_RECT  wz     'If command is UNDRAW_RECT
           if_e         call    #drawRect
                        cmp     gCmd, #DRAW_ARC  wz        'If command is DRAW_ARC
           if_e         jmp     #drawArc
'
'                       Add other commands here...
'
                        jmp     #Re_Entry               ' command is not found,jump back to top
                        
'******************************************************
'*********************  Plot X,Y  *********************
'******************************************************

plotXY                  mov     temp, pblock            'Get all the parameters (except the 
                        add     temp,#4                 '      command...we already have that)
                        rdlong  pixelAdd, temp          'Get the bitmap base address
                        add     temp,#4
                        rdlong  plotX, temp             'Get X
                        add     temp,#4
                        rdlong  plotY, temp             'Get Y
                        call    #plotPoint              'Made into a function call
                        jmp     #Re_Entry

'******************************************************
'*********************  Get X and Y *******************
'******************************************************

snagXandY               mov     temp, pblock            'Get all the parameters (except the
                        add     temp,#4                 '      command...we already have that)
                        rdlong  pixelAdd, temp          'Get the bitmap base address
                        add     temp,#4
                        rdlong  x0, temp                'Get X0
                        add     temp,#4
                        rdlong  y0, temp                'Get Y0
                        add     temp,#4
                        rdlong  x1, temp                'Get X1
                        add     temp,#4
                        rdlong  y1, temp                'Get Y1
snagXandY_ret           ret                           

'******************************************************
'*********************  Draw Line  ********************
'******************************************************

drawLine
                        cmp     gCmd, #DRAW_LINE  wz     ' If command is DRAW_LINE
           if_e         call    #snagXandY               '  <---- get Start/Stop X and Y --<<<
                        cmp     gCmd, #UNDRAW_LINE  wz   ' If command is UNDRAW_LINE
           if_e         call    #snagXandY              
                                                        
                        mov     steep,#0                ' Adapted/converted from psuedo-code 
                        mov     xt0,x0                  ' found on Wikipedia:
                        mov     yt0,y0                  ' <http://en.wikipedia.org/wiki/
                        mov     xt1,x1                  ' Bresenham's_line_algorithm>  
                        mov     yt1,y1
                        sub     xt1,xt0                 ' steep:= ||(y1 - y0) > ||(x1 - x0)
                        abs     xt1,xt1                 ' Absolute value of x1-x0
                        sub     yt1,yt0
                        abs     yt1,yt1                 ' Absolute value of y1-y0
                        cmp     xt1,yt1         wz,wc   ' ||(y1 - y0) > ||(x1 - x0)  ???
            if_c        mov     steep,MY_TRUE           ' if yt1 > xt1 then set steep to TRUE
                        cmp     steep,MY_TRUE  wz       ' if steep    ( is true, or -1 )
            if_e        mov     temp1,x0                '      swap x0 and y0
            if_e        mov     x0,y0
            if_e        mov     y0,temp1
            if_e        mov     temp1,x1                 '     swap x1 and y1
            if_e        mov     x1,y1
            if_e        mov     y1,temp1
                        cmp     x1,x0         wz,wc      'If x0>x1
            if_b        mov     temp1,x0                 '     swap x0 and x1
            if_b        mov     x0,x1
            if_b        mov     x1,temp1
            if_b        mov     temp1,y0
            if_b        mov     y0,y1                   '      swap(@y0, @y1)
            if_b        mov     y1,temp1
                        mov     deltax,x1
                        sub     deltax,x0               ' deltax := x1 - x0
                        mov     deltay,y1
                        sub     deltay,y0               ' deltay := ||(y1 - y0)
                        abs     deltay,deltay           ' absolute value of deltay into deltay
                        mov     error,deltax               ' error := deltax << 1
                        shr     error,#1
                        mov     yy,y0                   ' yy := y0
                        cmp     y0,y1         wz,wc     ' if y0<y1
            if_c        mov     ystep,#1                '              ystep := 1 
            if_nc       mov     ystep,MY_TRUE           '     else     ystep := -1
                        mov     xx,x0                   ' load xx with x0
:Loop1                  cmp     steep,MY_TRUE   wz,wc   ' if steep
           if_b         jmp     #:nplot

                        mov     plotX,yy                '        (if steep is true)
                        mov     plotY,xx                '                plot yy,xx
                        call    #plotPoint
                        jmp     #:pplot
:nplot
                        mov     plotX,xx                'if steep is false
                        mov     plotY,yy                '                plot xx,yy
                        call    #plotPoint
:pplot
                        subs    error, deltay           ' error := error - deltay
                        cmps    error,#0     wz,wc      ' if error < 0
           if_a         jmp     #:hop                   '    if error >= 0 skip over next code
                        add     yy,ystep                '    if error < 0 then yy := yy + ystep
                        add     error,deltax            '      error := error + deltax
:hop                    cmp     xx,x1           wz      ' is xx=x1 ? check if repeat loop done
           if_ne        add     xx,#1                   ' if false, add 1
           if_ne        jmp     #:Loop1                 ' then jump back up to Loop1
drawLine_ret            ret 

'******************************************************
'*********************  Draw Rect  ********************
'******************************************************

drawRect                call    #snagXandY
                        mov     rx0, x0
                        mov     ry0, y0                  ' Grab x0,y0  and x1,y1  store
                        mov     rx1, x1
                        mov     ry1, y1

                        mov     y1,y0
                        call    #drawLine                ' Top Shelf

                        mov     x0,rx0
                        mov     y0,ry0
                        mov     x1,x0                    ' Left Side
                        mov     y1,ry1
                        call    #drawLine

                        mov     x0,rx0
                        mov     y0,ry1
                        mov     x1,rx1                   ' Bottom Shelf 
                        mov     y1,ry1
                        call    #drawLine

                        mov     x0,rx1
                        mov     y0,ry0
                        mov     x1,rx1                   ' Right Side
                        mov     y1,ry1
                        call    #drawLine

drawRect_ret            ret 


'******************************************************
'*********************  Draw Arc  *********************
'******************************************************
'For next semester
drawArc
drawArc_ret            ret 


'******************************************************
'*********************  plotPoint  ********************
'******************************************************
plotPoint
                        mov     temp,plotX             ' Save plotX in temp to restore later
                        mov     pX,plotX
                        mov     pY,plotY
                        shl     plotY,#4               ' Y<<4
                        shr     plotX,#5               ' X>>5
                        add     plotX,plotY            ' [y<<4+x>>5]
                        shl     plotX,#2               ' shift left 2 to address longs in RAM
                        mov     calcAdd,pixelAdd
                        add     calcAdd,plotX          ' Add to base register
                        mov     plotX,temp                      
                        mov     mask, #1
                        shl     mask,plotX             ' Shift the bit in the mask                        
                                                       ' Read the long in the bitmap and
                                                       ' OR or AND the pixel and write it back
                        rdlong  temp, calcAdd
                        and     gCmd,#2 wz             'If bit 1 is set then call to CLEAR_XY
           if_z         or      temp,mask              'SET_XY
           if_nz        andn    temp,mask              'CLEAR_XY
                        wrlong  temp, calcAdd
plotPoint_ret           ret
'**********************************************************************************************
MY_TRUE                 long    $FFFFFFFF
BIT31                   long    $80000000
steep                   res     1   
deltax                  res     1   
deltay                  res     1   
error                   res     1   
ystep                   res     1   
yy                      res     1   
xx                      res     1   

x0                      res     1
y0                      res     1
x1                      res     1
y1                      res     1

xt0                     res     1
yt0                     res     1
xt1                     res     1
yt1                     res     1

pblock                  res     1
gCmd                    res     1
pixelAdd                res     1
calcAdd                 res     1
plotX                   res     1
plotY                   res     1
pX                      res     1
pY                      res     1
temp                    res     1
mask                    res     1
temp1                   res     1

rx0                     res     1
ry0                     res     1
rx1                     res     1
ry1                     res     1

                        FIT
{{
┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                              ADDING COMMANDS TO THE CON Block                               │                                                            
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│  Command Names use a number that help determines if plot( x,y ) will SET or CLEAR a bit.    │
│                                                                                             │
│             In the example below, DRAW_LINE is assigned a decimal value of 5.               │
│                                                                                             │
│ This is converted into  0101 in Binary. If the LSB is a 1, this means you will SET a bit.   │
│                                                                                 │           │
│                                                                                 │           │
│          DRAW_LINE     =           %0000 0 1 0 1   'decimal = 5                 │           │
│                                                ^                                │           │
│                                                └────────────────────────────────┘           │
│                                                                                             │
│                                                                                             │
│          UNDRAW_LINE   =           %0000 0 1 1 0   'decimal = 6                             │
│                                              ^                                              │
│                                              │                                              │
│                                              └─────────────────────────┐                    │
│                                                                        │                    │
│ When UNDRAW_LINE was declared, it was given the decimal value 6,       │                    │
│ Which becomes 0110 in Binary. If the second LSB is a 1, this says to CLEAR the bit.         │
│                                                                                             │
└─────────────────────────────────────────────────────────────────────────────────────────────┘


┌─────────────────────────────────────────────────────────────────────────────────────────────┐
│                                      TERMS OF USE: MIT License                              │                                                            
├─────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this         │
│software and associated documentation files (the "Software"), to deal in the Software without│
│restriction, including without limitation the rights to use, copy,modify, merge, publish,    │
│distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom    │
│the Software is furnished to do so, subject to the following conditions:                     │  
│                                                                                             │
│The above copyright notice and this permission notice shall be included in all copies or     │
│substantial portions of the Software.│                                                       │
│                                                                                             │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,          │
│INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR     │
│PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE    │
│FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR         │
│OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER       │
│DEALINGS IN THE SOFTWARE.                                                                    │
└─────────────────────────────────────────────────────────────────────────────────────────────┘

}}    