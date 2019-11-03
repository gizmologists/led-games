
CON     
  _xinfreq=5_000_000          'The system clock is set at 100MHz (you need at least a 20MHz system clock)
  _clkmode=xtal1+pll16x            
  num_leds = 1024
  
  up = 1
  down = 2
  left = 3
  right = 4
    
OBJ
  rgb : "WS2812B_RGB_LED_Driver"
  demo: "demo_game"
  pst : "Parallax Serial Terminal"

PUB main | i

  'rgb.start(0, num_leds) 
  'waitcnt(clkfreq + cnt)
  'rgb.all_off
  'waitcnt(clkfreq/+cnt)
  'rgb.stop
  
  'rgb.set_led(0, rgb#blue)
  'rgb.set_led(1, rgb#blue)
  'rgb.update_leds
  demo.start
  'demo.stop