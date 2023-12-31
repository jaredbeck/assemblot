# frozen_string_literal: true

require 'assemblot/cpu'

module Assemblot
  class Bot
    attr_reader :arena, :code, :name, :vx, :vy, :x, :y

    def initialize(name:, code:, atrs:, arena:)
      @name = name
      @code = code
      @atrs = atrs # e.g. clock speed
      @arena = arena
      @x = 100
      @y = 100
      @vx = 0
      @vy = 0
      @cpu = CPU.new(code: code, reg: cpu_initial_registers)
    end

    def clock_speed
      @atrs.fetch('clock_speed')
    end

    # Execute code according to clock speed, return actions, e.g. fire weapon.
    def tick(t)
      reg = @cpu.tick(t, clock_speed)
      @vx = reg[:vx]
      @vy = reg[:vy]
      @x = (@x + @vx).clamp(0, @arena.width)
      @y = (@y + @vy).clamp(0, @arena.height)
      puts format('%d: %s: Pos: %d, %d Vel: %d, %d', t, @name, @x, @y, @vx, @vy)
      @cpu[:x] = @x
      @cpu[:y] = @y
    end

    private

    def cpu_initial_registers
      {
        vx: @vx, # velocity
        vy: @vy,
        wx: @arena.width,
        wy: @arena.height,
        x: @x, # position
        y: @y,
      }
    end
  end
end
