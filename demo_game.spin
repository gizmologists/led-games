CON     
  _xinfreq=6_250_000
  _clkmode=xtal1+pll16x            
  num_leds = 1024
 
  off  = 0
  blue = 50

OBJ
  rgb : "WS2812B_RGB_LED_Driver"
  pst : "Parallax Serial Terminal"

VAR
  long update
  
PUB start
  '
  'pst.start(144000)
  rgb.start(0, num_leds)
  update := 0
  rgb.set_pixel(16, 16, blue)
  rgb.set_pixel(17, 16, blue)
  rgb.set_pixel(16, 15, blue)
  rgb.set_pixel(15, 15, blue)
  rgb.set_pixel(16, 14, blue)

  rgb.start_engine(2, @update)
  waitcnt(clkfreq+cnt)

  repeat 
    if update > 0
      update_frame
      update := 0
 
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
  repeat x from 10 to 20
    repeat y from 10 to 20
      num_neighbors := 0
      repeat x_offset from -1 to 1
        repeat y_offset from -1 to 1
          if rgb.get_previous_pixel(x + x_offset, y + y_offset) <> off
            num_neighbors++
            
      if num_neighbors == 3 or (num_neighbors == 4 and rgb.get_previous_pixel(x, y) <> off)
        rgb.set_pixel(x, y, blue)
      else
        rgb.set_pixel(x, y, off)
      
          
        