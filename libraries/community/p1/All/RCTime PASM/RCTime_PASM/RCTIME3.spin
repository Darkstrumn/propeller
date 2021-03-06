''***************************************
''*  PASM RCTIME v1.0                   *
''*  Author: Brandon Nimon              *
''*  Created: September 4, 2009         *
''*  Copyright (c) 2009 Parallax, Inc.  *
''*  See end of file for terms of use.  *
''******************************************************************
''* This isn't too unlike other common RC Time objects, but it has *
''* some very useful elements that other objects may not have.     *
''* First, and most significantly, it uses PASM which allows for   *
''* much more accurate timing, and uses less power than the SPIN   *
''* variety.                                                       *
''* Another feature is the *_forever mode; this allows the         *
''* controlling cog to receive continuous input of RC times.       *
''* Another unique feature which allows for more accurate RC times *
''* when other environmental variables may be affected: after the  *
''* single RC time test, the pin is set in the opposite direction  *
''* of the test. This stops current flow through the testing       *
''* circuit. This is important in some testing (thermistors, for   *
''* example) where continued current flow will alter the           *
''* resistance value due to generated heat. When running in        *
''* *_forever mode, softstop can be used to allow one last RC Time *
''* value, before terminating. Finally, the standard single RCTIME *
''* has a built-in watchdog timer so the cog won't halt completely *
''* if a problem with the RC circuit occurs.                       *
''******************************************************************
''
CON

OBJ

VAR
                        
   BYTE cogon, cog
   BYTE foreverm                                     ' forever mode value

PUB RCTIME (pin, waitus, pinstate, watchdogms) : rtime | waitstart, waitlen
'' Start RCTIME cog                  
' waitus is the number of microseconds to wait at pinstate before starting test.
' It is also the amount of time to wait at the opposite of pinstate after the test.
' pinstate 1 will set the pin high, and wait for it to go low, and visa versa.
' rcAddr is an address of a long where the results should be written.
' If mode is set to 0, RCTime will only run once, if set to any other, it will run
' until the cog is stopped.
' A watchdog should be used to check for messuring problems.

  stop

  apin := pin
  wait := (clkfreq / 1_000_000 * waitus) #> 9
  state := pinstate
  foreverm := 0
  modeAddr := @foreverm
  cogonAddr := @cogon

  waitlen := clkfreq / 1000 * watchdogms

  rtime~
  cogon := (cog := cognew(@entry, @rtime)) > 0
  waitstart := cnt                      
  IF (cogon)
    REPEAT UNTIL (rtime <> 0 OR (cnt - waitstart) => waitlen)
    IF (rtime == 0)
      stop
      RETURN false                 
    RETURN rtime
  RETURN false

PUB RCTIME_forever (pin, waitus, pinstate, rcAddr)
'' Start RCTIME cog                  
' waitus is the number of microseconds to wait at pinstate before starting test.
' It is also the amount of time to wait at the opposite of pinstate after the test.
' pinstate 1 will set the pin high, and wait for it to go low, and visa versa.
' rcAddr is an address of a long where the results should be written.
' If mode is set to 0, RCTime will only run once, if set to any other, it will run
' until the cog is stopped.
' A watchdog should be used to check for messuring problems.

  stop

  apin := pin
  wait := (clkfreq / 1_000_000 * waitus) #> 9
  state := pinstate
  foreverm := 1
  modeAddr := @foreverm
  cogonAddr := @cogon

  cogon := (cog := cognew(@entry, rcAddr)) > 0

PUB stop
'' Stop RCTIME cog
              
  IF (cogon~)
    cogstop(cog) 


PUB softstop
'' Stops RCTIME cog after it returns RC Time value it is currently messuring
' Note: if pin never acchieves opposite state, the cog may never terminate
' when using this method. A watchdog should be used.

  foreverm := 0


DAT

                        ORG 0
'----- Checks RCTIME for a pin ------------------------
' returns 1 or greater as a value in the supplied address
entry
                        MOV     pinmask, #1             ' enable pin
                        SHL     pinmask, apin           ' shift to applicable position
                        MOV     statemask, state        ' create long mask
                        SHL     statemask, apin         ' shift to applicable pin

                        MOV     opstate, #1
                        SUB     opstate, state          ' get oposite state for waitpeq
                        ABS     opstate, opstate
                        SHL     opstate, apin           ' shift to applicable pin
                        
                        MOV     OUTA, statemask         ' set output state before enabling output
loop                    
                        MOV     DIRA, pinmask           ' enable output
                        MOV     time, cnt               ' get time
                        ADD     time, wait          
                        WAITCNT time, #0                ' wait for predetermined time

                        MOV     starttime, cnt          ' start count
                        MOV     DIRA, #0                ' set as input
                        WAITPEQ opstate, pinmask        ' wait for pin to flop states
                        MOV     endtime, cnt            ' end count
                        
                        RDBYTE  forever, modeAddr WZ    ' check forever (this allows for a "soft off")
                        SUB     endtime, starttime      ' calculate difference
                        SUB     endtime, #13            ' adjust for execution time, so minimum result is 1               
                        WRLONG  endtime, PAR            ' write to suplied address
                        
              IF_NZ     JMP     #loop                   ' loop if forever is enabled
                        XOR     OUTA, statemask         ' set in opposite output state (this is useful for tests where continued current through the pin map alter results as in temperature messurments)
                        MOV     DIRA, pinmask           ' set to output to accieve opposite state
                        MOV     time, cnt               ' get time
                        ADD     time, wait
                        WAITCNT time, wait              ' wait for a period in opposite output state
                        MOV     DIRA, #0                ' set to input

                        MOV     p, #0
                        WRBYTE  p, cogonAddr  
                        COGID   p                       ' get cog id
                        COGSTOP p                       ' kill this cog

                        
apin                    LONG    0                       ' pin to set and wait
statemask               LONG    0                       ' mask for state (may be different than pinmask)
wait                    LONG    0                       ' clock cycles to wait for high and low (set in SPIN)
state                   LONG    0                       ' set to this state and wait for opposite
modeAddr                LONG    0                       ' address of byte to enable run rctime for forever or not (set in SPIN)
cogonAddr               LONG    0                       ' cogon address to set if cog stops

pinmask                 RES                             ' mask for pin
forever                 RES                             ' enable run rctime for forever or not
starttime               RES                             ' start timer
endtime                 RES                             ' end timer
p                       RES
opstate                 RES                             ' stores opposite value of state
time                    RES                             ' used for pauses

                        FIT 496                            

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