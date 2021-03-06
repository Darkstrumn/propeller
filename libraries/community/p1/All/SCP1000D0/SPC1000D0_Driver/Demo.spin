''=============================================================================
''
'' @file     Demo
'' @target   Propeller
''
'' Demo of SCP1000D0.spin
''
''   ───EnvLog
''        ├──SCP1000D0
''        ├──FullDuplex     (Proplib ver 1.2)
''        ├──FloatString    (Proplib ver 1.2)
''        └──FloatMath      (Proplib ver 1.2)
''
'' @author   B Mathias Johansson 
''
'' Copyright (c) 2009
'' See end of file for terms of use.
''
'' @version  V0.1 - Jan 26, 2009
''
''=============================================================================
CON
  _clkmode = xtal1 + pll16x
  _xinfreq = 5_000_000

  'Serial
  SerialComBaud = 19200
  CR = 13
  LF = 10

  'SCP1000D0
  SCP_DRDY      =2                                       ' SHT DRDY pin
  SCP_CSB       =3                                       ' SHT CSB  pin
  SCP_MISO      =4                                       ' SHT MISO pin
  SCP_MOSI      =5                                       ' SHT MISI pin
  SCP_SCK       =6                                       ' SHT SCK pin
OBJ
  SerialCom     : "FullDuplexSerial"                                                         'Cogs 1
  SCP           : "SCP1000D0"                                                                'Cogs 0
  FloatString   : "FloatString"                                                              'Cogs 0
  FloatMath     : "FloatMath"                                                                'Cogs 0
                                                                                 'This object Cogs 1
                                                                                       'Cogs used: 2
                                                                                                                                                                          
PUB main 
  Init
  repeat
    if SerialCom.rxcheck > -1
      GetPresure
      
PRI Init
  'Serial
  SerialCom.start(31,30,0,SerialComBaud)
  'Math
  'FloatMath.start                                  ' start floating point object
  'SCP1000D0
  SCP.start(SCP_DRDY, SCP_CSB, SCP_MISO, SCP_MOSI, SCP_SCK) ' start SCP object 
  
PRI GetPresure | presure
    
    SerialCom.str(string("<Ver>"))
    SerialCom.bin(SCP.getChipVersion,8)
    SerialCom.str(string("</Ver>"))
    SerialCom.str(string("<OPS>"))
    SerialCom.bin(SCP.getOPStatus,8)
    SerialCom.str(string("</OPS>"))
    SerialCom.str(string("<ASIC>"))
    SerialCom.bin(SCP.getASICStatus,8) 
    SerialCom.str(string("</ASIC>"))
    SerialCom.str(string("<DRDY>"))
    SerialCom.bin(SCP.getDRDY,1) 
    SerialCom.str(string("</DRDY>"))
    SerialCom.str(string("<PresureInBin>"))
    presure:=SCP.getSample
    SerialCom.bin(presure,32)
    SerialCom.str(string("</PresureInBin>"))
 
    SerialCom.str(string("<PresureInPa>"))
    presure:= FloatMath.FFloat(presure)
    presure:= FloatMath.FMul(presure,0.25)
    'SerialCom.str(FloatString.FloatToFormat(presure, 15, 2))
    SerialCom.str(FloatString.FloatToString(presure))
    SerialCom.str(string("</PresureInPa>"))
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