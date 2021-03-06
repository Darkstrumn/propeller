'' ===========================================================================
''  VGA High-Res Text UI Elements Base UI Support Functions  v1.2
''
''  File: SimpleBox.spin
''  Author: Allen Marincak
''  Copyright (c) 2009 Allen MArincak
''  See end of file for terms of use
'' ===========================================================================
''
''============================================================================
'' SimpleBox Control
''============================================================================
''
'' Just draws a box with optional title, plain and simple.
''

PUB DrawBox( pRow, pCol, pWidth, pHeight, pTitlePtr, pVgaPtr, pVgaWidth ) | idx, vgaIdx, rowCnt, tbTitle, vgaStartIdx
  vgaStartIdx := pRow * pVgaWidth + pCol
  
  vgaIdx := vgaStartIdx                         'clear the area first
  repeat pHeight
    bytefill(@byte[pVgaPtr][vgaIdx],32,pWidth)
    vgaIdx += pVgaWidth

  vgaIdx := vgaStartIdx                         'goto top left row/col
  
  byte[pVgaPtr][vgaIdx++] := 10                 'top left corner char
  bytefill(@byte[pVgaPtr][vgaIdx],14,pWidth-2)  'horizontal line 
  vgaIdx += pWidth - 2
  byte[pVgaPtr][vgaIdx++] := 11                 'top right corner char
    
  vgaIdx := vgaStartIdx + pVgaWidth             'move down to start of next row

  if pTitlePtr <> 0                             'if there is a title
    
    byte[pVgaPtr][vgaIdx++] := 15               'vertical line char
     
    idx := strsize( pTitlePtr )
    bytemove( @byte[pVgaPtr][vgaIdx], pTitlePtr, idx )'place title         
    vgaIdx += pWidth - 2
    byte[pVgaPtr][vgaIdx++] := 15               'vertical line char

    vgaIdx := vgaStartIdx + 2 * pVgaWidth       'move down to start of next row

    byte[pVgaPtr][vgaIdx++] := 18               'left 'tee' char
    bytefill(@byte[pVgaPtr][vgaIdx],14,pWidth-2)'horizontal line 
    vgaIdx += pWidth - 2
    byte[pVgaPtr][vgaIdx++] := 19               'right 'tee' char
    
    rowCnt := 3                                 'row counter
    
  else
  
    rowCnt := 1                                 'row counter

  vgaIdx := vgaStartIdx + pVgaWidth * rowCnt    'move down to start of next row
  repeat pHeight - rowCnt - 1
    byte[pVgaPtr][vgaIdx++] := 15               'vertical line char
    vgaIdx += pWidth - 2
    byte[pVgaPtr][vgaIdx++] := 15               'vertical line char
    vgaIdx -= pWidth
    vgaIdx += pVgaWidth

  'the above left vgaIdx pointing to the start of the last line
  
  byte[pVgaPtr][vgaIdx++] := 12                 'bottom left corner char
  bytefill(@byte[pVgaPtr][vgaIdx],14,pWidth-2)  'horizontal line 
  vgaIdx += pWidth - 2
  byte[pVgaPtr][vgaIdx++] := 13                 'bottom right corner char

{{
┌────────────────────────────────────────────────────────────────────────────┐
│                     TERMS OF USE: MIT License                              │                                                            
├────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy│
│of this software and associated documentation files (the "Software"), to    │
│deal in the Software without restriction, including without limitation the  │
│rights to use, copy, modify, merge, publish, distribute, sublicense, and/or │
│sell copies of the Software, and to permit persons to whom the Software is  │
│furnished to do so, subject to the following conditions:                    │
│                                                                            │
│The above copyright notice and this permission notice shall be included in  │
│all copies or substantial portions of the Software.                         │
│                                                                            │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR  │
│IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,    │
│FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE │
│AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER      │
│LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING     │
│FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS│
│IN THE SOFTWARE.                                                            │
└────────────────────────────────────────────────────────────────────────────┘
}}   