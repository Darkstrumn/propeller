{{
*****************************************
* RCTIME v1                             *
* Author: Beau Schwabe                  *
* Copyright (c) 2007 Parallax           *
* See end of file for terms of use.     *
*****************************************

Version 2 by Kees Stolker
- Added usage documentation to this .spin file copied from samples supplied by Beau schwabe
- Have start return the cog assigned (as per the original documentation)
- changed the test for unavailble cog (in start method) to allow starting cog 0
- removed need for cogon variable
  This breaking compatibility, although in a minor way: "if !start()" breaks. "if not start()" works.
- return the un-scaled time from RCTIME method. It makes calculating the actual time easier.
- Turned RCTemp from var to local and renamed to ClockcCycles
- Removed the VAR 'Mode" and used cogon instead
- improved documentation
- simplified Delay1ms
- introduced the PRI drive method to allow use of RCTIME in background and foreground mode simultaneously.   
- added the method getRCvalue() to get a measurement result in Ohm (or Farad) regardless of the clock frequency
  The innovation I wanted to implement, driving gall other changes...
- startRC, stopRC and driveRC support background mode for getRCvalue
- few other coding, naming and style changes (just for the fun of it...) and to help me fully understand the original RCTIME code



Usage: (copied from the RCTIME demos by Beau Schwabe)
  
  
  State = 0 (Preferred)
  
           220Ω  C
  I/O Pin ──┳── GND
               │
             ┌R
             │ │
             └─┻─── GND
  
  
  State = 1 
  
           220Ω  C
  I/O Pin ──┳── GND
               │
             ┌R
             │ │
             └─┻─── +3.3V


Theory of operation: (By Kees Stolker, using the sources mentioned)

    (see http://www.allaboutcircuits.com/vol_1/chpt_16/4.html)

The formula to calculate an arbitrary % discharge =

    %Change = 1 - 1/exp(t/rc) x 100%

The RC time constant = the time it takes for a capicitor to uncharge to ~ 63.212% of its initial charge:
    RC in Seconds = R in ohm x Capacitance in Farad

An easier to work with alternative formula (totally equivalent, although not used in this object):
    RC in ms = R in KΩ x C in µf

Symbol for RC = Tau, which is not in the character set, so I substitute rc <=> R*C 

In this application, the %Change is 50%. Halfway from VDD to VSS the logic 'flips' and
the input pin changes from 1 to 0 (mode 0) or from 0 to 1 (mode 1).

Since we know %Chhange (50%) and measure t, we can find rc. Knowing either R or C, gives us the other

    50% = 1 - 1/exp(t/rc) x 100%
 => .5 -1 = - 1/exp(t/rc)
 => -.5 = - 1/exp(t/rc)
 => .5 = 1/exp(t/rc)
 => 2 = exp(t/rc)
 => ln(2) = t/rc
 => rc = t / ln(2)

 => r = t / ln(2) / c = t / (ln(2) * c)
 => c = t / ln(2) / r = t / (ln(2) * r)


Please take care with the final value due to the following sources of inaccuarcy:
- The clock used
- The tolerance of resistor and capacitor used
- The tolerance of the Propeller while interpreting logic 1 or 0 on the input pin
- The inherent (lack of) accuracy in floating point math
- etc. etc.

TIP: If you don't have a tool to actually measure the (fixed) capicitor you want to use, you can use a fixed
resistor in the RC circuit, measure it exactly with your multi-meter and use this object to find the exact
value for the capacitor.


}}

CON
  Ln2 = 0.69314718055995                                ' the value of ln(2)


VAR

   long cog, Stack[30]                             ' the cog and stack for RCTIME background mode

PUB start(Pin,State,ClockCycleStore)
{{
starts a cog to continuuously store scaled measurements in a variable 

All parameters are passed without change to RCTIME
Pin: Pin to measure
State: See theory of operation ... type of RC circuiut used
ClockCycleStore: Address of memory location to store ( ClockCycles / 16 )  

returns false if no cog available
}}    

  stop

  return cog := cognew(drive(Pin,State,ClockCycleStore),@Stack) + 1  'so 0 (false) if no cog 

PUB stop
{{
Stop RCTIME - frees a cog
}}
  if cog > 0
    cogstop(cog - 1)
    cog := 0

PRI drive(Pin,State,ClockCycleStore)
    ' this implementation does not break compatibility of previous RCTIME version
    repeat
       RCTIME(Pin,State,ClockCycleStore)

CON ' Here the actual functionality

PUB RCTIME(Pin,State,ClockCycleStore) : ClockCycles
{{
Measure (dis)charge time in clockcycles of the capacitor in the RC circuit

Pin: Pin to measure
State: See theory of operation ... type of RC circuiut used
ClockCycleStore: Address of memory location to store scaled result ( ClockCycles / 16 )

return ClockCycles: Number of clockcycles to Charge or Discharge the capacitor through the resistor in the RC circuit  
}}    
    outa[Pin] := State                         'make I/O an output in the State you wish to measure... and then charge cap
    dira[Pin] := 1                               
    Pause1ms(1)                                'pause for 1mS to charge cap
    dira[Pin] := 0                             'make I/O an input
    ClockCycles := cnt                         'grab clock tick counter value
    WAITPEQ(1-State,|< Pin,0)                  'wait until pin goes into the opposite state you wish to measure; State: 1=discharge 0=charge
    ClockCycles := cnt - ClockCycles - 1600    'see how many clock cycles passed until desired State changed
    ClockCycles #>= 0                          'no less than 0
    long [ClockCycleStore] := ClockCycles >> 4 'Write ClockCycles with scaled result (divide by 16) <<-number of clock cycles per itteration loop
     
    ' You will only get here if running in forground mode (not in separate cog)
    return ClockCycles                         'Return unscaled full accuracy result 

CON 'helper utility. 

PUB Pause1ms(Period) 
{{Pause execution for Period (in units of 1 ms).}}

  ' We intend to wait relatively long, so we can violate the 'waitcnt pause + cnt' convention to increase accuracy
  waitcnt (cnt + ((clkfreq / 1000 * Period) #> 1000))    'Wait for designated ms units, but (just in case the clock frequency is VERY low), at least 1000 clks              

CON ' Comment out everything below to avoid loading FloatMath (if you really need the memeory)

OBJ
  fm    : "FloatMath"
  
VAR
   long cogRC, RCStack[60]                         ' the cog stack for getRCvalue, larger, due to the use of FloatMatch

PUB startRC(TheOneYouKnow,Pin,State,RCValueStore)
{{
starts a cog to continuuously store resistance (or capacitance) in a variable 

All parameters are passed without change to getRCvalue

If successful, returns the ID of the newly started cog. If there were no more cogs
available, returns -1.
}}    
  stopRC
  return cogRC := cognew(driveRC(TheOneYouKnow,Pin,State,RCValueStore),@RCStack) + 1

PUB stopRC
{{
Stop RCTIME - frees a cog
}}
  if cogRC > 0
    cogstop(cogRC - 1)
    cogRC := 0

PRI driveRC(TheOneYouKnow,Pin,State,RCValueStore)
    ' This implementation functionaly separates foreground and background mode 
    repeat
       long [RCValueStore] := getRCvalue(TheOneYouKnow,Pin,State,1)       

CON ' Here the actual functionality

PUB getRCvalue(TheOneYouKnow,Pin,State,Sample) : TheOneYouDont | t, ClockCycles
{{
Calls RCTIME and calculates the value of the resistor (or capacitor), given the valuue of the capacitor (or resistor) 

TheOneYouKnow: Float. The 'known' value, most of the time the value of the capacitor (in Farad) 
Pin: Pin to measure
State: See theory of operation ... type of RC circuiut used
Sample: The number of measurement samples to take. The mean is returned. Anything <=1 will take 1 measurement.

return TheOneYouDont: Float. The 'measure' value, most of the time the value of the resistor (in Ohm) 

Note: Since each measurement takes at least 1 mS to charge the capacitor, there is hardly any incentive to use assembly.
}}  

    t := 0.0                                     ' initialize to floating point zero

    repeat (Sample #>= 1)     ' Everything =< 1 results in a single shot measuurement
       t := fm.fadd(t,fm.fFloat(RCTIME(Pin,State,@ClockCycles)))        ' add the measurement to t, later used to calculate a mean

    ' t := t / Sample / clkfreq  => the average measurement time in seconds 
    t := fm.fdiv(fm.fdiv(t,fm.ffloat(Sample)),fm.ffloat(clkfreq))

    
    ' r = t / (ln(2) * c) <=> c = t / (ln(2) * r)   { See theory of operation }
    ' return t / (ln(2) * TheOneYouKnow)
    return fm.fdiv(t,fm.fmul(ln2,TheOneYouKnow))
'} 
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
b}}    