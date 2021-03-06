{
********************************************
    Weather Info Screen Demo
********************************************
    Charlie Dixon  2007 
********************************************
This was created with parts of programs from
other users.  Why reinvent the wheel?  :^)
}
CON
  _CLKMODE = XTAL1 + PLL16X
  _XINFREQ = 5_000_000
  _stack = ($3000 + $3000 + 100) >> 2                   'accommodate display memory and stack

  x_tiles = 16
  y_tiles = 12

  x_screen = x_tiles << 4
  y_screen = y_tiles << 4

  width = 0             '0 = minimum
  x_scale = 1           '1 = minimum
  y_scale = 1           '1 = minimum
  x_spacing = 6         '6 = normal
  y_spacing = 13        '13 = normal

  x_chr = x_scale * x_spacing
  y_chr = y_scale * y_spacing

  y_offset = y_spacing / 6 + y_chr - 1

  x_limit = x_screen / (x_scale * x_spacing)
  y_limit = y_screen / (y_scale * y_spacing)
  y_max = y_limit - 1

  y_screen_bytes = y_screen << 2
  y_scroll = y_chr << 2
  y_scroll_longs = y_chr * y_max
  y_clear = y_scroll_longs << 2
  y_clear_longs = y_screen - y_scroll_longs

  paramcount = 14

  display_base = $5000
  bitmap_base = $2000

  a = 81
  bb =40  

VAR
    long  tv_status     '0/1/2 = off/visible/invisible           read-only
    long  tv_enable     '0/? = off/on                            write-only
    long  tv_pins       '%ppmmm = pins                           write-only
    long  tv_mode       '%ccinp = chroma,interlace,ntsc/pal,swap write-only
    long  tv_screen     'pointer to screen (words)               write-only
    long  tv_colors     'pointer to colors (longs)               write-only               
    long  tv_hc         'horizontal cells                        write-only
    long  tv_vc         'vertical cells                          write-only
    long  tv_hx         'horizontal cell expansion               write-only
    long  tv_vx         'vertical cell expansion                 write-only
    long  tv_ho         'horizontal offset                       write-only
    long  tv_vo         'vertical offset                         write-only
    long  tv_broadcast  'broadcast frequency (Hz)                write-only
    long  tv_auralcog   'aural fm cog                            write-only

    word  screen[x_tiles * y_tiles]
    long  colors[64]
    long  x, y     
    long  theta

OBJ
' In the CD_ versions of graphics, FloatMath and Numbers, I just
' commented out portions of the objects that I didn't need to
' reduce the number of longs.  I will eventually just cut and paste
' the parts I need into a condensed file for my final application.

    tv    :     "tv"
    gr    :     "CD_graphics"
    fm    :     "CD_FloatMath"
    Num   :     "CD_Numbers"
    adc   :     "CD_ADC0834"
        
PUB DIAL | i,dx,dy,Temp,Dir

    'start tv
    longmove(@tv_status, @tvparams, paramcount)
    tv_screen := @screen
    tv_colors := @colors
    tv.start(@tv_status)

    'init colors
    repeat i from 0 to 63
      colors[i] := $00001010 * (9) & $F + $2B060C02   '$00001010 * (5+4) & $F + $2B060C02

    'init tile screen
    repeat dx from 0 to tv_hc - 1
      repeat dy from 0 to tv_vc - 1
        screen[dy * tv_hc + dx] := display_base >> 6 + dy + dx * tv_vc + ((dy & $3F) << 10)

   'start and setup graphics, Sensirion and DS1302 RTC
    gr.start                                            'Start Graphics Driver
    gr.setup(16, 12, 128, 96, bitmap_base)
    adc.start(0)

'**************************************************************************************************
' Main Program Loop to display Wind Direction to TV Screen
'**************************************************************************************************

    repeat
      gr.clear                                           'Clear graphics screen
      theta := (adc.GetADC(2) * 64) + 10                 'Adjusted for ADC returning 5V = 0111 1111
      gr.colorwidth(1, 2)                                'Set Color and Width
      gr.textmode(1,1,7,%0100)                           'Set text mode
      gr.arc(0, -1, 95, 95, 0, 23, 360, 0)               'Draw circle
      repeat i from 0 to 32                              'Draw ticks around the circle
        gr.arc(0, -1, 95, 95, i*512, 0, 1, 0)
        gr.arc(0, -1, 85, 85, i*512, 0, 1, 1)

      gr.colorwidth(2, 1)                               'Display theta and degrees
      gr.textmode(1,1,7,%0000)
      gr.text(-128,82,string("Direction:"))
      if (theta > 7939) OR (theta < 258)
        Dir := string("N")
      if (theta > 257) AND (theta < 770)
        Dir := string("NNE")
      if (theta > 769) AND (theta < 1282)
        Dir := string("NE")
      if (theta > 1281) AND (theta < 1794)
        Dir := string("ENE")
      if (theta > 1793) AND (theta < 2306)
        Dir := string("E")
      if (theta > 2305) AND (theta < 2819)
        Dir := string("ESE")
      if (theta > 2818) AND (theta < 3331)
        Dir := string("SE")
      if (theta > 3330) AND (theta < 3843)
        Dir := string("SSE")
      if (theta > 3842) AND (theta < 4355)
        Dir := string("S")
      if (theta > 4354) AND (theta < 4867)
        Dir := string("SSW")
      if (theta > 4866) AND (theta < 5379)
        Dir := string("SW")
      if (theta > 5378) AND (theta < 5891)
        Dir := string("WSW")
      if (theta > 5890) AND (theta < 6403)
        Dir := string("W")
      if (theta > 6402) AND (theta < 6915)
        Dir := string("WNW")
      if (theta > 6914) AND (theta < 7427)
        Dir := string("NW")
      if (theta > 7426) AND (theta < 7940)
        Dir := string("NNW")
      gr.text(-128,65,Dir)
      gr.text(80,82,string("Degree:"))
      x := 16                                           'Like GOTO x,y for Str() :)
      y := -6
      Temp := FM.FDiv(theta, 22.76)                     'High tech math
      Str(Num.ToStr(Temp, Num#DDEC))                    'Diplay theta
      gr.colorwidth(3, 2)                                'Set Color and Width      
      gr.arc(0, -1, 60, 60, -theta+2048, 0, 1, 0)        '(0, -1, 85, 85, -theta+2048, 0, 1, 0)        'Draw needle
      gr.arc(0, -1, 65, 65, -theta+6144, 0, 1, 1)
      gr.arc(0, -1, 5, 5, -theta, 0, 1, 0)               'Draw needle cross
      gr.arc(0, -1, 5, 5, -theta+4096, 0, 1, 1)
      gr.arc(0, -1, 60, 60, -theta+2048-150, 0, 1, 0)    'Draw needle arrow
      gr.arc(0, -1, 70, 70, -theta+2048, 0, 1, 1)      
      gr.arc(0, -1, 60, 60, -theta+2048+150, 0, 1, 1)
      gr.arc(0, -1, 60, 60, -theta+2048-150, 0, 1, 1)
      
      gr.colorwidth(2, 1)
      gr.text(-3, 68,string("N"))
      gr.text(77, -10,string("E"))
      gr.text(-81, -10,string("W"))
      gr.text(-3, -85,string("S"))

      gr.copy(display_base)                            'copy bitmap to display


PUB out(c)

'' Print a character
''
''       $00 = home
''  $01..$03 = color
''  $04..$07 = color schemes
''       $09 = tab
''       $0D = return
''  $20..$7E = character

  case c

    $00:                'home?
      gr.clear
      x := y := 0

    $01..$03:           'color?
      gr.color(c)

    $04..$07:           'color scheme?
      tv_colors := @color_schemes[c & 3]

    $09:                'tab?
      repeat
        out($20)
      while x & 7

    $0D:                'return?
      newline

    $20..$7E:           'character?
      gr.text(x * x_chr, -y * y_chr - y_offset, @c)
      gr.finish
      if ++x == x_limit
        newline

PUB str(string_ptr)

'' Print a zero-terminated string

  repeat strsize(string_ptr)
    out(byte[string_ptr++])

PUB dec(value) | i

'' Print a decimal number

  if value < 0
    -value
    out("-")

  i := 1_000_000_000

  repeat 10
    if value => i
      out(value / i + "0")
      value //= i
      result~~
    elseif result or i == 1
      out("0")
    i /= 10

PRI newline

  if ++y == y_limit
    gr.finish
    repeat x from 0 to x_tiles - 1
      y := bitmap_base + x * y_screen_bytes
      longmove(y, y + y_scroll, y_scroll_longs)
      longfill(y + y_clear, 0, y_clear_longs)
    y := y_max
  x := 0

DAT

Zero                    word    $30
DP                      word    $2E
Hyphen                  word    $2D

tvparams                long    0               'status
                        long    1               'enable
                        long    %001_0101       'pins
                        long    %0000           'mode
                        long    0               'screen
                        long    0               'colors
                        long    x_tiles         'hc
                        long    y_tiles         'vc
                        long    10              'hx
                        long    1               'vx
                        long    0               'ho
                        long    0               'vo
                        long    0               'broadcast
                        long    0               'auralcog

color_schemes           long    $BC_6C_05_02
                        long    $0E_0D_0C_0A
                        long    $6E_6D_6C_6A
                        long    $BE_BD_BC_BA
DAT
     {<end of object code>}
     
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