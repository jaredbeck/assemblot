# frozen_string_literal: true

require 'yaml'
require 'bot/line'

module Bot
  class CPU
    def initialize(code: '', reg: {})
      parse(code)
      @reg = reg.merge(
        pc: 0, # Program Counter (line index)
      )
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
      ins = line.ins
      if line.empty? || line.label?
        advance_pc
      elsif @instructions.include?(ins)
        result = send ins, *line.args
        if ins[0] == 'j' && result == :jump
          jump(line.args.first)
        else
          advance_pc
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

    def tick(t, clock_speed)
      clock_tick = 0
      while !@halted && clock_tick < clock_speed
        line = @lines[@reg[:pc]]
        puts format('%4d %4d %4d %20s %s', t, clock_tick, line.num, line.command, @reg)
        exec(line)
        clock_tick += 1
      end
      @reg.slice(:vx, :vy)
    end

    private

    # Increment the PC to the next non-empty line
    def advance_pc
      loop do
        @reg[:pc] += 1
        if @reg[:pc] >= @lines.length
          @halted = true
        end
        if @halted || !@lines[@reg[:pc]].empty?
          break
        end
      end
    end

    def acl(x, y)
      self[:vx] += val(x)
      self[:vy] += val(y)
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
      @lines = code.split("\n").each_with_index.map { |raw_line, ix| Line.new(raw_line, ix) }
      @labels = @lines.each_with_object({}) { |line, acc|
        if line.label?
          acc[line.label] = line.ix
        end
      }
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
end
