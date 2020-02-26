CON      
  FPS = 5

  off  = rgb#off
  blue = 32
  red = rgb#red
  chartreuse = 32<<16+16<<8
  dark_green = 32<<16
  
  LEFT = -1
  RIGHT = 1
  STALL = 0
  
  paddle_length = 5
  paddle_height = 5
  

OBJ
  rgb : "WS2812B_RGB_LED_Driver"
  ' PST object for debugging
  pst : "Parallax Serial Terminal"

VAR
  long update_frame
  
  long curr_frame
  long end_game
  
  long joystick_left
  long joystick_right
  
  long joy_cog
  long joy_stack[10]
  long joy_dir
  
  long paddle_pos
  
  
'' Start the game
' Naming convention: Function takes in __ (double underscore) before variables that
' are just assigned to a variable in the VAR section.
' This is needed because no `this` exists in spin - so they have to be different names
PUB start(leds, __joystick_left, __joystick_right)
  ' Initialize variables
  update_frame := 0
  end_game := 0
  paddle_pos := 1
  
  'pst.start(9600)
  
  ' Set pin variables - Add more variables if more buttons etc. are needed
  joystick_left := __joystick_left
  joystick_right := __joystick_right
  
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
  cogstop(joy_cog)
  rgb.all_off
  waitcnt(clkfreq/2+cnt)
  rgb.stop_engine
  rgb.stop
  
PUB setup_game | x, y
  ' Let things stabilize or somethin
  waitcnt(clkfreq + cnt)
  
  ' Draw the border
  repeat x from 0 to 31
    rgb.set_pixel (x,0,blue)
    rgb.set_pixel (x,31,blue)
  repeat y from 1 to 20
    rgb.set_pixel (0,y,blue)
    rgb.set_pixel (31,y,blue)
    
  ' Draw paddle
  repeat x from 1 to paddle_length
    rgb.set_pixel (x, paddle_height, chartreuse)
  
  ' Start joystick_listener
  joy_cog := cognew(listen(@joy_dir), @joy_stack) 
  
PUB listen(dir_addr)
    repeat
        if not ina[joystick_left]
            long[dir_addr] := LEFT
        if not ina[joystick_right]
            long[dir_addr] := RIGHT
        else
            long[dir_addr] := STALL

'' Code to be run every frame
'' LEDs are not updated until this code is done - make sure it's fast!
PUB perform_frame_update | i, delta_X, new_dir

    delta_X := joy_dir
    
    if delta_X == LEFT and (paddle_pos <> 1)
        rgb.set_pixel(paddle_pos+paddle_length-1, paddle_height, rgb#off)
        rgb.set_pixel(paddle_pos-1, paddle_height, chartreuse)
    elseif delta_X == RIGHT and (paddle_pos+paddle_length-1 <> 31)
        rgb.set_pixel(paddle_pos, paddle_height, rgb#off)
        rgb.set_pixel(paddle_pos+paddle_length, paddle_height, chartreuse)
  

''Copyright Matt