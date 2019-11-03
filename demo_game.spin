CON          
  num_leds = 1024
 
  off  = 0
  blue = 50

OBJ
  rgb : "WS2812B_RGB_LED_Driver"
  ' PST object for debugging
  'pst : "Parallax Serial Terminal"

VAR
  long update
  
PUB start
  ' Start PST for debugging - if clockrate problems fixed, change baud 144000 -> 115200
  'pst.start(144000)
  rgb.start(0, num_leds)
  update := 0
  
  ' Give a basic starting pattern that goes through a fair few iterations
  rgb.set_pixel(0, 0, blue)
  rgb.set_pixel(15, 0, blue)
  rgb.set_pixel(16, 0, blue)
  {
  rgb.set_pixel(5, 5, blue)
  rgb.set_pixel(4, 5, blue)
  rgb.set_pixel(5, 4, blue)
  }

  ' Start the engine and wait just in case (probably don't need a full second)
  rgb.start_engine(2, @update)
  waitcnt(clkfreq+cnt)

  ' Main game loop - NOTE this should stop on a condition eg `repeat until game_done` but
  ' don't do that here - this is a demo game after all. But, this loop is run once per frame.
  repeat 
    update := 1
    {if update > 0
      update_frame
      update := 0}
      
  ' Should call stop after game done, so it's put here, but never reached
  stop
 
'' Stops the game
PUB stop
  rgb.all_off
  waitcnt(clkfreq/2+cnt)
  rgb.stop_engine
  rgb.stop
  
'' Code to be run every frame
'' LEDs are not updated until this code is done - make sure it's fast!
PUB update_frame | x, y, x_offset, y_offset, num_neighbors
  '1 to 30 covers whole grid, 10-20 doesn't but makes it faster
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
      
          
        