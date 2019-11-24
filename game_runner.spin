
CON     
  _xinfreq=5_000_000          'The system clock is set at 100MHz (you need at least a 20MHz system clock)
  _clkmode=xtal1+pll16x            
  
  'PINS
  LEDS = 0
  BUTTON_GREEN = 21
  DOWN = 24
  UP = 25
  RIGHT = 26
  LEFT = 27
    
OBJ
  rgb : "WS2812B_RGB_LED_Driver"
  demo: "demo_game_button"
  tetris: "tetris_game"
  'pst : "Parallax Serial Terminal"

PUB main | i
  'pst.start(115200)
  ' Set pin directions
  DIRA[LEDS] := 1
  DIRA[BUTTON_GREEN] := 0
  DIRA[UP] := 0
  DIRA[DOWN] := 0
  DIRA[LEFT] := 0
  DIRA[RIGHT] := 0
  tetris.start(0, BUTTON_GREEN, UP, DOWN, LEFT, RIGHT)
  {
  repeat
    pst.str(String("Green Button:"))
    pst.dec(INA[BUTTON_GREEN])
    pst.newline
    pst.str(String("Up:"))
    pst.dec(INA[UP])
    pst.newline
    pst.str(String("Down:"))
    pst.dec(INA[DOWN])
    pst.newline
    pst.str(String("Left:"))
    pst.dec(INA[LEFT])
    pst.newline
    pst.str(String("Right:"))
    pst.dec(INA[RIGHT])
    pst.newline
    pst.newline
    
    waitcnt(clkfreq+cnt)}
  demo.start(LEDS, BUTTON_GREEN)