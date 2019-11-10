'' WS2812B_RGB_LED_Driver
'' by Gavin T. Garner
'' University of Virginia
'' April 20, 2012
{  This object can be used to control a Red-Green-Blue LED light strip (such as the 1m and 2m 
   ones available from Pololu.com as parts #2540 and #2541). These strips incorporate TM1804 chips by
   Titan Micro (one for each RGB LED) and 24-bit color data is shifted into them using quick pulses
   (~1300ns=Digital_1 and ~700ns=Digital_0). Because these pulses are so quick, they must be generated
   using PASM code. The advantage to this is that they can be updated and changed much more quickly
   than other types of addressable RGB LED strips. Note that this code will not control RGB LED strips
   that use WS2801 chips (such as the ones currently sold by Sparkfun.com).
                                    Instructions for use:
   Wiring:
         Propeller I/O pin (your choice) <---> IN  (silver wire with white stripe on Pololu Part) 
                         Propeller's Vss <---> GND (silver wire with no stripe on Pololu Part)
   NC (both GND terminals are connected) <---> GND (black wire w/dashed white stripe on Pololu Part)
        5V Power Supply (1.25Amps/meter) <---> +VC (black wire with no stripe on Pololu Part)
   Software:
   Insert this RGB_LED_Strip object into your code and call the "start" method. This will
   start the assembly program on a new cog where it will run continuously and take care of
   communication between your spin code and the TM1804 chips. Once this PASM driver is started, you
   can call the methods below such as rgb.ChangeLED(0,255)
   You can also create your own methods, but note that you must set the "update" variable to a
   non-zero value (eg. update:=true) whenever you want the LEDs to change/update
   Note: If you want to control more than 60 LEDs (2 meters), you will need to increase the number
   of longs alotted to the LED variable array below (eg. lights[120] for two 2m strips wired together).
                                       HAVE FUN!!!                                                  }  
CON        'Predefined colors that can be accessed from your code using rgb#constant:
                                                ' green    red      blue              
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
  
  NUM_LEDS       = 256
 
VAR
  long update           ' Controls when LED values are sent (its address gets loaded into Cog 1)      
  long max_address      ' Address of the last LED in the string                                       
  long cog, frame_cog   ' Store cog # (so that the cog can be stopped)                                
  long lights[NUM_LEDS] ' Actual order of LEDs after daisy-chaining
  long previous_lights[NUM_LEDS] ' LEDs from the past state
  long frame_stack[100] ' Stack for frames  
  long fps              ' Game's update rate (1/fps)

'' Starts RGB LED Strip driver on a cog, returns false if no cog available.
'' Note: Requires at least a 20MHz system clock.
''
'' PARAMS: `output_pin` the output pin connected to the LEDs
'' PARAMS: `leds` the number of LEDs
PUB start(output_pin) : okay
  _LEDs := NUM_LEDS
  _pin := output_pin
  max_address := NUM_LEDS - 1 
  _update := @update    
                                                  

  'TODO: change values based on actual values?
  'LED Strip WS2812B chip
  High0 := clkfreq / 2_500_000  '0.4us
  Low0 := clkfreq / 1_176_470 '0.85us
  High1 := clkfreq / 1_250_000 '0.8us
  Low1 := clkfreq / 2_222_222 '0.45us  
  reset := clkfreq / 20_000 '50us             

  stop                                        ' Stop the cog (just in case)
  okay := cog := cognew(@RGBdriver,@lights)+1 ' Start PASM RGB LED Strip driver

'' Stops the LED driver and releases the cog
PUB stop          
  if cog
    cogstop(cog~ - 1)
    
'' Bottom left is the origin.
'' LED panels start 0 in bottom left for each, arranged in the following way:
'' PANEL 4   PANEL 3
'' PANEL 1   PANEL 2
''
'' PARAMS: `x` the x value for the index
'' PARAMS: `y` the y value for the index
PUB xy_to_index(x, y) | new_x, new_y, position_in_grid
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

'' Starts the game engine. This starts the cog that updates new_fps times per second.
''
'' PARAMS: `new_fps` the framerate to update at
PUB start_engine(new_fps, update_frame_address) | my_matrix
  _update_frame := update_frame_address
  fps := new_fps
  longmove(@previous_lights, @lights, NUM_LEDS)
  if frame_cog <> -1
    frame_cog := cognew(update_frame, @frame_stack) + 1
    
  return frame_cog
  
'' Stops the framerate cog, causing the game to stop running and turns off all LEDs.
PUB stop_engine
  if frame_cog
    cogstop(frame_cog~ - 1)
    
  ' Wait to ensure updates don't overlap
  waitcnt(clkfreq/100 + cnt)
  all_off
  update_leds
 
'' Sets pixel at (x, y) to the given color, where (x, y) is based from bottom left.
'' Does NOT immediately update the LEDs with the pixel - relegated to fps process.
''
'' PARAMS: `color` the rgb value to change the pixel to
PUB set_pixel(x, y, color)
  if x < 0 or x > 31 or y < 0 or y > 31
    return
  lights[xy_to_index(x, y)] := color

'' Gets the color at position (x, y) from the bottom left.
PUB get_previous_pixel(x, y) 
  if x < 0 or x > 31 or y < 0 or y > 31
    return off
  return get_previous_color(xy_to_index(x, y))
  
'' Gets the color at position (x, y) from the bottom left.
PUB get_pixel(x, y)
  if x < 0 or x > 31 or y < 0 or y > 31
    return off
  return get_color(xy_to_index(x, y))

'' Updates the LEDs 
PUB update_leds
  update := 1

'' Updates the color of LED at a specific address with color and updates the grid
''
'' PARAMS: `led_address` the daisy-chained address of the light to change color
PUB set_led(led_address, color)
  lights[led_address] := color
  update_leds

'' Turns off all of the LEDs
PUB all_off | i                    
  longfill(@lights, 0, max_address + 1) 
  update_leds

'' Sets all LEDs to specified color
PUB set_all_colors(color)
  longfill(@lights,color, max_address + 1)
  update_leds

'' Sets the LED at led_address to a specified, separated RGB value
PUB set_led_rgb(led_address, _red, _green, _blue)
  lights[led_address] := _red<<16 + _green<<8 + _blue
  update_leds

'' Sets the LED at led_address to the given color with the given intensity (from 0-255)
PUB set_led_intensity(led_address, color, intense)
  lights[led_address]:=((((color>>16)*intense)/255)<<16) +((((color>>8 & $FF)*intense)/255)<<8)+(((color & $FF)*intense)/255)
  update_leds

'' Changes the intensity of a color.
''
'' PARAMS: `intense` the value of the new intensity from 0 (no intensity) to 255 (max intensity)
'' RETURNS: the new RGB value associated with the passed intensity
PUB change_intensity(color, intense) : newvalue
  newvalue:=((((color>>16)*intense)/255)<<16) +((((color>>8 & $FF)*intense)/255)<<8)+(((color & $FF)*intense)/255)
  update_leds
  
'' Sets the LEDs from start to end with a given color
PUB set_section(address_start, address_end, color)
  longfill(@lights[address_start], color, address_end - address_start + 1)
  '       (@lights[address_end] - @lights[address_start])/4) 
  update_leds
  
'' Gets the color at led_address and returns it
PUB get_previous_color(led_address) : color
  
  color := previous_lights[led_address]

'' Gets the color at led_address and returns it
PUB get_color(led_address) : color
  color := lights[led_address]

'' Updates the LEDs fps times per second.
PRI update_frame
  repeat
    repeat until long[_update_frame] == 0
      next
    update_leds
    longmove(@previous_lights, @lights, NUM_LEDS)
    long[_update_frame] := 1
    waitcnt(clkfreq/fps + cnt)
  

DAT
''This PASM code sends control data to the RGB LEDs on the strip once the "update" variable is set to
'' a value other than 0
              org       0                 
RGBdriver     mov       pinmask,#1          'Set direction of data pin to be an output 
              shl       pinmask,_pin
              mov       dira,pinmask
              mov       index,par           'Set index to LED variable array's base address

StartDataTX   rdlong    check,_update       '                                                  
              tjz       check,#StartDataTX  'Wait for Cog 0 to set "update" to true or 1       
              mov       count,#0            'Start with "index" count=0
                                                                                               
AddressLoop   rdlong    RGBvalue,index      'Fetch RGB[index] value from central Hub RAM       
              mov       shift,#23           'Start with shift=23 (shift to MSB of Red value)   
                                                                                               
BitLoop       mov       outa,pinmask        'Set data pin High
              mov       getbit,RGBvalue     'Store RGBvalue as "getbit"                   
              shr       getbit,shift        'Shift this RGB value right "shift" # of bits 
              and       getbit,#1           'Lop off all bits except LSB                  
              cmp       getbit,#1       wz  'Check if bit=1, if so, set Z flag            
        if_z  jmp       #DigiOne                                                          
DigiZero      mov       counter,cnt         'Output a pulse corresponding to a digital 0 
              'add       counter,High0  
              
              'waitcnt   counter,Low0        'Wait for 0.7us
              add       counter,Low0
              mov       outa,#0             'Set data pin Low 
              waitcnt   counter,#0          'Wait for 1.8us

              tjz       shift,#Increment    'If shift=0, jump down to "Increment"         
              sub       shift,#1            'Decrement shift by 1                         
              jmp       #BitLoop            'Repeat BitLoop if "shift" has not reached 0                                                      

DigiOne       mov       counter,cnt         'Output a pulse corresponding to a digital 1
              add       counter,High1
              waitcnt   counter,Low1        'Wait for 1.3us
              mov       outa,#0             'Set data pin Low
              waitcnt   counter,#0          'Wait for 1.2us
              tjz       shift,#Increment    'If shift=0, jump down to "Increment"         
              sub       shift,#1            'Decrement shift by 1                         
              
              jmp       #BitLoop            'Repeat BitLoop if "shift" has not reached 0 

Increment     add       index,#4            'Increment index by 4 byte addresses (1 long)                             
              add       count,#1            'Increment count by 1
              cmp       count,_LEDs    wz   'Check to see if all LEDs have been set  
        if_nz jmp       #AddressLoop        'If not, repeat AddressLoop for next LED's RGBvalue

              mov       counter,cnt                                                                        
              add       counter,reset                                                                      
              waitcnt   counter,#0          'Wait for 24us (reset datastream)                              
              wrlong    zero,_update        'Set update value to 0, wait for Cog 0 to reset this
              mov       index,par           'Set index to LED variable array's base address
              jmp       #StartDataTX
                      
                                            'Starred values (*) are set before cog is loaded
_update       long      0                   'Hub RAM address of "update" will be stored here*
_update_frame long      0
_pin          long      0                   'Output pin number will be stored here*
_LEDs         long      0                   'Total number of LEDs will be stored here*
High1         long      0                   '~1.3 microseconds(digital 1)*
Low1          long      0                   '~1.2 microseconds*            
High0         long      0                   '~0.7 microseconds(digital 0)* 
Low0          long      0                   '~1.8 microseconds*            
reset         long      0                   '~25 microseconds (the 24us spec doesn't seem to work)*            
zero          long      0
pinmask       res
RGBvalue      res
getbit        res
counter       res
count         res
check         res
index         res
shift         res
last          res
              fit

{Copyright (c) 2012 Gavin Garner, University of Virginia                                                                              
MIT License: Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated             
documentation files (the "Software"), to deal in the Software without restriction, including without limitation the                   
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit                
persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and               
this permission notice shall be included in all copies or substantial portions of the Software. The software is provided              
as is, without warranty of any kind, express or implied, including but not limited to the warrenties of noninfringement.              
In no event shall the author or copyright holder be liable for any claim, damages or other liablility, out of or in                   
connection with the software or the use or other dealings in the software.}       