{{
  Schematic:
                ┌─────────┐
                │  Master │
      clockOut  │         │slaveRESn
         ┌──────┤  Prop   ├──────┳──┐
         │      └─────────┘      │  │
         │                       │  │
         │      ┌─────────┐      │  │
         │      │  Slave  │      │  │
         │  XI  │         │ RESn │  │
         ┣──────┤  Prop   ├──────┫  │
         │      └─────────┘1MegΩ   │
         │                         │
         │      ┌─────────┐         │
         │      │  Slave  │         │
         │  XI  │         │ RESn    │
         └──────┤  Prop   ├─────────┫ 
                └─────────┘   1MegΩ 
                                    
                  
}}

{{Snippet 1}}
{Master Prop (5Mhz crystal)}

CON
  _clkmode      = XTAL1 + PLL16x                        ' System clock → 80 MHz 12.5nS
  _xinfreq      = 5_000_000                             ' external crystal 5MHz

PRI GenerateClock(clockOutPin,slaveRESnOutPin)
  
  outa[clockOutPin]~                                    ' low initially
  dira[clockOutPin]~~                                   ' output

  PHSA~                                                 ' clear phase A accumulator
  FRQA := $8000_0000 >> 3 ' 5Mhz
  CTRA := %00100<<26 | clockOutPin                      ' put counter A into numerically controlled oscillator (NCO) mode

  {since the clock is now available, allow the slave(s) to begin running}
  outa[slaveRESnOutPin]~~                               ' high
  dira[slaveRESnOutPin]~~                               ' output

{{Snippet 2}}
{Slave Prop (no crystal)}
CON
  _clkmode      = XINPUT + PLL16x
  _xinfreq      = 5_000_000                             ' external signal on XI pin at 5MHz


{{Snippet 3}}
{Master Prop Clock Timing Test}
CON
  _clkmode = xtal1 + pll16x                  ' System clock → 80 MHz
  _xinfreq = 5_000_000                       ' external crystal 5MHz

OBJ
  UI:"Parallax Serial Terminal"

PUB Main
  ClockTest(27)
  repeat ' forever
    waitcnt(clkfreq+cnt)

PRI ClockTest(clockOutPin) | t, n
  UI.Start(115_200)
  UI.Home
  UI.Clear 
  outa[clockOutPin]~  ' 
  dira[clockOutPin]~~ '  
  PHSA~
  FRQA := $8000_0000 >> 3 '3=5Mhz ' 10=39.05kHz
  CTRA := %00100<<26 | clockOutPin
  '
  ' measures out to  ~5.086Mhz
  '
  ' derivation:
  '
  '         edges      
  '         ───── * clkfreq = signal frequency (Hz)
  '         ticks   
           
  repeat 100
    PHSB~
    FRQB := 1
    t := -cnt
    CTRB := %01010<<26 | clockOutPin    ' pos edge detector on P26 clone of MCU_CLOCK_OUT
    waitcnt(clkfreq>>12+cnt) ' 1/4096 : 244.140625µS
    t += cnt - 544 ' overhead according to AN009
    CTRB~
    ' edges PHSB, ticks t ticks per edge
    UI.Str(string("ticks: "))
    UI.Dec(t)
    UI.Str(string(" edges: "))
    UI.Dec(PHSB)
    UI.Str(string(" ticks/edges [ticks per edge]: "))
    UI.Dec(t/PHSB)
    UI.Char(".")
    UI.Dec(t*100/PHSB - t/PHSB*100)
    UI.Newline
  CTRA~     
