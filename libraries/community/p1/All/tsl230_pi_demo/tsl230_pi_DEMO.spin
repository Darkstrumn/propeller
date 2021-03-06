{{ 
┌─────────────────────────────────────┬────────────────┬─────────────────────┬───────────────┐
│ TSL230_pi Light2Freq DEMO           │  BR            │ (C)2007,2008        │  31 Dec 2008  │
├─────────────────────────────────────┴────────────────┴─────────────────────┴───────────────┤
│ Demo of TAOS TSL230 light to frequency sensor driver with manual and auto scaling          │
│ capabilities.  This driver uses the PULSE INTEGRATION method to estimate light intensity.  │
│ I.e. pulse outputs from TSL230 are acumulated for a fixed (user-specified) period of       │
│ time.   Yields a high accuracy estimate of average light intensity over the integration    │
│ period.  This demo and driver object are based on the original object by Paul Baker, with  │
│ various modifications.  Among these modifications, a moving average filter has been added  │
│ to the assembly routine to smooth the measured output.                                     │
│                                                                                            │
│ This demo is set up to work with PLQ-DAQ, but also works fine with Parallax Serial Terminal│
│                                                                                            │
│ See end of file for terms of use.                                                          │
└────────────────────────────────────────────────────────────────────────────────────────────┘
}}
CON 
  _clkmode = xtal1 + pll16x       
  _XinFREQ = 5_000_000
'hardware constants
  inpin          = 2
  ctrlpinbase    = 0          
'software constants
  samplefreq     = 40
  autoscale      = true

  
OBJ
  debug: "SerialMirror"        'Same as fullDuplexSerial, but can also call in subroutines
  lfs  : "tsl230_pi"

PUB Go|_scale,_raw,_sample
  waitcnt(clkfreq * 5 + cnt)                          'Start FullDuplexSerial
  Debug.start(31, 30, 0, 57600)
  Debug.Str(String("MSG,Initializing...",13))
  Debug.Str(String("LABEL,time,scale,raw,sample",13))
  Debug.Str(String("CLEARDATA",13))
  
  lfs.Start(inpin,ctrlpinbase,samplefreq,autoscale)   'start l2f driver object
  lfs.setSampleFreq(240)                              'set update rate to 240 samples/sec
  waitcnt(clkfreq / 10 + cnt)                         'give ASM routine time to start & stabilize

  repeat
    _scale := lfs.getScale
    _raw := lfs.getRawSample
    _sample := lfs.getSample
    Debug.Str(String("DATA, TIME,"))
    Debug.dec(_scale)
    Debug.Str(String(",  "))
    Debug.dec(_raw)
    Debug.Str(String(",  "))
    Debug.dec(_sample)
    Debug.Str(String(13))
    waitcnt(clkfreq / 10 + cnt)


DAT

{{

┌────────────────────────────────────────────────────────────────────────────────────────────┐
│                                     TERMS OF USE: MIT License                              │                                                            
├────────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this        │
│software and associated documentation files (the "Software"), to deal in the Software       │
│without restriction, including without limitation the rights to use, copy, modify, merge,   │
│publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons  │
│to whom the Software is furnished to do so, subject to the following conditions:            │
│                                                                                            │                         
│The above copyright notice and this permission notice shall be included in all copies or    │
│substantial portions of the Software.                                                       │
│                                                                                            │                         
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,         │
│INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR    │
│PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE   │
│FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR        │
│OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER      │                                │
│DEALINGS IN THE SOFTWARE.                                                                   │
└────────────────────────────────────────────────────────────────────────────────────────────┘
}}