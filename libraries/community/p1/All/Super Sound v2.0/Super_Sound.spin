{{

┌┐
 Super_Sound                              
 Author: Thomas E. McInnes                                
 See end of file for terms of use .                        
└┘

}}
VAR

  Long cctrl, oldcctrl
  Long laudio, raudio
  Byte count

OBJ

  d     :       "DTMF"
  c     :       "Ciphers"
  m     :       "morse_code"
  s     :       "Synth"

PUB start(left, right)

  laudio := left
  raudio := right
  d.start_up(1, 0)
  m.start_up(raudio)                                   

PUB cipher_ctrl(ctrl)

  cctrl := ctrl

PUB Help

  oldcctrl := cctrl
  cipher_ctrl(false)
  d.tech_support                      
  waitcnt((clkfreq * 12) + cnt)
  m.help
  waitcnt(clkfreq + cnt)
  m.str(@hstring)
  waitcnt(clkfreq + cnt)
  m.help
  cipher_ctrl(oldcctrl)

PUB m_out(character)

  if cctrl == true
    m.out(c.SubCipher(character))
  elseif cctrl == false
    m.out(character)

PUB m_str(text_ptr)

  count := 0
  if cctrl == true
    repeat until count == strsize(text_ptr)
      m.out(c.Subcipher(byte[text_ptr][count++])) 
  elseif cctrl == false
    m.str(text_ptr)    

PUB tone(number)

  d.tone(number)

PUB Synth_A(frequency)

  s.Synth("A", frequency, laudio)

PUB Synth_B(frequency)

  s.Synth("B", frequency, laudio)
  
PUB Quiet

  s.silence_a(laudio)
  s.silence_b(laudio)

DAT

hstring       Byte      "I am a robot in need of help", 0
     
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