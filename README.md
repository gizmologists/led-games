# led-games

LED games for the Gizmologist's game table.

# Current Flow

Propeller chip
--------------

### Game Runner
  - `main`
    - Selects game to run
    - Talks to Arduino through Serial

### Game
  - `start`
    - Starts the game and engine to be displayed on screen
  - `stop`
    - Stops the game and goes back to selection screen etc.

### Game Engine
  - `set_pixel(x, y, rgb)`
    - Sets pixel at (x, y) to the rgb value
    - Bottom left is (0, 0)
    - Does not update the screen
  - `get_pixel(x, y)`
    - Gets the pixel at (x, y)
  - `start_engine`
    - Starts the framerate cog that updates the screen
  - `stop_engine`
    - Stops the framerate cog
    - Zeroes out the LEDs (or display some end screen?)
  - `PRI update_frame`
    - Updates the entire screen's LEDs

### Links
 - Spin reference: https://www.parallax.com/sites/default/files/downloads/P8X32A-Web-PropellerManual-v1.2.pdf
 - LED Datasheet: https://cdn-shop.adafruit.com/datasheets/WS2812B.pdf
