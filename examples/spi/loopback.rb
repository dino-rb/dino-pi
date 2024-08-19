require 'denko'
require 'denko/piboard'

board = Denko::PiBoard.new spi_devices: [{cs0: 229, index: 1}]
bus = Denko::SPI::Bus.new(board: board)

TEST_DATA = [0, 1, 2, 3, 4, 5, 6, 7]

# Create a simple test component class.
class SPITester
  include Denko::SPI::Peripheral
end
spi_tester = SPITester.new(bus: bus, pin: 229)
spi_tester.add_callback do |rx_bytes|
  # If MOSI and MISO are connected this should match TEST_DATA.
  # If not, should be 8 bytes of 255.
  puts "RX bytes: #{rx_bytes.split(",").map(&:to_i)}"
end

# Send the test data.
puts "TX bytes: #{TEST_DATA.inspect}"
spi_tester.spi_transfer(write: TEST_DATA, read: 8)

# Wait for read callback to run.
sleep 1
board.finish_write
