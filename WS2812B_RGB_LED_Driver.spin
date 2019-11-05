'' WS2812B_RGB_LED_Driver
'' by Quintin DeGroot and Evan Typanski 
'' University of Virginia
'' October 21, 2019
{  
   This object can be used to control 16x16 Red-Green-Blue LED light panels incorporating the WS2812B chips by
   WorldSemi (one for each RGB LED). The datasheet referenced to create this driver is found here:
   https://cdn-shop.adafruit.com/datasheets/WS2812B.pdf. 
   
   To control these chips, 24-bit color data is shifted into them using quick pulses at a speed of 800 kbps
   (1.25us per bit). Digital 0 is sent as 0.4us high then 0.85us low, Digital 2 as 0.8us high, 0.45us low.
   Data will normally be "pushed" along the strand, but a low voltage for at least 50us low will signal a
   reset and the next value as it moves through the strand will overwrite rather than push the value in 
   front of it along. Propeller Assembly Language (PASM) is used for this to ensure clock cycle reliability
   on these very small delays.
                                    Instructions for use:
   Wiring:
         Propeller I/O pin (your choice) <---> DIN 
                         Propeller's Vss <---> GND 
   NC (both GND terminals are connected) <---> GND ???????????
        5V Power Supply (1.25Amps/meter) <---> VDD (also with a capacitor off to ground? TODO Evan help me here)
   Layout:
   PANEL 4    PANEL 3
   PANEL 1    PANEL 2
   Software:
   This code essentially supplies a virtual 2D array that can be modified at will and is bitmapped to a screen
   made of 4 linked 16x16 led panels (1024 leds in all). These are addressed such that 0,0 in the virtual array
   is at the bottom left, and 31,31 is at the top right. An update can be requested by calling frame_update,
   which will allow the current state of the virtual array to be written to the screen. Please for the love
   of god don't import multiple instances of this object or else you'll be sent straight to concurrency hell.
   Colors can always be specified by the constants provided here (<this_obj_import_name>#<color>), or you
   can make your own. Note that all virtual array reads and writes will hang in order to avoid interacting with
   the stored array while a screen refresh is in progress.
   
   A brief warning: The screen should be refreshed at no more than 10 fps. This is because 
   a full write takes 30.72ms (1.25us*24*1024), and a frame at 10 fps is only 100 ms. Theoretically the framerate 
   could be pushed as high as ~30 fps, but in order to have the dominant period of the time being a static frame
   rather than an overwrite transition, we recommend a rate 1/3 of minimal. 
   
   Public Methods:
     start_update_cog(pin)  - starts an available cog outputting led signals on pin if a cog is available, returns -1 otherwise
     stop_update_cog()      - if an update cog is set, stops it. Serves as a destructor
     write_pixel(x,y,color) - writes a 24-bit value color to position x,y in virtual array
     read_pixel(x,y)        - reads a 24-bit color value from position x,y in virtual array
     set_all(color)         - writes a 24-bit value color to every position in virtual array
     frame_update()         - request for leds to be updated.
   Private Methods:
     xy_to_index(x, y)      - transforms an x,y position in the virtual array to an index value in lights[]
   PASM:
     PinInit: sets given pin to be output
     UpdateDelay: sets output pin low and resets "update" to the false state, then waits until update is set again
     DataInit: Loads starting address of the LED array. Sets address back by 4 to allow exit condition to work easier
     LEDLoop: Iterates long-by-long through the LED array. Within each long, bounces back and forth between digi0 and
              digi1. Guaranteed to give fastest possible iteration through array on clock speeds of at least ~60 Mhz.
}
  
CON
  {Predefined colors}                           ' blue     red      green               
  off            = 0                            '%00000000_00000000_00000000
  red            = 255<<8                       '%00000000_11111111_00000000
  green          = 255<<16                      '%11111111_00000000_00000000 
  blue           = 255                          '%00000000_00000000_11111111 
  white          = 255<<16+255<<8+255           '%11111111_11111111_11111111 
  cyan           = 255<<16+255                  '%11111111_00000000_11111111 
  magenta        = 255<<8+255                   '%00000000_11111111_11111111 
  yellow         = 255<<16+255<<8               '%11111111_11111111_00000000 
  chartreuse     = 255<<16+127<<8               '%11111111_01111111_00000000
  orange         = 60<<16+255<<8                '%10100101_11111111_11010100        
  aquamarine     = 255<<16+127<<8+212           '%11111111_11111111_11010100
  pink           = 128<<16+255<<8+128           '%10000000_11111111_10000000
  turquoise      = 224<<16+63<<8+192            '%10000000_00111111_10000000
  realwhite      = 255<<16+200<<8+255           '%11100000_11001000_11000000
  indigo         = 170                          '%00000000_00111111_01111111
  violet         = 51<<16+215<<8+255            '%01111111_10111111_10111111
  crimson        = 153<<8                       '%00000000_10011001_00000000
  {Number of led's in all linked strips}
  NUM_LEDS       = 16*16*4                      '1024
 
VAR
  long update
  long led_update_cog
  long lights[NUM_LEDS]

PUB null
  ' Don't use this as a top-level object, geez, it's a driver

PUB start_update_cog(pin) : cog_num
  { setting vars for loading into cog }
  pinmask := |< pin
  _stop   := @lights + NUM_LEDS*4 - 4
  _update := @update
  High0   := clkfreq / 2_500_000   '0.4us, about 32 cycles at 80 Mhz
  Low0    := clkfreq / 1_176_470   '0.85us, about 64 cycles at 80 Mhz
  High1   := clkfreq / 1_250_000   '0.8us, about 64 cycles at 80 Mhz
  Low1    := clkfreq / 2_222_222   '0.45us, about 32 cycles at 80 Mhz
  { starting led updater cog }
  stop_update_cog
  cog_num := led_update_cog := cognew(@RGBDriver, @lights) ' todo: could I just write the value of @lights to save setup cycles?

PUB stop_update_cog
  if led_update_cog
    cogstop(led_update_cog~ - 1)

PUB write_pixel(x,y,color) | arr_pos
  arr_pos := xy_to_index(x, y)
  repeat while update ' Refuse to interact with array while led update is in progress
  lights[arr_pos] := color 

PUB read_pixel(x,y) | arr_pos
  arr_pos := xy_to_index(x, y)
  repeat while update ' Refuse to interact with array while led update is in progress
  return lights[arr_pos]

PUB set_all(color)
  longfill(@lights, color, NUM_LEDS)

PUB frame_update
  update := 1


  
PRI xy_to_index(x, y) | new_x, new_y, position_in_grid
  new_x := x // 16
  new_y := y // 16
  ' Position in its individual matrix is position_in_grid
  if (new_x // 2 == 0)
    position_in_grid := (new_x * 16) + new_y
  else
    position_in_grid := (new_x * 16) + (15 - new_y)

  ' Now figure out which grid
  if x < 16 and y < 16
    return position_in_grid
  elseif x => 16 and y < 16
    return position_in_grid + 256
  elseif x => 16 and y => 16
    return position_in_grid + 256 * 2
  elseif x < 16 and y => 16
    return position_in_grid + 256 * 3

DAT
              org       0
RGBdriver     nop
PinInit       or        DIRA, pinmask
UpdateDelay   andn      OUTA, pinmask
              wrlong    zero, _update
:Loop         rdlong    check, _update
              tjz       check, #:Loop 
DataInit      mov       index, PAR
              sub       index, #4
LEDLoop       mov       bitmask, basebitmask
              add       index, #4
              cmp       index, _stop        WZ
       if_z   jmp       UpdateDelay
              rdlong    rgbval, index
              shr       rgbval, #8              
              and       rgbval, bitmask     WZ, NR
       if_z   mov       time, High0
       if_nz  mov       time, High1
              add       time, CNT
              or        OUTA, pinmask
       if_z   jmp       #:DigiZero
              jmp       #:DigiOne      
:DigiZero     waitcnt   time, Low0                  
              andn      OUTA, pinmask
              shr       bitmask, #1         WC
              and       rgbval, bitmask     WZ, NR
       if_z   mov       next_period, High0
       if_nz  mov       next_period, High1      
              waitcnt   time, next_period
              or        OUTA, pinmask
       if_c   jmp       #LEDLoop
       if_z   jmp       #:DigiZero
              jmp       #:DigiOne      
:DigiOne      shr       bitmask, #1         WC        
              and       rgbval, bitmask     WZ, NR
       if_z   mov       next_period, High0
       if_nz  mov       next_period, High1                                      
              waitcnt   time, Low1
              andn      OUTA, pinmask
              waitcnt   time, next_period  
              or        OUTA, pinmask            
       if_c   jmp       #LEDLoop
       if_nz  jmp       #:DigiZero
              jmp       #:DigiOne

{ All of these have their values already }
zero          long      0     ' A register holding a value of zero, necessary for how WRLONG works
basebitmask   long      |< 23 ' Sets the 24th bit of the long, the first bit used by a color value
{ All of these need to be set before this is called }
_update       long      0     ' Address of the "update" semaphore in main memory
_stop         long      0     ' Address after the last stored LED value in main memory
pinmask       long      0     ' Long with the xth bit set, where x is the pin going to the led's DIN
High0         long      0     ' Number of cycles to wait for the high segment of a digital 0 (0.4us)
Low0          long      0     ' Number of cycles to wait for the low segment of a digital 0 (0.85us)
High1         long      0     ' Number of cycles to wait for the high segment of a digital 1 (0.45us)
Low1          long      0     ' Number of cycles to wait for the low segment of a digital 1 (0.8us)
{ All of these are set and modified internally }
check         res             ' Long holding value read from update
index         res             ' Long holding address currently reading from
bitmask       res             ' Long with a shifting bit set that maps to the bit of rgbval being examined
time          res             ' Long containing a shifting value used for waitcnt's
next_period   res             ' Long that depends on whether the next bit is 1 or 0. Helps minimize required jmp's
rgbval        res             ' 24-bit rgb value loaded from lights[] currently being examined
{ Makes sure all of the above fits in cog ram at compile time }
fit                         



{Copyright (c) 2019 Gizmologists, University of Virginia                                                                              
MIT License: Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated             
documentation files (the "Software"), to deal in the Software without restriction, including without limitation the                   
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit                
persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and               
this permission notice shall be included in all copies or substantial portions of the Software. The software is provided              
as is, without warranty of any kind, express or implied, including but not limited to the warrenties of noninfringement.              
In no event shall the author or copyright holder be liable for any claim, damages or other liablility, out of or in                   
connection with the software or the use or other dealings in the software.}       