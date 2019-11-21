CON      
  FPS = 2

  ' Variables needed to make checks/intensity better - can also use variables in rgb
  off  = 0
  blue = 50
  
  ' Each piece's number
  O_PIECE = 0
  I_PIECE = 1
  S_PIECE = 2
  Z_PIECE = 3
  L_PIECE = 4
  J_PIECE = 5
  T_PIECE = 6

  ' Orientations of all of the pieces - Dunno why you'd use these variables since they're
  ' just numbers... but you do you
  ORIENTATION_0 = 0
  ORIENTATION_1 = 1
  ORIENTATION_2 = 2
  ORIENTATION_3 = 3

OBJ
  rgb : "WS2812B_RGB_LED_Driver"
  ' PST object for debugging
  'pst : "Parallax Serial Terminal"

VAR
  long update_frame
  ' Pins
  byte button_green
  byte up, down, left, right
  ' Current orientation
  byte curr_orientation
  ' Current x/y values
  byte curr_x_offset, curr_y_offset
  ' Piece type of current piece
  byte curr_piece_type
  ' 3 next pieces' types
  byte next_piece_1, next_piece_2, next_piece_3
  
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
  rgb.set_pixel (General_L_X_3[0], General_L_Y_3[0], rgb.change_intensity (rgb#red,32))
  rgb.set_pixel (General_L_X_3[1], General_L_Y_3[1], rgb.change_intensity (rgb#red,32))
  rgb.set_pixel (General_L_X_3[2], General_L_Y_3[2], rgb.change_intensity (rgb#red,32))
  rgb.set_pixel (General_L_X_3[3], General_L_Y_3[3], rgb.change_intensity (rgb#red,32))
  rgb.set_pixel (8, 0, rgb#red)

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

DAT
General_O_X_0 byte  0, 0, 1, 1
General_O_Y_0 byte  0, 1, 0, 1
General_O_X_1 byte  0, 0, 1, 1
General_O_Y_1 byte  0, 1, 0, 1
General_O_X_2 byte  0, 0, 1, 1
General_O_Y_2 byte  0, 1, 0, 1
General_O_X_3 byte  0, 0, 1, 1
General_O_Y_3 byte  0, 1, 0, 1

General_I_X_0 byte  0, 1, 2, 3
General_I_Y_0 byte  2, 2, 2, 2
General_I_X_1 byte  2, 2, 2, 2
General_I_Y_1 byte  0, 1, 2, 3
General_I_X_2 byte  0, 1, 2, 3
General_I_Y_2 byte  2, 2, 2, 2
General_I_X_3 byte  2, 2, 2, 2
General_I_Y_3 byte  0, 1, 2, 3

General_S_X_0 byte  0, 1, 1, 2
General_S_Y_0 byte  0, 0, 1, 1
General_S_X_1 byte  2, 2, 1, 1
General_S_Y_1 byte  0, 1, 1, 2
General_S_X_2 byte  0, 1, 1, 2
General_S_Y_2 byte  0, 0, 1, 1
General_S_X_3 byte  2, 2, 1, 1
General_S_Y_3 byte  0, 1, 1, 2

General_Z_X_0 byte  0, 1, 1, 2
General_Z_Y_0 byte  1, 1, 0, 0
General_Z_X_1 byte  1, 1, 2, 2
General_Z_Y_1 byte  0, 1, 1, 2
General_Z_X_2 byte  0, 1, 1, 2
General_Z_Y_2 byte  1, 1, 0, 0
General_Z_X_3 byte  1, 1, 2, 2
General_Z_Y_3 byte  0, 1, 1, 2

General_L_X_0 byte 0, 0, 1, 2
General_L_Y_0 byte 0, 1, 1, 1
General_L_X_1 byte 1, 1, 1, 2
General_L_Y_1 byte 0, 1, 2, 0
General_L_X_2 byte 0, 1, 2, 2
General_L_Y_2 byte 1, 1, 1, 2
General_L_X_3 byte 0, 1, 1, 1
General_L_Y_3 byte 2, 0, 1, 2

General_J_X_0 byte 0, 1, 2, 2
General_J_Y_0 byte 1, 1, 0, 1
General_J_X_1 byte 1, 1, 1, 2
General_J_Y_1 byte 0, 1, 2, 2
General_J_X_2 byte 0, 0, 1, 2
General_J_Y_2 byte 1, 2, 1, 1
General_J_X_3 byte 0, 1, 1, 1
General_J_Y_3 byte 0, 0, 1, 2

General_T_X_0 byte 0, 1, 1, 2
General_T_Y_0 byte 1, 0, 1, 1
General_T_X_1 byte 1, 1, 1, 2
General_T_Y_1 byte 0, 1, 2, 1
General_T_X_2 byte 0, 1, 1, 2
General_T_Y_2 byte 1, 1, 2, 1
General_T_X_3 byte 0, 1, 1, 1
General_T_Y_3 byte 1, 0, 1, 2