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
  
PUB start(leds, __button_green)
  ' Initialize variables
  update_frame := 0
  button_green := __button_green
  ' Start PST for debugging - if clockrate problems fixed, change baud 144000 -> 115200
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
  rgb.set_pixel(6, 5, blue)
  rgb.set_pixel(5, 6, blue)
  rgb.set_pixel(5, 5, blue)
  rgb.set_pixel(4, 5, blue)
  rgb.set_pixel(5, 4, blue)
  
'' Code to be run every frame
'' LEDs are not updated until this code is done - make sure it's fast!
PUB perform_frame_update | x, y, x_offset, y_offset, num_neighbors
  '1 to 30 covers whole grid, 10-20 doesn't but makes it faster
  repeat x from 1 to 10
    repeat y from 1 to 10
      num_neighbors := 0
      repeat x_offset from -1 to 1
        repeat y_offset from -1 to 1
          if rgb.get_previous_pixel(x + x_offset, y + y_offset) <> off
            num_neighbors++
            
      if num_neighbors == 3 or (num_neighbors == 4 and rgb.get_previous_pixel(x, y) <> off)
        rgb.set_pixel(x, y, blue)
      else
        rgb.set_pixel(x, y, off)