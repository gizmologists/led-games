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
  long up, down, left, right
  
'' Start the game
' Naming convention: Function takes in __ (double underscore) before variables that
' are just assigned to a variable in the VAR section.
' This is needed because no `this` exists in spin - so they have to be different names
PUB start(leds, __button_green, __up, __down, __left, __right)
  ' Initialize variables
  update_frame := 0
  ' Set pin variables - Add more variables if more buttons etc. are needed
  button_green := __button_green
  up := __up
  down := __down
  left := __left
  right := __right
  
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
  ' Give a basic starting pattern that eventually loops
  ' Setup board
  ' Get 3 next shapes
  
'' Code to be run every frame
'' LEDs are not updated until this code is done - make sure it's fast!
PUB perform_frame_update
  ' Rotate pressed event
  ' - Override joystick event if pressed (so return immediately after)
  ' Joystick event
  ' - If nothing moves, continue
  ' - If something moves, return here
  ' No event
  ' - Move down once every so many frames
  ' - Check if piece placed

' Handles button press for rotation
PUB rotation_event | i
  i := 0

' Handles the joystick being pressed
PUB joystick_event | i
  i := 0
  
' Handles the piece being placed on the board
PUB handle_placement | i
  i := 0
  
PUB handle_line_clear | i
  i := 0
