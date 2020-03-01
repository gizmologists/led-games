
CON     
  _xinfreq=5_000_000          'The system clock is set at 100MHz (you need at least a 20MHz system clock)
  _clkmode=xtal1+pll16x            
  
  'PINS
  LEDS = 0
  JOYSTICK_LEFT = 20
  JOYSTICK_UP = 23
  JOYSTICK_RIGHT = 21
  JOYSTICK_DOWN = 22
    
OBJ
  rgb : "WS2812B_RGB_LED_Driver"
  snake: "snake"
  'pst : "Parallax Serial Terminal"

PUB main | i
  'pst.start(115200)
  ' Set pin directions
  DIRA[LEDS] := 1
  DIRA[JOYSTICK_LEFT] := 0
  DIRA[JOYSTICK_UP] := 0
  DIRA[JOYSTICK_RIGHT] := 0
  DIRA[JOYSTICK_DOWN] := 0
  repeat
    'pst.str(string("STARTING"))
    'pst.newline
    snake.start(LEDS, JOYSTICK_LEFT, JOYSTICK_UP, JOYSTICK_RIGHT, JOYSTICK_DOWN)
    'pst.str(string("STARTING SOON"))
    'pst.newline
    waitcnt(clkfreq+cnt)