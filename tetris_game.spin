CON      
  FPS = 1

  ' Variables needed to make checks/intensity better - can also use variables in rgb
  off  = 0
  blue = 30
  
  ' Direction constants
  RIGHT = 0
  UP = 1
  LEFT = 2
  DOWN = 3
  NONE = 4
  
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
  byte joystick_up, joystick_down, joystick_left, joystick_right
  ' Current orientation
  byte curr_orientation
  ' Current x/y values
  long curr_x_offset, curr_y_offset
  ' Piece type of current piece
  byte curr_piece_type
  ' 3 next pieces' types
  byte next_piece_1, next_piece_2, next_piece_3
  ' Buffers current direction and button presses
  byte direction, button_pressed
  ' Score and previously/currently displayed score
  long score, prev_score
  ' Stack for input buffering
  long input_stack[10]
  ' Random number seed
  long ran
  ' Colors that need intensity changes
  long orange, chartreuse, magenta, aquamarine, crimson
  
'' Start the game
' Naming convention: Function takes in __ (double underscore) before variables that
' are just assigned to a variable in the VAR section.
' This is needed because no `this` exists in spin - so they have to be different names
PUB start(leds, __button_green, __up, __down, __left, __right)
  pst.start(115200)
  set_colors
  ' Initialize variables
  update_frame := 0
  ' Set pin variables - Add more variables if more buttons etc. are needed
  button_green := __button_green
  joystick_up := __up
  joystick_down := __down
  joystick_left := __left
  joystick_right := __right
  
  ' Start RGB driver
  rgb.start(leds)
  
  ' Performs game setup
  setup_game
  
  ' Start the engine and wait just in case (probably don't need a full second)
  rgb.start_engine(FPS, @update_frame)
  waitcnt(clkfreq+cnt)
  ' Initialize random number seed - probably enough happened to be unique-ish
  ran := cnt

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
  ' Buffer inputs
  cognew(check_inputs(@direction, @button_pressed), @input_stack)

  ' Give a basic starting pattern that eventually loops
  ' Setup board
  ' Get 3 next shapes
  score := 1337
  prev_score := 12113
  curr_piece_type := J_PIECE'get_random_piece
  'next_piece_1 := get_random_piece
  'next_piece_2 := get_random_piece
  'next_piece_3 := get_random_piece
  curr_orientation := 0
  curr_x_offset := 7
  curr_y_offset := 17
  draw_current_piece(blue)
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
    
  draw_brand
  
  {rgb.set_pixel (General_L_X_3[0], General_L_Y_3[0], rgb.change_intensity (rgb#red,32))
  rgb.set_pixel (General_L_X_3[1], General_L_Y_3[1], rgb.change_intensity (rgb#red,32))
  rgb.set_pixel (General_L_X_3[2], General_L_Y_3[2], rgb.change_intensity (rgb#red,32))
  rgb.set_pixel (General_L_X_3[3], General_L_Y_3[3], rgb.change_intensity (rgb#red,32))}
  {rgb.set_pixel (0, 0, rgb#red)
  rgb.set_pixel (16, 0, rgb#red)
  rgb.set_pixel (0, 16, rgb#red)
  rgb.set_pixel (16, 16, rgb#red)}

PUB draw_brand
  'T
  rgb.set_pixel(0, 31, magenta)
  rgb.set_pixel(1, 31, magenta)
  rgb.set_pixel(2, 31, magenta)
  rgb.set_pixel(3, 31, magenta)
  rgb.set_pixel(4, 31, magenta)
  rgb.set_pixel(5, 31, magenta)
  rgb.set_pixel(6, 31, magenta)
  rgb.set_pixel(3, 30, magenta)
  rgb.set_pixel(3, 29, magenta)
  rgb.set_pixel(3, 28, magenta)
  rgb.set_pixel(3, 27, magenta)
  rgb.set_pixel(3, 26, magenta)
  rgb.set_pixel(3, 25, magenta)
  rgb.set_pixel(3, 24, magenta)
  rgb.set_pixel(3, 23, magenta)
  
  'E
  rgb.set_pixel(5, 21, aquamarine)
  rgb.set_pixel(6, 21, aquamarine)
  rgb.set_pixel(7, 21, aquamarine)
  rgb.set_pixel(8, 21, aquamarine)
  rgb.set_pixel(9, 21, aquamarine)
  rgb.set_pixel(5, 22, aquamarine)
  rgb.set_pixel(5, 23, aquamarine)
  rgb.set_pixel(5, 24, aquamarine)
  rgb.set_pixel(5, 25, aquamarine)
  rgb.set_pixel(5, 26, aquamarine)
  rgb.set_pixel(5, 27, aquamarine)
  rgb.set_pixel(5, 28, aquamarine)
  rgb.set_pixel(5, 29, aquamarine)
  rgb.set_pixel(6, 25, aquamarine)
  rgb.set_pixel(7, 25, aquamarine)
  rgb.set_pixel(6, 29, aquamarine)
  rgb.set_pixel(7, 29, aquamarine)
  rgb.set_pixel(8, 29, aquamarine)
  rgb.set_pixel(9, 29, aquamarine)
  'T
  rgb.set_pixel(4, 11, crimson)
  rgb.set_pixel(4, 12, crimson)
  rgb.set_pixel(4, 13, crimson)
  rgb.set_pixel(4, 14, crimson)
  rgb.set_pixel(4, 15, crimson)
  rgb.set_pixel(4, 16, crimson)
  rgb.set_pixel(4, 17, crimson)
  rgb.set_pixel(4, 18, crimson)
  rgb.set_pixel(1, 19, crimson)
  rgb.set_pixel(2, 19, crimson)
  rgb.set_pixel(3, 19, crimson)
  rgb.set_pixel(4, 19, crimson)
  rgb.set_pixel(5, 19, crimson)
  rgb.set_pixel(6, 19, crimson)
  rgb.set_pixel(7, 19, crimson)
  'R
  rgb.set_pixel(7, 12, chartreuse)
  rgb.set_pixel(8, 9, chartreuse)
  rgb.set_pixel(9, 9, chartreuse)
  rgb.set_pixel(8, 10, chartreuse)
  rgb.set_pixel(8, 11, chartreuse)
  rgb.set_pixel(8, 12, chartreuse)
  rgb.set_pixel(8, 13, chartreuse)
  rgb.set_pixel(9, 13, chartreuse)
  rgb.set_pixel(9, 14, chartreuse)
  rgb.set_pixel(9, 15, chartreuse)
  rgb.set_pixel(9, 16, chartreuse)
  rgb.set_pixel(8, 16, chartreuse)
  rgb.set_pixel(7, 16, chartreuse)
  rgb.set_pixel(6, 16, chartreuse)
  rgb.set_pixel(5, 16, chartreuse)
  rgb.set_pixel(5, 15, chartreuse)
  rgb.set_pixel(5, 14, chartreuse)
  rgb.set_pixel(5, 13, chartreuse)
  rgb.set_pixel(6, 13, chartreuse)
  rgb.set_pixel(7, 13, chartreuse)
  rgb.set_pixel(5, 12, chartreuse)
  rgb.set_pixel(5, 11, chartreuse)
  rgb.set_pixel(5, 10, chartreuse)
  'I
  rgb.set_pixel(1, 1, blue)
  rgb.set_pixel(2, 1, blue)
  rgb.set_pixel(3, 1, blue)
  rgb.set_pixel(4, 1, blue)
  rgb.set_pixel(5, 1, blue)
  rgb.set_pixel(6, 1, blue)
  rgb.set_pixel(7, 1, blue)
  rgb.set_pixel(4, 2, blue)
  rgb.set_pixel(4, 3, blue)
  rgb.set_pixel(4, 4, blue)
  rgb.set_pixel(4, 5, blue)
  rgb.set_pixel(4, 6, blue)
  rgb.set_pixel(4, 7, blue)
  rgb.set_pixel(4, 8, blue)
  rgb.set_pixel(4, 9, blue)
  rgb.set_pixel(1, 9, blue)
  rgb.set_pixel(2, 9, blue)
  rgb.set_pixel(3, 9, blue)
  rgb.set_pixel(5, 9, blue)
  rgb.set_pixel(6, 9, blue)
  rgb.set_pixel(7, 9, blue)
  'S
  rgb.set_pixel(5, 0, orange)
  rgb.set_pixel(6, 0, orange)
  rgb.set_pixel(7, 0, orange)
  rgb.set_pixel(8, 0, orange)
  rgb.set_pixel(9, 0, orange)
  rgb.set_pixel(9, 1, orange)
  rgb.set_pixel(9, 2, orange)
  rgb.set_pixel(9, 3, orange)
  rgb.set_pixel(9, 4, orange)
  rgb.set_pixel(8, 4, orange)
  rgb.set_pixel(7, 4, orange)
  rgb.set_pixel(6, 4, orange)
  rgb.set_pixel(5, 4, orange)
  rgb.set_pixel(5, 5, orange)
  rgb.set_pixel(5, 6, orange)
  rgb.set_pixel(5, 7, orange)
  rgb.set_pixel(5, 8, orange)
  rgb.set_pixel(6, 8, orange)
  rgb.set_pixel(7, 8, orange)
  rgb.set_pixel(8, 8, orange)
  rgb.set_pixel(9, 8, orange)




'' Code to be run every frame
'' LEDs are not updated until this code is done - make sure it's fast!
PUB perform_frame_update
  draw_current_piece(rgb#off)
  'if should_stop
    'spawn_next_piece
  if not should_stop
    curr_y_offset := curr_y_offset - 1
  draw_current_piece(blue)
  ' Rotate pressed event
  ' - Override joystick event if pressed (so return immediately after)
  ' Joystick event
  ' - If nothing moves, continue
  ' - If something moves, return here
  ' No event
  ' - Move down once every so many frames
  ' - Check if piece placed
  direction := NONE
  button_pressed := 0

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
  
PUB spawn_next_piece
  curr_piece_type := next_piece_1
  next_piece_1 := next_piece_2
  next_piece_2 := next_piece_3
  next_piece_3 := get_random_piece
  curr_x_offset := 5
  curr_y_offset := 17
 
PUB draw_current_piece(color)  
  display_piece(get_global_x, get_global_y, curr_piece_type, curr_orientation, color)
  'display_piece(12, 12, J_PIECE, 0)
  
' Reads from global score variable
' Updates the score with any changed numbers
PUB update_score | i, tmp_score, tmp_prev_score, curr_digit, prev_digit, x_pos
  tmp_score := score
  tmp_prev_score := prev_score
  repeat i from 0 to NUM_SCORE_DIGITS - 1
    curr_digit := tmp_score // 10
    prev_digit := tmp_prev_score // 10
    'pst.dec(curr_digit)
    'pst.dec(prev_digit)
    'pst.newline
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
    
PUB display_piece(x_pos, y_pos, piece, orientation, color) | i, x, y
  repeat i from 0 to 3
    x := get_piece_x(x_pos, piece, orientation, i)
    y := get_piece_y(y_pos, piece, orientation, i)
    pst.dec(x)
    pst.newline
    pst.dec(y)
    pst.newline
    pst.dec(color)
    pst.newline
    pst.newline

    rgb.set_pixel(x, y, color)
    'pst.newline
  'pst.newline
  'pst.newline

PUB check_inputs(direction_addr, button_pressed_addr)
    DIRA[joystick_left] := 0
    DIRA[joystick_right] := 0
    DIRA[joystick_up] := 0
    DIRA[joystick_down] := 0
    DIRA[button_green] := 0

    repeat 
      if INA[joystick_left] == 0
        byte[direction_addr] := LEFT 
      if INA[joystick_right] == 0
        byte[direction_addr] := RIGHT
      if INA[joystick_up] == 0
        byte[direction_addr] := UP
      if INA[joystick_down] == 0
        byte[direction_addr] := DOWN
      if INA[button_green] == 0
        byte[button_pressed_addr] := 1

PRI get_random_piece
  ' TODO: Get so random piece isn't already on board
  return ran? // 7           
  
PRI set_colors
  orange := rgb.change_intensity(229 << 8 + 114 << 16 + 0, 30)
  chartreuse := rgb.change_intensity(rgb#chartreuse, 30)
  magenta := rgb.change_intensity(rgb#magenta, 30)
  aquamarine := rgb.change_intensity(rgb#aquamarine, 30)
  crimson := rgb.change_intensity(rgb#crimson, 30)
  
  
  
PRI should_stop | i, at_bottom
  repeat i from 0 to 3
    if get_piece_y(get_global_y, curr_piece_type, curr_orientation, i) == 0
      return true
  return false
  
PRI get_global_x
  return curr_x_offset + BOARD_START_X + 1

PRI get_global_y
  return curr_y_offset + BOARD_START_Y
  
PRI get_piece_x(x_pos, piece, orientation, i)
  case(piece)
      O_PIECE:
        case(orientation)
          0:
            return x_pos + GENERAL_O_X_0[i]
          1:
            return x_pos + GENERAL_O_X_1[i]
          2:
            return x_pos + GENERAL_O_X_2[i]
          3:
            return x_pos + GENERAL_O_X_3[i]
      I_PIECE:
        case(orientation)
          0:
            return x_pos + GENERAL_I_X_0[i]
          1:
            return x_pos + GENERAL_I_X_1[i]
          2:
            return x_pos + GENERAL_I_X_2[i]
          3:
            return x_pos + GENERAL_I_X_3[i]
      S_PIECE:
        case(orientation)
          0:
            return x_pos + GENERAL_S_X_0[i]
          1:
            return x_pos + GENERAL_S_X_1[i]
          2:
            return x_pos + GENERAL_S_X_2[i]
          3:
            return x_pos + GENERAL_S_X_3[i]
      Z_PIECE:
        case(orientation)
          0:
            return x_pos + GENERAL_Z_X_0[i]
          1:
            return x_pos + GENERAL_Z_X_1[i]
          2:
            return x_pos + GENERAL_Z_X_2[i]
          3:
            return x_pos + GENERAL_Z_X_3[i]
      L_PIECE:
        case(orientation)
          0:
            return x_pos + GENERAL_L_X_0[i]
          1:
            return x_pos + GENERAL_L_X_1[i]
          2:
            return x_pos + GENERAL_L_X_2[i]
          3:
            return x_pos + GENERAL_L_X_3[i]
      J_PIECE:
        case(orientation)
          0:
            return x_pos + GENERAL_J_X_0[i]
          1:
            return x_pos + GENERAL_J_X_1[i]
          2:
            return x_pos + GENERAL_J_X_2[i]
          3:
            return x_pos + GENERAL_J_X_3[i]
      T_PIECE:
        case(orientation)
          0:
            return x_pos + GENERAL_T_X_0[i]
          1:
            return x_pos + GENERAL_T_X_1[i]
          2:
            return x_pos + GENERAL_T_X_2[i]
          3:
            return x_pos + GENERAL_T_X_3[i]
            
PRI get_piece_y(y_pos, piece, orientation, i)
  case(piece)
      O_PIECE:
        case(orientation)
          0:
            return y_pos + GENERAL_O_Y_0[i]
          1:
            return y_pos + GENERAL_O_Y_1[i]
          2:
            return y_pos + GENERAL_O_Y_2[i]
          3:
            return y_pos + GENERAL_O_Y_3[i]
      I_PIECE:
        case(orientation)
          0:
            return y_pos + GENERAL_I_Y_0[i]
          1:
            return y_pos + GENERAL_I_Y_1[i]
          2:
            return y_pos + GENERAL_I_Y_2[i]
          3:
            return y_pos + GENERAL_I_Y_3[i]
      S_PIECE:
        case(orientation)
          0:
            return y_pos + GENERAL_S_Y_0[i]
          1:
            return y_pos + GENERAL_S_Y_1[i]
          2:
            return y_pos + GENERAL_S_Y_2[i]
          3:
            return y_pos + GENERAL_S_Y_3[i]
      Z_PIECE:
        case(orientation)
          0:
            return y_pos + GENERAL_Z_Y_0[i]
          1:
            return y_pos + GENERAL_Z_Y_1[i]
          2:
            return y_pos + GENERAL_Z_Y_2[i]
          3:
            return y_pos + GENERAL_Z_Y_3[i]
      L_PIECE:
        case(orientation)
          0:
            return y_pos + GENERAL_L_Y_0[i]
          1:
            return y_pos + GENERAL_L_Y_1[i]
          2:
            return y_pos + GENERAL_L_Y_2[i]
          3:
            return y_pos + GENERAL_L_Y_3[i]
      J_PIECE:
        case(orientation)
          0:
            return y_pos + GENERAL_J_Y_0[i]
          1:
            return y_pos + GENERAL_J_Y_1[i]
          2:
            return y_pos + GENERAL_J_Y_2[i]
          3:
            return y_pos + GENERAL_J_Y_3[i]
      T_PIECE:
        case(orientation)
          0:
            return y_pos + GENERAL_T_Y_0[i]
          1:
            return y_pos + GENERAL_T_Y_1[i]
          2:
            return y_pos + GENERAL_T_Y_2[i]
          3:
            return y_pos + GENERAL_T_Y_3[i]
        

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