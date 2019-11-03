CON          
  num_leds = 1024
 
  off  = 0
  blue = 50

OBJ
  rgb : "WS2812B_RGB_LED_Driver"
  ' PST object for debugging
  'pst : "Parallax Serial Terminal"

VAR
  long update
  
PUB start
  ' Start PST for debugging - if clockrate problems fixed, change baud 144000 -> 115200
  'pst.start(144000)
  rgb.start(0, num_leds)
  update := 0
  
  ' Give a basic starting pattern that goes through a fair few iterations
  repeat x from 0 to 31
    rgb.set_pixel (x,0,blue)
    rgb.set_pixel (x,31,blue)
  repeat y from 1 to 30
    rgb.set_pixel (0,y,blue)
    rgb.set_pixel (31,y,blue)


  ' Start the engine and wait just in case (probably don't need a full second)
  rgb.start_engine(2, @update)
  waitcnt(clkfreq+cnt)

  ' Main game loop - NOTE this should stop on a condition eg `repeat until game_done` but
  ' don't do that here - this is a demo game after all. But, this loop is run once per frame.
  repeat 
    if update > 0
      update_frame
      update := 0
      
  ' Should call stop after game done, so it's put here, but never reached
  stop
 
'' Stops the game
PUB stop
  rgb.all_off
  waitcnt(clkfreq/2+cnt)
  rgb.stop_engine
  rgb.stop
  
'' Code to be run every frame
'' LEDs are not updated until this code is done - make sure it's fast!
PUB update_frame | 
    