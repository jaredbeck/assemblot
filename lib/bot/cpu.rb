# frozen_string_literal: true

require 'yaml'

class CPU
  def initialize(bot)
    @bot = bot
    parse(bot.code)
    @reg = {
      vx: bot.vx,
      vy: bot.vy,
      x: bot.x,
      y: bot.y,
    }
    rules = load_rules
    @instructions = rules.fetch('instructions').keys.freeze
    @reg_ids = rules.fetch('registers').keys.freeze
    @halted = false
    @pc = 0 # Program Counter (line index in @code)
  end

  def [](k)
    @reg[k.to_sym]
  end

  def []=(k, v)
    @reg[k.to_sym] = v
  end

  def exec(line)
    return if @halted
    tok = line.split
    ins = tok.shift.downcase
    if @instructions.include?(ins)
      send ins, *tok
    else
      warn format('Invalid instruction: %s', ins)
      @halted = true
    end
  end

  def tick(t)
    clock_tick = 0
    while clock_tick < @bot.clock_speed
      line = @code[@pc]
      puts format('%4d %4d %s', t, clock_tick, line)
      exec(line)
      @pc += 1 # TODO: jumps
      clock_tick += 1
    end
  end

  private

  def acl(x, y)
    @bot.acl(x, y)
  end

  def add(i, j)
    self[i] = self[i].to_i + val(j)
  end

  def cmp(i, j)
    self[:c] = val(i) - val(j)
  end

  def load_rules
    path = File.join(__dir__, '../../rules.yml')
    YAML.safe_load(File.read(path)).fetch('cpu')
  end

  def mov(i, j)
    self[j] = val(i)
  end

  def parse(code)
    @code = []
    @labels = {}
    code.split("\n").reject(&:empty?).each do |line_raw|
      line = line_raw.strip
      label_match = line.match(/(.*):\z/)
      if label_match.nil?
        @code << line
      else
        @labels[label_match.captures.first] = @code.length
      end
    end
  end

  def sub(i, j)
    self[i] = self[i].to_i - val(j)
  end

  def val(k)
    @reg_ids.include?(k) ? self[k].to_i : k.to_i
  end
end
