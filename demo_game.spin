OBJ
  rgb : "WS2812B_RGB_LED_Driver"

'' Starts the game
PUB start | i
  rgb.start_engine(2)
  repeat i from 0 to 8
    rgb.set_pixel (i*2, i, rgb#blue)
    waitcnt(clkfreq/3 + cnt)
  stop
  
'' Stops the game
PUB stop
  rgb.all_off
  rgb.stop_engine
