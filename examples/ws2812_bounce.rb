#
# Walk a single pixel along the length of a WS2812 strip and back,
# changing color each time it returns to position 0.
#
require 'denko/piboard'

RED    = [255, 0, 0]
GREEN  = [0, 255, 0]
BLUE   = [0, 0, 255]
WHITE  = [255, 255, 255]
COLORS = [RED, GREEN, BLUE, WHITE]

WS2812_PIN = 231
PIXELS = 8

# Move along the strip and back, one pixel at a time.
positions = (0..PIXELS-1).to_a + (1..PIXELS-2).to_a.reverse

# Create a board map for your SBC, so Denko can map hardware SPI pins to GPIOs.
board_map = File.join(File.dirname(__FILE__), "board_maps/orange_pi_zero_2w.yml")
board = Denko::PiBoard.new(board_map)
strip = Denko::LED::WS2812.new(board: board, pin: WS2812_PIN, length: PIXELS)

loop do
  COLORS.each do |color|
    positions.each do |index|
      strip.clear
      strip[index] = color
      strip.show
      sleep 0.05
    end
  end
end
