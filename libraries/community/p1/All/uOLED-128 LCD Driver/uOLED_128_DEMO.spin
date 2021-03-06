CON
  _CLKMODE      = XTAL1 + PLL16X                        
  _XINFREQ      = 5_000_000

OBJ
  LCD   : "uOLED_128"
  DELAY : "Clock"  

PUB Demo
  LCD.INIT

  LCD.CIRCLE (64,64,20, 0,255,0, 1)
  LCD.LINE (10,10,118,118, 255,255,0)

  LCD.RECTANGLE (50,50,70,70, 0,255,255, 0)

  LCD.PAINT (40,40, 60,60, 255,255,255)

  LCD.BUTTON (30,30,60,60, 255,0,255, 0)
              
  LCD.FONT_SIZE (0)

  LCD.TEXT (0,0, 255,255,255, 0, string("Hello World!"))

  DELAY.PauseSec(4)
                                                    
  LCD.FADE_OUT (200)
  
  LCD.SHUTDOWN
  
   