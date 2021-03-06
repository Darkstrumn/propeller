'' JET ENGINE v1
'' (C)2018 IRQ Interactive
'' Spin Glue code
'' very loosley based on JT Cook's Ranquest driver
''
'' Specs:
'' Tilemap of 16x12 tiles
'' 32 Sprites per screen, 8 per line, lots of settings

CON
  X_Length = 32 ''number of tiles that run horizontally across screen
  Y_Length = 24 ''number of tiles that run vertically across screen

' constants
 SCANLINE_BUFFER = $7800
 NUM_LINES = gfx#NUM_LINES
 SPR_BUCKETS = SCANLINE_BUFFER - (NUM_LINES*8)
 request_scanline       = SPR_BUCKETS-2      'address of scanline buffer for TV driver
 tilemap_adr            = SPR_BUCKETS-4      'address of tile map
 tile_adr               = SPR_BUCKETS-6 'address of tiles (must be 64-byte-aligned)
 border_color           = SPR_BUCKETS-8 'address of border color      
 oam_adr             =    SPR_BUCKETS-10      'address of where sprite attribs are stored
 oam_in_use             =    SPR_BUCKETS-12
 debug_shizzle             =    SPR_BUCKETS-16
 text_colors             =    SPR_BUCKETS-18
 first_subscreen        =    SPR_BUCKETS-20
 buffer_attribs         = SPR_BUCKETS-28 'array of 8 bytes
 aatable                = SPR_BUCKETS-60 'array of 32 bytes
 aatable8               = SPR_BUCKETS-76 'array of 16 bytes

 x_tiles = 16 '*16=240
 y_tiles = 12 '*16=160

 num_sprites    = gfx#num_sprites


OBJ
  tv    : "JET_v01_composite.spin"             ' tv driver 256 pixel scanline
  gfx   : "JET_v01_rendering.spin"    ' graphics engine

VAR
   'byte Tile_Map[X_Length*Y_Length] ''tile map
   'byte Tiles[(64)*Num_Of_Tiles] ''number of tiles (8x8 pixels = 64)

   long cog_number ''used for rendering engine
   long cog_total  ''used for rendering engine  
   'long border_color ''used for borders
''used for TV driver
   long tv_status      '0/1/2 = off/visible/invisible           read-only
   long tv_enable      '0/? = off/on                            write-only
   long tv_pins        '%ppmmm = pins                           write-only
   long tv_mode        '%ccinp = chroma,interlace,ntsc/pal,swap write-only
   long tv_screen      'pointer to screen (words)               write-only
   long tv_colors      'pointer to colors (longs)               write-only               
   long tv_hc          'horizontal cells                        write-only
   long tv_vc          'vertical cells                          write-only
   long tv_hx          'horizontal cell expansion               write-only
   long tv_vx          'vertical cell expansion                 write-only
   long tv_ho          'horizontal offset                       write-only
   long tv_vo          'vertical offset                         write-only
   long tv_broadcast   'broadcast frequency (Hz)                write-only
   long tv_auralcog    'aural fm cog                            write-only
''used to stop and start tv driver

PUB tv_start(NorP)
  long[@tvparams+12]:=NorP ''NTSC or PAL60
  tv.start(@tvparams)

PUB tv_stop
   tv.stop
   
PUB start(video_pins,NorP, cog_num)      | i, ready
  DIRA[0] := 1
  outa[0] := 0

  'long[tilemap_adr] := @Tile_Map  'address of tile map
  long[@tvparams+8]:=video_pins ''map pins for video out

  
  ' Boot requested number of rendering cogs:
  ' this must be 4, because bit magic
  longfill(SPR_BUCKETS,$01 ,NUM_LINES*8)
  cog_total :=cog_num
  cog_number := 0
  ready~
  repeat 4
    gfx.start(cog_number,SPR_BUCKETS+(cog_number*(NUM_LINES*2)),@ready)
    cog_number++
  ready~~
  word[border_color]:=$04 ''default border color
  'start tv driver
  tv_start(NorP)

PUB Wait_Vsync ''wait until frame is done drawing
    repeat while word[request_scanline] <> NUM_LINES-1
PUB Wait_frickVsync
    repeat while word[request_scanline] < NUM_LINES-2
PUB Set_Border_Color(bcolor) | i ''set the color for border around screen
    long[border_color]:=bcolor
PUB Set_Filter(i1,s1p,s1e,s1s,i2,s2p,s2e,s2s)
  ovli1             := i1
  ovls1_ptr         := s1p       
  ovls1_end         := s1e      
  ovls1_start       := s1s     
  ovli2             := i2      
  ovls2_ptr         := s2p      
  ovls2_end         := s2e   
  ovls2_start       := s2s
PUB Set_Scrollborder(pal,patp,pate,pats)
  borderpal         := pal
  scrollborder_ptr  := patp
  scrollborder_end  := pate
  scrollborder_start:= pats
          
DAT
tvparams                long    0               'status
                        long    1               'enable
                        long    %011_0000       'pins ' PROTO/DEMO BOARD = %001_0101 ' HYDRA = %011_0000
                        long    0               'mode - default to NTSC
                        long    x_tiles         'hc
                        long    NUM_LINES       'vc
                        long    12              'hx (unused)
                        long    1               'vx
                        long    0               'ho
                        long    0               'vo
                        long    50_000_000'_xinfreq<<4  'broadcast
                        long    0               'auralcog
                        long    SCANLINE_BUFFER
                        long    border_color 'pointer to border colour
                        long    request_scanline
disp_ptr                long    buffer_attribs
VSync                   long    0
                        

'nextline               long    0

ovli1                   long    %011000_000
ovls1_ptr               long    %0
ovls1_end               long    %0
ovls1_start             long    %0
ovli2                   long    %100000_000
ovls2_ptr               long    %0
ovls2_end               long    %0
ovls2_start             long    %0

borderpal               long    $07_05_03_02
scrollborder_ptr        long    %0
scrollborder_end        long    %0
scrollborder_start      long    %0

{{
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                    TERMS OF USE: Parallax Object Exchange License                                            │                                                            
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