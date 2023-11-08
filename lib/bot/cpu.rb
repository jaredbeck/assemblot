# frozen_string_literal: true

require 'yaml'

class CPU
  def initialize(bot)
    @bot = bot
    parse(bot.code)
    @reg = {
      pc: 0, # Program Counter (line index)
      vx: bot.vx, # velocity
      vy: bot.vy,
      wx: bot.arena.width,
      wy: bot.arena.height,
      x: bot.x, # position
      y: bot.y,
    }
    rules = load_rules
    @instructions = rules.fetch('instructions').keys.freeze
    @reg_ids = rules.fetch('registers').keys.freeze
    @halted = false
  end

  def [](k)
    @reg[k.to_sym]
  end

  def []=(k, v)
    @reg[k.to_sym] = v
  end

  def exec(line)
    tok = line.split
    ins = tok.shift.downcase
    if @instructions.include?(ins)
      result = send ins, *tok
      if ins[0] == 'j' && result == :jump
        jump(tok.first)
      else
        @reg[:pc] += 1
      end
    else
      warn format('Invalid instruction: %s', ins)
      @halted = true
    end
  end

  def fetch(k)
    if @reg_ids.include?(k.to_s)
      self[k].to_i
    else
      warn format('Register not found: %s', k)
      @halted = true
    end
  end

  def tick(t)
    clock_tick = 0
    while !@halted && clock_tick < @bot.clock_speed
      line = @code[@reg[:pc]]
      puts format('%4d %4d %4d %20s %s', t, clock_tick, @reg[:pc], line, @reg)
      exec(line)
      clock_tick += 1
    end
  end

  private

  def acl(x, y)
    dvx = val(x)
    dvy = val(y)
    self[:vx] += dvx
    self[:vy] += dvy
    @bot.acl(dvx, dvy) # hmmm. could get out of sync. maybe return stuff like vx from #tick instead
  end

  def add(i, j)
    self[i] = self[i].to_i + val(j)
  end

  def cmp(i, j)
    self[:c] = val(i) - val(j)
  end

  def je(_label)
    @reg[:c] == 0 ? :jump : nil
  end

  def jle(_label)
    @reg[:c] <= 0 ? :jump : nil
  end

  def jmp(_label)
    :jump
  end

  def jump(label)
    @reg[:pc] = @labels.fetch(label)
  rescue KeyError
    warn format('Label not found: %s', label)
  end

  def load_rules
    path = File.join(__dir__, '../../rules.yml')
    YAML.safe_load(File.read(path)).fetch('cpu')
  end

  def mov(i, j)
    self[j] = val(i)
  end

  def neg(k)
    self[k] = - fetch(k).to_i
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

  def rnd(k)
    self[k] = rand(self[k])
  end

  def sub(i, j)
    self[i] = self[i].to_i - val(j)
  end

  def val(k)
    @reg_ids.include?(k) ? self[k].to_i : k.to_i
  end
end
