CON      
  FPS = 8

  off  = rgb#off
  blue = 32
  red = rgb#red
  chartreuse = 32<<16+16<<8
  dark_green = 32<<16
  
  'RIGHT = 0
  UP = 1
  'LEFT = 2
  DOWN = 3

OBJ
  rgb : "WS2812B_RGB_LED_Driver"
  ' PST object for debugging
  pst : "Parallax Serial Terminal"

VAR
  long update_frame
  
  long curr_frame
  long end_game
  
  'long joystick_left
  long joystick_up
  'long joystick_right
  long joystick_down
  
    
'' Start the game
' Naming convention: Function takes in __ (double underscore) before variables that
' are just assigned to a variable in the VAR section.
' This is needed because no `this` exists in spin - so they have to be different names
PUB start(leds, __joystick_left, __joystick_up, __joystick_right, __joystick_down)
  ' Initialize variables
  update_frame := 0
  end_game := 0
  
  pst.start(9600)
  
  ' Set pin variables - Add more variables if more buttons etc. are needed
  'joystick_left := __joystick_left
  joystick_up := __joystick_up
  'joystick_right := __joystick_right
  joystick_down := __joystick_down
  
  ' Start RGB driver
  rgb.start(leds)
  
  ' Performs game setup
  setup_game
  
  ' Start the engine and wait just in case (probably don't need a full second)
  rgb.start_engine(FPS, @update_frame)
  waitcnt(clkfreq+cnt)

  ' Main game loop - NOTE this should stop on a condition eg `repeat until game_done` but
  ' don't do that here - this is a demo game after all. But, this loop is run once per frame.  
  repeat while end_game == 0 
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
  ' Let things stabilize or somethin
  waitcnt(clkfreq + cnt)
  
  ' Draw snake starting position
  ''rgb.set_pixel (12, 6, chartreuse)
  
 
  
  ' Draw the ground
  repeat x from 0 to 15
    rgb.set_pixel (x,15,blue)
  


'' Code to be run every frame
'' LEDs are not updated until this code is done - make sure it's fast!
PUB perform_frame_update | delta_X, delta_Y, old_dir, old_head, new_head
    
    'Set new direction to first valid found
    if (not ina[joystick_up])
      pst.str(string("Setting dir = RIGHT"))
      pst.str(string(13))
      dir := RIGHT
    elseif (not ina[joystick_down])
      pst.str(string("Setting dir = DOWN"))
      pst.str(string(13))
      dir := DOWN
       
    {
    pst.str(string("Turning on: ")) 
    pst.dec(snake_X[new_head]) 
    pst.str(string(", ")) 
    pst.dec(snake_Y[new_head]) 
    pst.str(string(13))
    
    pst.str(string("Turning off: ")) 
    pst.dec(snake_X[snake_start]) 
    pst.str(string(", ")) 
    pst.dec(snake_Y[snake_start]) 
    pst.str(string(13))
    
    pst.str(string("Time: "))
    pst.dec(CNT)
    pst.str(string(13))
    pst.str(string(13))
    }
    
    'rgb.set_pixel (snake_X[new_head], snake_Y[new_head], chartreuse)
  
''Copyright Matt(2/3) and Ethan(1/3)