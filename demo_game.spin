CON      
  FPS = 2

  ' Variables needed to make checks/intensity better - can also use variables in rgb
  off  = 0
  blue = 50

OBJ
  rgb : "WS2812B_RGB_LED_Driver"
  ' PST object for debugging
  'pst : "Parallax Serial Terminal"

VAR
  long update_frame
  long button_green
  
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
  
PUB setup_game
  ' Draw the border
  repeat x from 0 to 31
    rgb.set_pixel (x,0,blue)
    rgb.set_pixel (x,31,blue)
  repeat y from 1 to 30
    rgb.set_pixel (0,y,blue)
    rgb.set_pixel (31,y,blue)
  
'' Code to be run every frame
'' LEDs are not updated until this code is done - make sure it's fast!
PUB perform_frame_update | x, y, x_offset, y_offset, num_neighbors
  ' 1 to 30 covers whole grid, but makes it slow
  ' Use subset to go faster (eg 1 to 10)
  repeat x from 1 to 30
    repeat y from 1 to 30
      num_neighbors := 0
      repeat x_offset from -1 to 1
        repeat y_offset from -1 to 1
          if rgb.get_previous_pixel(x + x_offset, y + y_offset) <> off
            num_neighbors++
            
      if num_neighbors == 3 or (num_neighbors == 4 and rgb.get_previous_pixel(x, y) <> off)
        rgb.set_pixel(x, y, blue)
      else
        rgb.set_pixel(x, y, off)