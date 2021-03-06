{{

┌──────────────────────────────────────────┐
│ Ping_Pasm                                │
│ Author: Wm Dygon  (pogertt@wi.rr.com)    │               
│ Copyright (c) 2011 Wm Dygon              │ 
│                                          │ 
│ See end of file for terms of use.        │                
└──────────────────────────────────────────┘

Edit "Ping_Pin" to pin you have your Ping)) sensor wired to.
Remember pins are numbered 0 to 31.

This program launches a new cog, and has it:

Trigger a Ping)) sensor on your choice of pins.
Wait for several microseconds, then start to watch the return echo pulse.
After approximately 19 milliseconds it sends the echo width measurement to the spin program.
There is then a short delay B4 the cycle repeats.

This assembly routine runs about 39 times a second.
The overhead is almost always the same, so you can expect a constant stream of data at consistent
intervals.
The only variation is when the wrlong gets to write to main ram that there may be a difference of 
7 to 22 clock cycles.







}}

CON
       _clkmode = xtal1 + pll16x
       _xinfreq = 5_000_000

       TO_CM = 29_034
       
VAR

       long     Ram
       long     Distance
       long     Microseconds


OBJ

       PST   : "Parallax Serial Terminal"  
PUB    start 

       cognew(@entry, @Ram)
       if PST.start(115200)
 
       repeat        
          Microseconds := (||(Ram) /(clkfreq / 1_000_000)) >> 1  ' Travel Time
          Distance := Microseconds * 10_000 / TO_CM              ' Scaling
          PST.Home
          PST.Str(@Prompt)
          PST.ClearEnd    
          PST.Dec(Distance)
          waitcnt(clkfreq / 100 + cnt)


DAT


                    org      0
                        
entry               mov      main_ram, par                ' Load pointer to main ram
                    mov      Active_Pin, Ping_Pin_Mask
                    shl      Active_Pin, Ping_Pin
                    mov      Echo_Timer, Echo_Timer_Mask
                    add      Echo_Timer, Ping_Pin
                    mov      frqa,  # 1                   ' Make ctra count 1  per each clock

:loop                 
                    muxc     dira, Active_Pin               ' Make Ping_Pin into an OUTPUT
                    muxc     outa, Active_Pin               ' Turn Ping_Pin ON
                           
                    mov      Scratch_Pad, cnt             ' Get Current cnt Value
                    add      Scratch_Pad, Trigger_Pulse   ' Add Trigger Pulse Width to Scratch_Pad
                          
:Trigger_Delay      cmp      Scratch_Pad, cnt   wc        ' Compare Current counter with Trigger Width
         if_nc      jmp      #:Trigger_Delay              ' Wait for Trigger pulse to time out
                    muxnc    dira, Active_Pin             ' Turn Ping_Pin into an INPUT                      

                    mov      ctra, Echo_Timer             'Start ctra as Logic A counter.
                                                          'with Ping_Pin as APIN
                    mov      Scratch_Pad, cnt 
                    add      Scratch_Pad, Echo_Range      'Loads 19 millisecond delay
:Echo_Delay         cmp      Scratch_Pad, cnt  wc
      if_nc         jmp      #:Echo_Delay

                    mov      Echo_Pulse_Width, phsa       'Read the counter phsa value.
                    mov      ctra, #0
                    mov      phsa, #0
                          
                    wrlong   Echo_Pulse_Width, main_ram   'Write the measurment to Main Ram
                          
                    mov      Scratch_Pad, cnt              
                    add      Scratch_Pad, Delay_B4_Next_Read
:Next_Read_Delay    cmp      Scratch_Pad, cnt  wc
           if_nc    jmp      #:Next_Read_Delay
 
                    jmp      #:loop                         ' Repeat endlessly
                            
                    fit      496
                    
Ping_Pin            byte     6
Ping_Pin_Mask       long     %0000_0000_0000_0000_0000_0000_0000_0001   
Trigger_Pulse       long     160            '5 uSecond Delay   
Echo_Range          long     2_000_000      '19.5 mSecond Delay 
Delay_B4_Next_Read  long     20_000         '250 uSecond Delay  

'                            Timer Configuration Logic A
'                            %0_MODE_PLL_000000000_ BPIN _000_ APIN 
Echo_Timer_Mask     long     %0_1101_000_000000000_000000_000_000000     'cntra control register
             

                     
Scratch_Pad         res      1
Echo_Pulse_Width    res      1
Echo_Timer          res      1
Echo                res      1
main_ram            res      1
Active_Pin          res      1

Prompt              byte     "Millimeters = ",0








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