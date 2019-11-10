CON      
  FPS = 2

  off  = rgb#off
  blue = rgb#blue
  red = rgb#red
  green = rgb#chartreuse
  dark_green = 128

OBJ
  rgb : "WS2812B_RGB_LED_Driver"
  ' PST object for debugging
  'pst : "Parallax Serial Terminal"

VAR
  long update_frame
  long snake_X[900]
  long snake_Y[900]
  long snake_start
  long snake_len
  
'' Start the game
' Naming convention: Function takes in __ (double underscore) before variables that
' are just assigned to a variable in the VAR section.
' This is needed because no `this` exists in spin - so they have to be different names
PUB start(leds, __button_green)
  ' Initialize variables
  update_frame := 0
  ' Set pin variables - Add more variables if more buttons etc. are needed
  button_green := __button_green
  
  ' Start RGB driver
  rgb.start(leds)
  
  ' Performs game setup
  setup_game
  
  ' Start the engine and wait just in case (probably don't need a full second)
  rgb.start_engine(FPS, @update_frame)
  waitcnt(clkfreq+cnt)

  ' Main game loop - NOTE this should stop on a condition eg `repeat until game_done` but
  ' don't do that here - this is a demo game after all. But, this loop is run once per frame.
  repeat 
    if update_frame > 0
      perform_frame_update
      update_frame := 0
      
  ' Should call stop after game done, so it's put here, but never reached
  stop
 
'' Stops the game
PUB stop
  rgb.all_off
  waitcnt(clkfreq/2+cnt)
  rgb.stop_engine
  rgb.stop
  
PUB setup_game | x, y
  ' Draw the border
  repeat x from 0 to 13'31
    rgb.set_pixel (x,0,blue)
    rgb.set_pixel (x,13,blue)'(x,31,blue)
  repeat y from 1 to 12
    rgb.set_pixel (0,y,blue)
    rgb.set_pixel (13,y,blue)'(31,y,blue)
  
'' Code to be run every frame
'' LEDs are not updated until this code is done - make sure it's fast!
PUB perform_frame_update
  