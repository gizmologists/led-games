CON     
  _xinfreq=6_250_000          'The system clock is set at 100MHz (you need at least a 20MHz system clock)
  _clkmode=xtal1+pll16x            
  num_leds = 1024
    
OBJ
  rgb : "WS2812B_RGB_LED_Driver"
  'demo: "demo_game"

PUB main | i
  rgb.start(0, num_leds)
  
  waitcnt(clkfreq + cnt)
  rgb.all_off
  'demo_game.start
  'demo_game.stop
  rgb.start_engine(2)
  
  repeat i from 0 to 15
    rgb.set_pixel (i*2, i, rgb#blue)
    waitcnt(clkfreq/3 + cnt)
    
  repeat i from 0 to 15
    rgb.set_pixel (i*2, i+16, rgb#blue)
    waitcnt(clkfreq/3 + cnt)