CON     
  _xinfreq=6_250_000          'The system clock is set at 100MHz (you need at least a 20MHz system clock)
  _clkmode=xtal1+pll16x            
  num_leds = 1024
    
OBJ
  rgb : "WS2812B_RGB_LED_Driver"
  demo: "demo_game"

PUB main | i
  rgb.start(0, num_leds) 
  waitcnt(clkfreq + cnt)
  rgb.all_off
  'waitcnt(clkfreq/+cnt)
  rgb.stop
  
  demo.start
  demo.stop