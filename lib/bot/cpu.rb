# frozen_string_literal: true

require 'yaml'

class CPU
  def initialize
    @reg = {}
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

  private

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
    self[j] = self[i]
  end

  def sub(i, j)
    self[i] = self[i].to_i - val(j)
  end

  def val(k)
    @reg_ids.include?(k) ? self[k] : k.to_i
  end
end
