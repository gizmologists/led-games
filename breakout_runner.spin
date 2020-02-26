
CON     
  _xinfreq=5_000_000          'The system clock is set at 100MHz (you need at least a 20MHz system clock)
  _clkmode=xtal1+pll16x            
  
  'PINS
  LEDS = 0
  JOYSTICK_LEFT = 25
  JOYSTICK_RIGHT = 24
    
OBJ
  rgb : "WS2812B_RGB_LED_Driver"
  breakout: "breakout"
  pst : "Parallax Serial Terminal"

PUB main | i
  ' Set pin directions
  DIRA[LEDS] := 1
  DIRA[JOYSTICK_LEFT] := 0
  DIRA[JOYSTICK_RIGHT] := 0
  repeat
    breakout.start(LEDS, JOYSTICK_LEFT, JOYSTICK_RIGHT)
    waitcnt(clkfreq+cnt)