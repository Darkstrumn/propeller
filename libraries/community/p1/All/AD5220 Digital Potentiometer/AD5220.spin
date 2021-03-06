{{
┌───────────────────────────────────────────────────┐
│ AD5220.spin version 1.0.0                         │
├───────────────────────────────────────────────────┤
│                                                   │               
│ Author: Mark M. Owen                              │
│                                                   │                 
│ Copyright (C)2014 Mark M. Owen                    │               
│ MIT License - see end of file for terms of use.   │                
└───────────────────────────────────────────────────┘

Description:

This object provides a simple means of interfacing with an
Analog Devices AD5220 series digital potentiometer.


PROGRAMMING THE POTENTIOMETER DIVIDER

Voltage Output Operation

The digital potentiometer easily generates an output voltage
proportional to the input voltage applied to a given terminal.
For example connecting A Terminal to +5V and B Terminal to
ground produces an output voltage at the wiper W which can be
any value starting at zero volts up to 1 LSB less than +5V. Each
LSB of voltage is equal to the voltage applied across terminals
AB divided by the 128-position resolution of the potentiometer
divider. The general equation defining the output voltage with
respect to ground for any given input voltage applied to terminals
AB is:

VW(D) = D/128 × VAB + VB

D represents the current contents of the internal UP/DOWN
counter.

Operation of the digital potentiometer in the divider mode results
in more accurate operation over temperature. Here the output voltage
is dependent on the ratio of the internal resistors, not the absolute
value, therefore, the drift improves to 20 ppm/°C.

Pinout diagram:

    ┌───────┐
CLK ┤ • A   ├ VDD
  _ │   D   │ __
U/D ┤   5   ├ CS
    │   2   │
A   ┤   2   ├ B 
    │   0   │
GND ┤       ├ W 
    └───────┘

ESD protection (internal to device)

digital    analog
inputs    pins A/B/W
  1kΩ       20Ω
──┬   ──┬
 ┌─┘     ┌─┘
 zener    

Revision History:

  initial version 1/5/2014
}}

CON
  _clkmode = xtal1 + pll16x                  ' System clock → 80 MHz
  _xinfreq = 5_000_000                       ' external crystal 5MHz
   
VAR
  byte  clk
  byte  ud                            
  byte  cs
  word  state
   
OBJ
  

PUB Init(CLKpin,UDpin,CSpin)
{{
    Initializes the device output pins and internal state
     
    parameters:
      CLKpin                    wiper change one increment per clock pulse
      UDpin                     wiper up (high) down(low) select
      CSpin                     chip select, active low

}}
  dira[clk:=CLKpin]~~           ' output
  dira[ud:=UDpin]~~             ' output
  dira[cs:=CSpin]~~             ' output
  outa[CLKpin]~                 ' low is off
  outa[UDpin]~                  ' low is off
  outa[CSpin]~~                 ' high is off
  state := 64                   ' initial wiper setting by default

PUB Zero
{{
    Resets device wiper and state variable values to zero
}}
  state:=0
  repeat 128
    Wiper(-1)

PUB Wiper(up)
{{
    Increment, derement or simply read the wiper state variable.
    
    Wiper initial value is $40 (64) centered

    parameters:
      up                        -1:0:+1 increment value, zero only returns state
      
    returns:
      current state in range zero to 128

}}
  if not up
    return state
  outa[ud] := up>0
  outa[cs]~ ' active low
  waitcnt(clkfreq/1_000+cnt) 
  outa[clk]~~'
  waitcnt(clkfreq/1_000+cnt) 
  outa[clk]~'
  outa[cs]~~ ' deactivate
  outa[ud]~ ' ground
  if up>0
    state++
  else
    state--
  state <#= 128
  state #>= 0
  return state

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