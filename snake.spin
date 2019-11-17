CON      
  FPS = 5

  off  = rgb#off
  blue = 32
  red = 32<<16
  chartreuse = 32<<16+16<<8
  dark_green = 32<<16
  RIGHT = 0
  UP = 1
  LEFT = 2
  DOWN = 3

OBJ
  rgb : "WS2812B_RGB_LED_Driver"
  ' PST object for debugging
  pst : "Parallax Serial Terminal"

VAR
  long update_frame
  
  long curr_frame
  long end_game
  
  long joystick_left
  long joystick_up
  long joystick_right
  long joystick_down
  
  long snake_X[900]
  long snake_Y[900]
  long snake_start
  long snake_len
  
  long dir ' LEFT = 0, RIGHT = 2, UP = 1, DOWN = 3 
  
'' Start the game
' Naming convention: Function takes in __ (double underscore) before variables that
' are just assigned to a variable in the VAR section.
' This is needed because no `this` exists in spin - so they have to be different names
PUB start(leds, __joystick_left, __joystick_up, __joystick_right, __joystick_down)
  ' Initialize variables
  update_frame := 0
  end_game := 0
  snake_start := 0
  snake_len := 1
  dir := DOWN
  
  pst.start(9600)
  
  ' Set pin variables - Add more variables if more buttons etc. are needed
  joystick_left := __joystick_left
  joystick_up := __joystick_up
  joystick_right := __joystick_right
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
  rgb.set_pixel (8, 2, chartreuse)
  'rgb.set_pixel (8, 3, chartreuse)
  'rgb.set_pixel (8, 4, chartreuse)
  'rgb.set_pixel (8, 5, chartreuse)
  'rgb.set_pixel (8, 6, chartreuse)
  'rgb.set_pixel (8, 7, chartreuse)
  
  ' Setup position arrays
  snake_X[0] := 8
  snake_Y[0] := 2
  
  snake_X[1] := 8
  snake_Y[1] := 3
  
  snake_X[2] := 8
  snake_Y[2] := 4
  
  snake_X[3] := 8
  snake_Y[3] := 5
  
  snake_X[4] := 8
  snake_Y[4] := 6
  
  snake_X[5] := 8
  snake_Y[5] := 7
  
  ' Draw the border
  repeat x from 0 to 15'31
    rgb.set_pixel (x,0,blue)
    rgb.set_pixel (x,15,blue)'(x,31,blue)
  repeat y from 1 to 14
    rgb.set_pixel (0,y,blue)
    rgb.set_pixel (15,y,blue)'(31,y,blue)
  
'' Code to be run every frame
'' LEDs are not updated until this code is done - make sure it's fast!
PUB perform_frame_update | delta_X, delta_Y, old_dir, old_head, new_head
    delta_X := 0
    delta_Y := 0
    old_dir := dir
    
    'Set new direction to first valid found
    'If no valid new direction, don't change
    if (not ina[joystick_left]) and (old_dir <> RIGHT)
      pst.str(string("Setting dir = LEFT"))
      pst.str(string(13))
      dir := LEFT
    elseif (not ina[joystick_up]) and (old_dir <> DOWN)
      pst.str(string("Setting dir = UP"))
      pst.str(string(13))
      dir := UP
    elseif (not ina[joystick_right]) and (old_dir <> LEFT)
      pst.str(string("Setting dir = RIGHT"))
      pst.str(string(13))
      dir := RIGHT
    elseif (not ina[joystick_down]) and (old_dir <> UP)
      pst.str(string("Setting dir = DOWN"))
      pst.str(string(13))
      dir := DOWN
    
    if dir == RIGHT
      delta_X := 1
    elseif dir == LEFT
      delta_X := -1
    elseif dir == UP
      delta_Y := -1
    elseif dir == DOWN
      delta_Y := 1
    
    old_head := snake_start + snake_len - 1
    new_head := snake_start + snake_len
    
    snake_X[new_head] := snake_X[old_head] + delta_X
    snake_Y[new_head] := snake_Y[old_head] + delta_Y
       
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
    
    if rgb.get_pixel(snake_X[new_head], snake_Y[new_head]) <> off
        pst.str(string("   OUCH!"))
        waitcnt(clkfreq+cnt)
        stop
            
    rgb.set_pixel (snake_X[new_head], snake_Y[new_head], chartreuse)
    rgb.set_pixel (snake_X[snake_start],snake_Y[snake_start], off)
    
    snake_start++
  
''Copyright Matt