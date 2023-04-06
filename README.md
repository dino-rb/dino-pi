# dino-piboard 0.13.0

This is an add-on to the [`dino`](https://github.com/austinbv/dino) gem. It adds support for the GPIO interface on Raspberry Pi single board computers. Unlike the main gem, which connects Ruby on a computer to an external microcontroller, this requires only a Pi.

`Dino::PiBoard` gives access to the Pi's own GPIO, and is a drop-in replacement for `Dino::Board`, which would represent an external microcontroller.

**Note:** This is not for the Raspberry Pi Pico (W) / RPP2040. That microcontroller is covered by the main gem.

## Installation
**Note:** This gem is very new. It WILL NOT work with the version of `dino` (0.11.3) currently available from RubyGems. Before installing `dino-piboard`, make sure to install the latest `dino` version (future 0.13.0) from the master branch.

**Note:** Add `sudo` before all `gem install` and `gem uninstall` if using the system Ruby on the Raspberry Pi. Rubies installed with `rbenv` won't require it.

Install dino from source:
```shell
gem uninstall dino
git clone https://github.com/austinbv/dino.git
cd dino
gem build
gem install dino-0.13.0.gem
```

**Note:** There's a bug in the release version of the `pigpio` gem which prevents Dino's tone (square wave buzzer) from working. Install from this fork if you need that fix, until a new version is released. Skip this step if you don't need it.

Install pigpio from source:
```shell
gem uninstall pigpio
git clone https://github.com/vickash/ruby-extension-pigpio.git
cd ruby-extension-pigpio
gem build
gem install pigpio-0.1.11.gem
```

Install the pigpo C library:
```shell
sudo apt-get install pigpio
```

Install this gem:
```shell
gem install dino-piboard
```

## Example
Raspberry Pi requires GPIO access requires root privelges. The pigpio library includes `pigpiod`, which runs in the background. We can access the GPIO through it, allowing our scripts to run as a regular user. Start `pigpiod` first:
```shell
sudo pigpiod -s 10
```
**Note:** `-s 10` tells `pigpiod` to sample pins every 10 microseconds, reducing CPU usage. Default is 5.


Create a script, `led_button.rb`:
```ruby
require 'dino/piboard'

# Create a board instance for the Raspberry Pi.
board = Dino::PiBoard.new

# LED connected to GPIO4.
led = Dino::LED.new(board: board, pin: 4)

# Momentary button connected to GPIO17, using internal pullup.
button = Dino::DigitalIO::Button.new(board: board, pin: 17, pullup: true)

# Led on when button is down (0)
button.down do
  puts "Button down"
  led.on
end

# Led is off when button is up (1)
button.up do
  puts "Button up"
  led.off
end

# Sleep main thread. Ctrl+C to quit.
sleep
```

Run the script:
```shell
ruby led_button.rb
```

See [`examples`](https://github.com/austinbv/dino/tree/master/examples) in the main gem for more. Remove any `Dino::Board::Connection` and `Dino::Board` objects that the script sets up, and do `board = Dino::PiBoard.new` instead. Not all features are implemented yet though, nor can be implemented. See [Feautres](#features) below.

## How It Works

This gem uses the [`pigpio`](https://github.com/nak1114/ruby-extension-pigpio) gem, which provides a Ruby interface to the [`pigpio`](https://github.com/joan2937/pigpio) C library, which provides low-level access to the Raspberry Pi's GPIO interface. Building on this, `Dino::PiBoard` plugs in as a replacement for `Dino::Board`. This allows `dino` features and component classes to be used directly on a Raspberry Pi, without an external microcontroller.

## Features

### Already Implemented
  - Internal Pull Down/Up
  - Digital Out
  - Digital In
  - PWM Out (analog audio can't be used when PWM is)
  - Tone Out (Not working with release version of `pigpio` gem. See [Installation](#installation) above.)

### To Be Implemented
  - Servo
  - I2C
  - SPI
  - OneWire
  - Infrared Out
  - WS2812

### Won't Be Implemented
  - UART. It would wrap a [`rubyserial`](https://github.com/hybridgroup/rubyserial) instance. Use that directly instead.

### Might Be Different
  - Variable Digital Listen Timing (pigpio doesn't have a real way to do this, but glitch filter might be even better?)

### Incompatible
  - Handshake (no need, since running on the same board)
  - EEPROM (can't mess with that. Use the filesystem instead)
  - Analog IO (No analog pins on Raspberry Pi. Use an ADC or DAC over I2C or SPI)
