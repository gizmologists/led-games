CON      
  FPS = 2

  off  = rgb#off
  blue = 64
  red = rgb#red
  chartreuse = 63<<16+31<<8
  dark_green = 64<<16
  RIGHT = 0
  UP = 1
  LEFT = 2
  DOWN = 3

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
  long direction ' LEFT = 0, RIGHT = 2, UP = 1, DOWN = 3 
  
'' Start the game
' Naming convention: Function takes in __ (double underscore) before variables that
' are just assigned to a variable in the VAR section.
' This is needed because no `this` exists in spin - so they have to be different names
PUB start(leds, __joystick_left, __joystick_up, __joystick_right, __joystick_down)
  ' Initialize variables
  update_frame := 0
  snake_start := 0
  snake_len := 3
  direction := 2
  
  ' Set pin variables - Add more variables if more buttons etc. are needed
  
  
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
  ' Draw snake starting position
  rgb.set_pixel (5, 5, chartreuse)
  rgb.set_pixel (6, 5, chartreuse)
  rgb.set_pixel (7, 5, chartreuse)
  
  ' Setup position arrays
  snake_X[0] := 5
  snake_Y[0] := 5
  
  snake_X[1] := 6
  snake_Y[1] := 5
  
  snake_X[2] := 7
  snake_Y[2] := 5
  
  ' Draw the border
  repeat x from 0 to 15'31
    rgb.set_pixel (x,0,blue)
    rgb.set_pixel (x,15,blue)'(x,31,blue)
  repeat y from 1 to 14
    rgb.set_pixel (0,y,blue)
    rgb.set_pixel (15,y,blue)'(31,y,blue)
  
'' Code to be run every frame
'' LEDs are not updated until this code is done - make sure it's fast!
PUB perform_frame_update | deltaX, deltaY
    deltaX = 0
    deltaY = 0
    
    if 
    
    if direction == RIGHT
        deltaX := 1
    if direction == LEFT
        deltaX := -1
    if direction == UP
        deltaY := 1
    if direction == DOWN
        deltaY := -1
    
    snake_X[snake_start + snake_len] = snake_X[snake_start + snake_len - 1] + deltaX
    snake_Y[snake_start + snake_len] = snake_Y[snake_start + snake_len - 1] + deltaY
    
    rgb.set_pixel (snake_X[snake_start],snake_Y[snake_start],off)
    
    snake_start++
  
  ''Copyright Matt