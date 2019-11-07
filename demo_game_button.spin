CON          
  num_leds = 1024
 
  off  = 0
  blue = 50
  FPS = 2
''  BUTTON_GREEN = 21

OBJ
  rgb : "WS2812B_RGB_LED_Driver"
  ' PST object for debugging
  pst : "Parallax Serial Terminal"

VAR
  long update_frame
  long button_green
  long btn
  long Button_Stack[10]
  
PUB start(leds, __button_green)
  pst.start(115200)
  pst.str(string("Pls work"))
  ' Initialize variables
  update_frame := 0
  ' Set pin variables - Add more variables if more buttons etc. are needed
  button_green := __button_green
  
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
  cognew(check_button(button_green, @btn), @Button_Stack)
  rgb.set_pixel(6, 5, blue)
  rgb.set_pixel(5, 6, blue)
  rgb.set_pixel(5, 5, blue)
  rgb.set_pixel(4, 5, blue)
  rgb.set_pixel(5, 4, blue)
  
'' Code to be run every frame
'' LEDs are not updated until this code is done - make sure it's fast!
PUB perform_frame_update
  '1 to 30 covers whole grid, 10-20 doesn't but makes it faster
    pst.dec(btn)
    if btn <> 0
        if rgb.get_pixel (1,1)
            rgb.set_pixel (1,1,off)
        else
            rgb.set_pixel (1,1,blue)
    btn := 1
        
      
PUB check_button(pin, button_addr)
    DIRA[pin] := 0
    repeat 
        if INA[pin] == 0
            long[button_addr] := 0   
        