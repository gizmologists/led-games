CON      
  FPS = 2

  ' Variables needed to make checks/intensity better - can also use variables in rgb
  off  = 0
  blue = 30
  
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
  
  ' UI constants
  ' Board is where actual game of Tetris is played
  BOARD_START_X = 10
  BOARD_END_X = 21
  
  BOARD_START_Y = 0
  BOARD_END_LEFT_Y = 32
  BOARD_END_RIGHT_Y = 20
  
  TOP_BORDER_START_X = 10
  TOP_BORDER_END_X = 32
  TOP_BORDER_Y = 20
  
  ' Score positions
  NUM_SCORE_DIGITS = 5
  SCORE_Y = 23

  ONES_X = 28
  TENS_X = 24
  HUNDREDS_X = 20
  THOUSANDS_X = 16
  TEN_THOUSANDS_X = 12
  

OBJ
  rgb : "WS2812B_RGB_LED_Driver"
  ' PST object for debugging
  pst : "Parallax Serial Terminal"

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
  ' Score and previously/currently displayed score
  long score, prev_score
  
'' Start the game
' Naming convention: Function takes in __ (double underscore) before variables that
' are just assigned to a variable in the VAR section.
' This is needed because no `this` exists in spin - so they have to be different names
PUB start(leds, __button_green, __up, __down, __left, __right)
  pst.start(115200)
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
  
PUB setup_game | x, y, length, i
  ' Give a basic starting pattern that eventually loops
  ' Setup board
  ' Get 3 next shapes
  score := 1337
  prev_score := 12113
  update_score
  
  ' Left game border
  repeat y from BOARD_START_Y to BOARD_END_LEFT_Y
    rgb.set_pixel (BOARD_START_X, y, blue)
  ' Right game border
  repeat y from BOARD_START_Y to BOARD_END_RIGHT_Y
    rgb.set_pixel (BOARD_END_X, y, blue)
  ' Top game border
  repeat x from TOP_BORDER_START_X to TOP_BORDER_END_X
    rgb.set_pixel (x, TOP_BORDER_Y, blue)
  
  {rgb.set_pixel (General_L_X_3[0], General_L_Y_3[0], rgb.change_intensity (rgb#red,32))
  rgb.set_pixel (General_L_X_3[1], General_L_Y_3[1], rgb.change_intensity (rgb#red,32))
  rgb.set_pixel (General_L_X_3[2], General_L_Y_3[2], rgb.change_intensity (rgb#red,32))
  rgb.set_pixel (General_L_X_3[3], General_L_Y_3[3], rgb.change_intensity (rgb#red,32))}
  {rgb.set_pixel (0, 0, rgb#red)
  rgb.set_pixel (16, 0, rgb#red)
  rgb.set_pixel (0, 16, rgb#red)
  rgb.set_pixel (16, 16, rgb#red)}


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
  
' Reads from global score variable
' Updates the score with any changed numbers
PUB update_score | i, tmp_score, tmp_prev_score, curr_digit, prev_digit, x_pos
  tmp_score := score
  tmp_prev_score := prev_score
  repeat i from 0 to NUM_SCORE_DIGITS - 1
    curr_digit := tmp_score // 10
    prev_digit := tmp_prev_score // 10
    pst.dec(curr_digit)
    pst.dec(prev_digit)
    pst.newline
    if curr_digit <> prev_digit
      ' First iteration through loop is ones, second tens, etc.
      ' This just looks up the starting X position 
      x_pos := lookupz(i: ONES_X, TENS_X, HUNDREDS_X, THOUSANDS_X, TEN_THOUSANDS_X)
      display_num(x_pos, SCORE_Y, curr_digit)
    tmp_score /= 10
    tmp_prev_score /= 10
    
     
' Displays num in position pos
' pos: 0 is ones place, 1 is tens place, etc.
PUB display_num(x_pos, y_pos, num) | length, x_arr, y_arr, i, x, y
  length := lookupz(num: 16, 10, 14, 12, 12, 13, 15, 10, 17, 13)
  repeat i from 0 to (length - 1)
    case(num)
      0: 
        x := x_pos + Zero_X[i]
        y := y_pos + Zero_Y[i]
      1: 
        x := x_pos + One_X[i]
        y := y_pos + One_Y[i]
      2: 
        x := x_pos + Two_X[i]
        y := y_pos + Two_Y[i]

      3: 
        x := x_pos + Three_X[i]
        y := y_pos + Three_Y[i]

      4: 
        x := x_pos + Four_X[i]
        y := y_pos + Four_Y[i]

      5: 
        x := x_pos + Five_X[i]
        y := y_pos + Five_Y[i]

      6: 
        x := x_pos + Six_X[i]
        y := y_pos + Six_Y[i]

      7: 
        x := x_pos + Seven_X[i]
        y := y_pos + Seven_Y[i]

      8: 
        x := x_pos + Eight_X[i]
        y := y_pos + Eight_Y[i]

      9: 
        x := x_pos + Nine_X[i]
        y := y_pos + Nine_Y[i]


    rgb.set_pixel(x, y, blue)

DAT
' Pieces
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

' Numbers offsets
Zero_X byte 0, 1, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 2, 0, 1, 2
Zero_Y byte 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 6

One_X byte 0, 1, 2, 1, 1, 1, 1, 1, 0, 1
One_Y byte 0, 0, 0, 1, 2, 3, 4, 5, 6, 6

Two_X byte 0, 1, 2, 0, 0, 0, 1, 2, 2, 0, 2, 0, 1, 2
Two_Y byte 0, 0, 0, 1, 2, 3, 3, 3, 4, 5, 5, 6, 6, 6

Three_X byte 0, 1, 2, 2, 2, 1, 2, 2, 2, 0, 1, 2
Three_Y byte 0, 0, 0, 1, 2, 3, 3, 4, 5, 6, 6, 6

Four_X byte 2, 2, 2, 0, 1, 2, 0, 2, 0, 2, 0, 2
Four_Y byte 0, 1, 2, 3, 3, 3, 4, 4, 5, 5, 6, 6

Five_X byte 0, 1, 2, 2, 2, 0, 1, 2, 0, 0, 0, 1, 2
Five_Y byte 0, 0, 0, 1, 2, 3, 3, 3, 4, 5, 6, 6, 6

Six_X byte 0, 1, 2, 0, 2, 0, 2, 0, 1, 2, 0, 0, 0, 1, 2
Six_Y byte 0, 0, 0, 1, 1, 2, 2, 3, 3, 3, 4, 5, 6, 6, 6

Seven_X byte 2, 2, 2, 2, 2, 0, 2, 0, 1, 2
Seven_Y byte 0, 1, 2, 3, 4, 5, 5, 6, 6, 6

Eight_X byte 0, 1, 2, 0, 2, 0, 2, 0, 1, 2, 0, 2, 0, 2, 0, 1, 2
Eight_Y byte 0, 0, 0, 1, 1, 2, 2, 3, 3, 3, 4, 4, 5, 5, 6, 6, 6

Nine_X byte 2, 2, 2, 0, 1, 2, 0, 2, 0, 2, 0, 1, 2
Nine_Y byte 0, 1, 2, 3, 3, 3, 4, 4, 5, 5, 6, 6, 6