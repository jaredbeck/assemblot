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
      set_flags(self[i])
    end

    def and(i, j)
      if @reg_ids.include?(i)
        self[i] &= val(j)
        set_flags(self[i])
      else
        halt(format('Register not found: %s', i))
      end
    end

    def btoi(i)
      i ? 1 : 0
    end

    # @doc https://en.wikipedia.org/wiki/FLAGS_register
    def cmp(i, j)
      set_flags(val(i) - val(j))
    end

    def halt(msg)
      warn msg
      @halted = true
    end

    def je(_label)
      self[:zf] ? :jump : nil
    end

    def jle(_label)
      (self[:sf] | self[:zf] == 1) ? :jump : nil
    end

    def jmp(_label)
      :jump
    end

    def jnz(_label)
      self[:zf] == 1 ? nil : :jump
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
      set_flags(self[k])
    end

    def or(i, j)
      if @reg_ids.include?(i)
        self[i] |= val(j)
        set_flags(self[i])
      else
        halt(format('Register not found: %s', i))
      end
    end

    # > In x86 processors, the parity flag reflects the parity only of the least
    # > significant byte of the result, and is set if the number of set bits of
    # > ones is even (put another way, the parity bit is set if the sum of the
    # > bits is even)
    # > https://en.wikipedia.org/wiki/Parity_flag
    def parity(i)
      btoi(i.to_s(2).count('1').even?)
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
      set_flags(self[k])
    end

    def set_flags(x)
      self[:sf] = btoi(x < 0)
      self[:zf] = btoi(x == 0)
      self[:pf] = parity(x)
    end

    def setnz(i)
      self[i] = btoi(self[:zf] == 0)
    end

    def sub(i, j)
      self[i] = self[i].to_i - val(j)
      set_flags(self[i])
    end

    # @doc https://en.wikipedia.org/wiki/TEST_(x86_instruction)
    def test(i, j)
      set_flags(i & j)
    end

    def val(k)
      if @reg_ids.include?(k)
        self[k].to_i
      elsif k.match?(/\A-?\d+\z/)
        k.to_i
      else
        halt(format('Invalid argument: expected register or integer, got: %s', k))
      end
    end
  end
end
