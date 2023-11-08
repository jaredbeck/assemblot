# frozen_string_literal: true

require 'bot/cpu'

module Bot
  class Bot
    attr_reader :code, :vx, :vy, :x, :y

    def initialize(name:, code:, atrs:, arena:)
      @name = name
      @code = code
      @cpu = CPU.new(self)
      @atrs = atrs # e.g. clock speed
      @arena = arena
      @x = 100
      @y = 100
      @vx = 0
      @vy = 0
    end

    def acl(x, y)
      @vx += x
      @vy += y
    end

    def clock_speed
      @atrs.fetch('clock_speed')
    end

    # Execute code according to clock speed, return actions, e.g. fire weapon.
    def tick(t)
      @cpu.tick(t)
      @x = (@x + @vx).clamp(0, @arena.width)
      @y = (@y + @vy).clamp(0, @arena.height)
      puts format('%d: %s (%d, %d)', t, @name, @x, @y)
    end
  end
end
