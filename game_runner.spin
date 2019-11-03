
CON     
  _xinfreq=5_000_000          'The system clock is set at 100MHz (you need at least a 20MHz system clock)
  _clkmode=xtal1+pll16x            
  
  'PINS
  LEDS = 0
  BUTTON_GREEN = 21
    
OBJ
  rgb : "WS2812B_RGB_LED_Driver"
  demo: "demo_game"
  'pst : "Parallax Serial Terminal"

PUB main | i
  ' Set pin directions
  DIRA[LEDS] := 1
  DIRA[BUTTON_GREEN] := 0
  demo.start(LEDS, BUTTON_GREEN)