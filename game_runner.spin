CON                          
  num_leds = 256  
  
OBJ
  rgb : "WS2812B_RGB_LED_Driver"           'Include WS2812B_RGB_LED_Driver object and call it "rgb" for short

PUB Demo | i, j, x, maxAddress
  rgb.start(3, num_leds)  'Start up RGB LED driver on a new cog, set data pin to be P0, 
  'rgb.start(0,TotalLEDs, 5, 6)    'Start up RGB LED driver on a new cog, set data pin to be P0,   
                                  ' and specify that there are 60 LEDs in the strip (2 meters)
  'maxAddress:=TotalLEDs-1         'LED addresses start with zero so 59 will be the maximum address
  repeat i from 0 to num_leds
    rgb.set_led(i, rgb#orange)
    i += 1
    waitcnt(clkfreq/2 + cnt)
    
  {                                '
repeat
  rgb.AllOff                      'You can turn off all of the LEDs at once
  waitcnt(clkfreq+cnt)

  rgb.AllOff

  rgb.Triangle(rgb.Intensity(rgb#orange, 32), rgb.Intensity(rgb#blue, 32), 20)
  waitcnt(clkfreq + cnt)
  rgb.AllOff

  rgb.LED_STRING(STRING(" go hoos go "), 0, LetterOffset, rgb.Intensity(rgb#orange, 64), 25)
  rgb.Flash(3, 1)

  rgb.Snake(rgb.Intensity(rgb#blue,32), 25, 10)

  rgb.Checker(rgb.Intensity(rgb#orange, 32), rgb.Intensity(rgb#blue, 32), rgb.Intensity(rgb#crimson, 32), rgb.Intensity(rgb#turquoise, 16), 50)
  waitcnt(clkfreq/2+cnt)
  rgb.AllOff

  rgb.FadeInOut(60)
  rgb.AllOff
  
  rgb.LED_STRING(STRING("gizmologists"), 0, LetterOffset, rgb.Intensity(rgb#blue, 64), 25)
  rgb.Flash(3, 1)

  rgb.Snake(rgb.Intensity(rgb#orange,32), 25, 10)

  rgb.StackOn(rgb.Intensity(rgb#red,32), rgb.Intensity(rgb#cyan,16), rgb.Intensity(rgb#white,8))
  rgb.AllOff
  
  rgb.FlipFlop(rgb.Intensity(rgb#red, 32), rgb.Intensity(rgb#blue, 32), rgb.Intensity(rgb#green, 32), 65)
  rgb.AllOff
 
  rgb.AllOff
  rgb.LED_STRING(STRING("  wahoowa   "), 0, LetterOffset, rgb.Intensity(rgb#orange, 64), 25)
  rgb.Flash(3, 1)

  rgb.Snake(rgb.Intensity(rgb#blue,32), 25, 10)

  rgb.FillBackAndForth(rgb.Intensity(rgb#white, 8), rgb.Intensity(rgb#yellow, 16), rgb.Intensity(rgb#green, 32), rgb.Intensity(rgb#crimson, 32), 75)
  waitcnt(clkfreq/2+cnt)
  rgb.AllOff
  
  rgb.Box(rgb.Intensity(rgb#yellow, 16), rgb.Intensity(rgb#magenta, 16), rgb.Intensity(rgb#red, 32), rgb.Intensity(rgb#blue, 32), 50)
  waitcnt(clkfreq+cnt)
  rgb.AllOff
          
  rgb.StickFigure(rgb.Intensity(rgb#red, 64), 10)
  rgb.AllOff   
  }                
  
     

{Copyright (c) 2012 Gavin Garner, University of Virginia                                                                              
MIT License: Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated             
documentation files (the "Software"), to deal in the Software without restriction, including without limitation the                   
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit                
persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and               
this permission notice shall be included in all copies or substantial portions of the Software. The software is provided              
as is, without warranty of any kind, express or implied, including but not limited to the warrenties of noninfringement.              
In no event shall the author or copyright holder be liable for any claim, damages or other liablility, out of or in                   
connection with the software or the use or other dealings in the software.}            
