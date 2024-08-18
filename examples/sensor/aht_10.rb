#
# Example using AHT10 sensor over I2C, for temperature and humidity.
#
require 'denko/piboard'

board = Denko::PiBoard.new i2c_devices: [{index: 3, sda: 264}]
bus = Denko::I2C::Bus.new(board: board, pin: 264)

sensor = Denko::Sensor::AHT10.new(bus: bus) # address: 0x38 default

# Get the shared #print_tph_reading method to print readings neatly.
require_relative 'neat_tph_readings'

# Poll it and print readings.
sensor.poll(5) do |reading|
  print_tph_reading(reading)
end

sleep
