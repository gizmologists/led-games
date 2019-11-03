CON          
  num_leds = 1024
 
  off  = 0
  blue = 50

OBJ
  rgb : "WS2812B_RGB_LED_Driver"
  ' PST object for debugging
  pst : "Parallax Serial Terminal"

VAR
  long update
  long btn
  long Button_Stack[10]
  
PUB start
  ' Start PST for debugging - if clockrate problems fixed, change baud 144000 -> 115200
  pst.start(115200)
  rgb.start(0, num_leds)
  btn := 0
  update := 0
  cognew(check_button(20, @btn), @Button_Stack)
  
  ' Give a basic starting pattern that goes through a fair few iterations
  rgb.set_pixel(5, 4, blue)
  rgb.set_pixel(6, 5, blue)
  rgb.set_pixel(5, 6, blue)
  rgb.set_pixel(5, 5, blue)
  rgb.set_pixel(4, 5, blue)
  rgb.set_pixel(5, 4, blue)

  ' Start the engine and wait just in case (probably don't need a full second)
  rgb.start_engine(2, @update)
  waitcnt(clkfreq+cnt)

  ' Main game loop - NOTE this should stop on a condition eg `repeat until game_done` but
  ' don't do that here - this is a demo game after all. But, this loop is run once per frame.
  repeat 
    if update > 0
      update_frame
      update := 0
      
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
PUB update_frame
  '1 to 30 covers whole grid, 10-20 doesn't but makes it faster
    pst.dec(btn)
    if btn <> 0
        if rgb.get_pixel (1,1)
            rgb.set_pixel (1,1,off)
        else
            rgb.set_pixel (1,1,blue)
    btn := 0
        
      
PUB check_button(pin, button_addr)
    DIRA[pin] := 0
    repeat 
        if INA[pin] <> 0
            long[button_addr] := 1    
        