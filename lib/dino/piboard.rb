require 'dino'
require 'pigpio'
include Pigpio::Constant

module Dino
  class PiBoard
    attr_reader :components, :high, :low, :pwm_high

    def initialize
      @components = []
      @pin_callbacks = []
      @pin_pwms = []
      
      @low  = 0
      @high = 1
      @pwm_high = 255

      @board = Pigpio.new
      unless @board.connect
        exit -1
      end
    end

    def finish_write
      @board.stop
    end

    def update(pin, message, time)
      update_component(pin, message)
    end

    def update_component(pin, message)
      @components.each do |part|
        part.update(message) if part.pin.to_i == pin
      end
    end

    def add_component(component)
      @components << component
    end

    def remove_component(component)
      component.stop if component.methods.include? :stop
      @components.delete(component)
    end

    # CMD = 0
    def set_pin_mode(pin, mode=:input)
      pwm_clear(pin)
      gpio = @board.gpio(pin)

      # Output
      if mode.to_s.match /output/
        gpio.mode = PI_OUTPUT

      # Input
      else
        gpio.mode = PI_INPUT
        # Only trigger state change if level has been stable for 90us.
        gpio.glitch_filter(90)

        # Pull down/up/none
        if mode.to_s.match /pulldown/
          gpio.pud = PI_PUD_DOWN
        elsif mode.to_s.match /pullup/
          gpio.pud = PI_PUD_UP
        else
          gpio.pud = PI_PUD_OFF
        end
      end
    end

    # CMD = 1
    def digital_write(pin, value)
      pwm_clear(pin)
      @board.gpio(pin).write(value)
    end
    
    # CMD = 2
    def digital_read(pin)
      if @pin_pwms[pin]
        @pin_pwms[pin].dutycycle
      else
        @board.gpio(pin).read
      end
    end

    # CMD = 3
    def pwm_write(pin, value)
      @pin_pwms[pin] = @board.gpio(pin).pwm unless @pin_pwms[pin]
      @pin_pwms[pin].dutycycle = value
    end

    # CMD = 6
    def set_listener(pin, state=:off, options={})
      # Listener on
      if state == :on && !@pin_callbacks[pin]
        callback = @board.gpio(pin).callback(EITHER_EDGE) do |tick, level, pin_cb|
          update(pin_cb, level, tick)
        end
        @pin_callbacks[pin] = callback

      # Listener off
      else
        @pin_callbacks[pin].cancel if @pin_callbacks[pin]
        @pin_callbacks[pin] = nil
      end
    end

    def digital_listen(pin, divider=4)
      set_listener(pin, :on, {})
    end

    def stop_listener(pin)
      set_listener(pin, :off)
    end

    def tone(pin, frequency, duration=nil)
      pin_mask = 1 << pin
      half_wavelength = (500000.0 / frequency).round
      wave = @board.wave
      wave.tx_stop.clear
      wave.add_new
      wave.add_generic [
        wave.pulse(pin_mask, 0x00, half_wavelength),
        wave.pulse(0x00, pin_mask, half_wavelength)                  
      ]
      wave_id = wave.create
      wave.send_repeat(wave_id)
    end

    def no_tone(pin)
      @board.wave.tx_stop.clear
    end

    private

    def pwm_clear(pin)
      @pin_pwms[pin] = nil
    end
  end
end
