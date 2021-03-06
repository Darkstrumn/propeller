{{

┌──────────────────────────────────────────┐
│ Wii Nunchuck Driver Object v1.0          │
│ Author: Pat Daderko (DogP)               │               
│ Copyright (c) 2009                       │               
│ See end of file for terms of use.        │                
└──────────────────────────────────────────┘

Based on a Wii nunchuck example project from John Abshier, which was based on code originally by João Geada

This code uses the Floating Point library for computing pitch and roll.  If this data isn't needed, you can
save 2 cogs by removing this functionality.  You can probably also combine only the needed floating point
functionality into a single cog.

Note there is no yaw, as that can't be determined from the accelerometers.  This also limits the pitch
to 180 degrees and will cause incorrect roll readings when the pitch is between 180 deg and 360 deg.

Also note that the Nunchuck can't be constantly read, or bad data will be returned.  A wait can be added
at the end of the read function if you'd like to ensure it doesn't read too often, but that's probably
better left to the end user to prevent processing time from being unnecessarily wasted.

The CAL_X, CAL_Y, and CAL_Z values are calibration values for zeroing the acceleration and may need to be
adjusted, depending on your specific hardware.  This is the 0 value for no acceleration in its axis, not
the value being held still (when held still, zeroing two values should give a third value around 200 from
the force of gravity).  Find your center position, zero the two axes perpendicular to the force of gravity,
then rotate the third axis perpendicular to gravity and zero that axis.

The CAL_JOY_X and CAL_JOY_Y are the center values of the joystick.  128 seems like the nominal value, but
varies depending on the nunchuck.     

Diagram below is showing the pinout looking into the connector (which plugs into the Wii Remote)
 _______ 
| 1 2 3 |
|       |
| 6 5 4 |
|_-----_|

1 - SDA 
2 - 
3 - VCC
4 - SCL 
5 - 
6 - GND

This is an I2C peripheral, and requires a pullup resistor on the SDA line
If using a prop board with an I2C EEPROM, this can be connected directly to pin 28 (SCL) and pin 29 (SDA)
}}

CON
   Nunchuck_Addr = $A4
   CAL_X     = 515
   CAL_Y     = 490
   CAL_Z     = 525
   CAL_JOY_X = 128
   CAL_JOY_Y = 128

OBJ
   i2cObject      : "i2cObject"
   fMath : "Float32Full"

VAR
   long joy_x
   long joy_y
   long accel_x
   long accel_y
   long accel_z
   byte button_c
   byte button_z                                                                                
   long _220uS
   byte i2cSCL, i2cSDA
  
PUB init(_scl, _sda)
   i2cSCL := _scl
   i2cSDA := _sda
   i2cObject.Init(i2cSDA, i2cSCL, false)
   fMath.start
   _220uS := clkfreq / 100_000 * 22 
  
PUB readNunchuck | data[6]
   ''reads all nunchuck data into memory
   i2cObject.writeLocation(Nunchuck_Addr, $F0, $55, 8, 8)
   waitcnt(_220uS+cnt)
   i2cObject.writeLocation(Nunchuck_Addr, $FB, $00, 8, 8)
   waitcnt(_220uS+cnt)
   i2cObject.i2cStart
   i2cObject.i2cWrite(Nunchuck_Addr, 8)
   i2cObject.i2cWrite(0,8)
   i2cObject.i2cStop
   waitcnt(_220uS+cnt)
   i2cObject.i2cStart
   i2cObject.i2cWrite(Nunchuck_Addr|1, 8)
   data[0] := i2cObject.i2cRead(0)
   data[1] := i2cObject.i2cRead(0) 
   data[2] := i2cObject.i2cRead(0) 
   data[3] := i2cObject.i2cRead(0) 
   data[4] := i2cObject.i2cRead(0) 
   data[5] := i2cObject.i2cRead(1)
   i2cObject.i2cStop
   joy_x := data[0]-CAL_JOY_X
   joy_y := data[1]-CAL_JOY_Y
   accel_x := ((data[2]<<2)|((data[5]>>2)&3))-CAL_X
   accel_y := ((data[3]<<2)|((data[5]>>4)&3))-CAL_Y
   accel_z := ((data[4]<<2)|((data[5]>>6)&3))-CAL_Z
   button_z := (data[5]&1)^1
   button_c := ((data[5]>>1)&1)^1

PUB joyX
   ''returns joystick x axis data
   return joy_x

PUB joyY
   ''returns joystick y axis data
   return joy_y

PUB accelX
   ''returns x axis accelerometer data
   return accel_x

PUB accelY
   ''returns y axis accelerometer data
   return accel_y

PUB accelZ
   ''returns z axis accelerometer data
   return accel_z

PUB radius
   ''radius, used for determining pitch
   return ^^(accel_x*accel_x + accel_y*accel_y + accel_z*accel_z) 

PUB pitch | rad
   ''computes pitch
   ''only 180 degrees of pitch (+/- 90) available from y data, since there's no yaw data
   rad := radius
   if rad>0 'radius of 0 during freefall will cause div by 0, so prevent this 
      return fMath.FRound(fMath.Degrees(fMath.ACos(fMath.FDiv(fMath.FFloat(accel_y),fMath.FFloat(radius)))))-90
   else 'return 0 degrees since accel_y=0 (radius=0 means all accelerations were 0) typically corresponds to 0 degrees pitch (no better guess) 
      return 0 

PUB roll
   ''computes roll
   ''full 360 degrees of roll (+/- 180) available from x and z data
   return fMath.FRound(fMath.Degrees(fMath.ATan2(fMath.FFloat(accel_x),fMath.FFloat(accel_z))))

PUB buttonC
   ''returns button C pressed or not
   return button_c

PUB buttonZ
   ''returns button Z pressed or not
   return button_z

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
