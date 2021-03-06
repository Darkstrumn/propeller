{{
┌───────────────────────────────────────────┐
│ RFID RFID Read/Write Object Wrapper       │
│ Author: TinkersALot                       │                     
│ Adapted from Joe Grand's BS2 code.        │                     
│ See end of file for terms of use.         │                      
└───────────────────────────────────────────┘
}}

CON

  _clkmode      = xtal1 + pll16x                        ' use crystal x 16
  _xinfreq      = 5_000_000

RFID_Read       =   $01  ' Read data from specified address, valid locations 1 to 33 (5)
RFID_Write      =   $02  ' Write data to specified address, valid locations 3 to 31 (1)
RFID_Login      =   $03  ' Login to tag with password (1)
RFID_SetPass    =   $04  ' Change tag's password from old to new (1)
RFID_Protect    =   $05  ' Enable/disable password protection (1)
RFID_Reset      =   $06  ' Reset tag (1)
RFID_ReadLegacy =   $0F  ' Read unique ID from EM4102 read-only tag (for backwards compatibility with Parallax RFID Card Reader, #28140 and #28340) (12)


' Memory map/address locations for EM4x50 tag
' Each address holds/returns a 32-bit (4 byte) value
ADDR_Password   =    0  ' Password (not readable)
ADDR_Protect    =    1  ' Protection Word
ADDR_Control    =    2  ' Control Word
' ADDR 3-31 are User EEPROM area
ADDR_Serial     =    32  ' Device Serial Number
ADDR_DeviceID   =    33  ' Device Identification

' Status/error return codes
ERR_OK          =    $01  ' No errors
ERR_LIW         =    $02  ' Did not find a listen window
ERR_NAK         =    $03  ' Received a NAK, could be invalid command
ERR_NAK_OLDPW   =    $04  ' Received a NAK sending old password (RFID_SetPass), could be incorrect password
ERR_NAK_NEWPW   =    $05  ' Received a NAK sending new password (RFID_SetPass)
ERR_LIW_NEWPW   =    $06  ' Did not find a listen window after setting new password (RFID_SetPass)
ERR_PARITY      =    $07  ' Parity error when reading data
                                                                                 
obj
 IO    : "FullDuplexSerial"


var

byte InternalBuffer[ 12 ] ' data buffer
byte CardDataBuffer[ 32 * 4 ]



Pub Start( RxPin, TxPin )
{{
  Public function that starts the IO (serial port) driver for this
}}
  Result := IO.start( RxPin, TxPin, 0, 9600 )



PUB TryGetCardSerialNumber( StringBuffer, TryCount )
{{
  Public function that makes repeated tries to read the serial number of a RFID card
}}
  Result := 0
  
  repeat while Result == 0 and TryCount > 0
    Result := ReadSerialNumber( @InternalBuffer, 4 )
    if Result <> 0
      if StringBuffer
        bytemove( StringBuffer, @InternalBuffer, 4 )
    else
      TryCount--
      PauseForSeconds( 1 )


   
PUB TryGetLegacyCardNumber( StringBuffer, TryCount ) | ErrCheck, LoopCounter
{{
  Public function that makes repeated tries to read the serial number of a legacy RFID card
}}
  Result := 0
  
  repeat while Result == 0 and TryCount > 0
    Result := ReadLegacyCard( 10 )
    if Result <> 0
      if StringBuffer
        bytemove( StringBuffer, @InternalBuffer, 10 )
    else
      TryCount--
      PauseForSeconds( 1 )



PUB TryCardLogin( PwdPtr, TryCount )
{{
  Public function that makes repeated tries to logon to the card using the password the RFID card
}}
  Result := 0

  repeat while Result == 0 and TryCount > 0
    Result := LoginToCard( PwdPtr )
    if Result == 0
      TryCount--
      PauseForSeconds( 1 )



PUB TryToReadCardData( StringBuffer, BaseAddress, CountToGet, TryCount )
{{
  Public function that makes repeated tries to read the data from the RFID card
}}
  Result := 0

  repeat while Result == 0 and TryCount > 0
    Result := ReadCardData( StringBuffer )
    if Result == 0 
      TryCount--
      PauseForSeconds( 1 )
    else
      bytemove( StringBuffer, @CardDataBuffer, CountToGet * 4 )  

  

PUB TryToWriteDataToCard( AtAddress, DataToWrite, TryCount )
{{
  Public function that makes repeated tries to write a word
  of data to the specified address on the RFID card
}}
  Result := 0

  repeat while Result == 0 and TryCount > 0
    Result := WriteCardData( AtAddress, DataToWrite )
    if Result == 0 
      TryCount--
      PauseForSeconds( 1 )



PUB TrySetCardPassword( OldPwd, NewPwd, TryCount )
{{
  Public function that makes repeated tries to change the password the RFID card
}}
  Result := 0

  repeat while Result == 0 and TryCount > 0
    Result := SetCardPassword( OldPwd, NewPwd )
    if Result == 0
      TryCount--     
      PauseForSeconds( 1 )


   
PUB TryCardReset( TryCount )
{{
  Public function that makes repeated tries to reset the RFID card
}}
  Result := 0

  repeat while Result == 0 and TryCount > 0
    Result := ResetTheCard
    if Result == 0
      TryCount--
      PauseForSeconds( 1 )



PUB TryCardUnlock( TryCount )
{{
  Public function that makes repeated tries to unlock the RFID card
}}
  Result := 0

  repeat while Result == 0 and TryCount > 0
    Result := UnlockTheCard
    if Result == 0
      TryCount--
      PauseForSeconds( 1 )



PUB TryCardLock( TryCount )
{{
  Public function that makes repeated tries to lock the RFID card
}}
  Result := 0

  repeat while Result == 0 and TryCount > 0
    Result := LockTheCard
    if Result == 0
      TryCount--
      PauseForSeconds( 1 )
    


PRI PauseForSeconds( period ) | clkcycles
{{
  Pause execution for period (in units of 1 sec).
}}
  clkcycles := ((clkfreq * period) - 4296) #> 381      ' Calculate 1 s time unit
  waitcnt(clkcycles + cnt)                             ' Wait for designated time



PRI ReadSerialNumber( OutBuffer, CountToGet ) | ErrCheck , LoopCounter
{{
  Driver function that reads the serial number of the RFID card
}}
  IO.str( string( "!RW", RFID_Read, ADDR_Serial ) )

  ErrCheck := IO.rx

  if ErrCheck <> ERR_OK
    Result := 0
  else
    repeat LoopCounter from 0 to CountToGet - 1
      InternalBuffer[ LoopCounter ] := IO.rx
    Result := CountToGet



PRI ReadLegacyCard( CountToGet ) | ErrCheck , LoopCounter
{{
  Driver function that reads the serial number of a legacy RFID card
}}
  IO.str( string( "!RW" , RFID_ReadLegacy ) )

  ErrCheck := IO.rx

  if ErrCheck == $0D or ErrCheck == $0A
    repeat LoopCounter from 0 to CountToGet - 1
      InternalBuffer[ LoopCounter ] := IO.rx
    Result := CountToGet
  else
    Result := 0



PRI LoginToCard( Pwd ) | ErrCheck, LoopCounter
{{
  Driver function that logs on to the RFID card
}}
  IO.str( string( "!RW", RFID_Login ) )

  repeat LoopCounter from 0 to 3
    IO.tx( byte[ Pwd + LoopCounter ] )

  ErrCheck := IO.rx

  if ErrCheck <> ERR_OK
    Result := 0
  else
    Result := 1  



PRI ReadCardData( OutBuffer ) | Offset, ErrCheck, OuterLoop, InnerLoop, OneByte
{{
  Driver function that reads all the data from the RFID card
}}
  Offset := 0
  repeat OuterLoop from 1 to 33
  
    IO.str( string( "!RW", RFID_Read ) )
    IO.tx ( OuterLoop )

    ErrCheck := IO.rx

    if ErrCheck <> ERR_OK
      Result := 0
    else
      repeat InnerLoop from 0 to 3
        CardDataBuffer[ Offset ] := IO.rx
        Offset++
      Result := 1  


PRI WriteCardData( AtAddress, DataToWrite ) | LoopCounter , ErrCheck
{{
  Driver function that writes data to the  RFID card
}}
  IO.str( string( "!RW", RFID_Write ) )
  IO.tx ( AtAddress )

  repeat LoopCounter from 0 to 3
    IO.tx( byte[ DataToWrite + LoopCounter ] )

  ErrCheck := IO.rx

  if ErrCheck <> ERR_OK
    Result := 0
  else
    Result := 1  



PRI SetCardPassword( OldPwd, NewPwd ) | ErrCheck, LoopCounter
{{
  Driver function that changes the password the RFID card
}}
  IO.str( string( "!RW", RFID_SetPass ) )

  repeat LoopCounter from 0 to 3 
    IO.tx ( byte[ OldPwd + LoopCounter ] )

  repeat LoopCounter from 0 to 3 
    IO.tx ( byte[ NewPwd + LoopCounter ] )

  ErrCheck := IO.rx

  if ErrCheck <> ERR_OK
    Result := 0
  else
    Result := 1  



PRI ResetTheCard | ErrCheck
{{
  Driver function that resets the RFID card
}}
  IO.str( string( "!RW", RFID_Reset ) )

  ErrCheck := IO.rx

  if ErrCheck <> ERR_OK
    Result := 0
  else
    Result := 1  



PRI UnlockTheCard | ErrCheck
{{
  Driver function that unlocks the RFID card
}}
  IO.str( string( "!RW", RFID_Protect ) )
  IO.tx ( $00 )

  ErrCheck := IO.rx

  if ErrCheck <> ERR_OK
    Result := 0
  else
    Result := 1  



PRI LockTheCard | ErrCheck
{{
  Driver function that locks the RFID card
}}
  IO.str( string( "!RW", RFID_Protect ) )
  IO.tx ( $01 )

  ErrCheck := IO.rx

  if ErrCheck <> ERR_OK
    Result := 0
  else
    Result := 1  



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