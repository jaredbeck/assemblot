# frozen_string_literal: true

require 'bot/arena'
require 'bot/bot'
require 'bot/cpu'
require 'bot/line'

module Bot
  RSpec.describe CPU do
    describe 'add' do
      it 'adds value of second arg to first' do
        cpu = CPU.new
        cpu[:a] = 1
        cpu.exec(Line['add a 1'])
        expect(cpu[:a]).to eq(2)
        cpu[:b] = 3
        cpu.exec(Line['add a b'])
        expect(cpu[:a]).to eq(5)
      end
    end

    describe 'cmp' do
      it 'subtracts second arg from first, saves result in register c' do
        cpu = CPU.new
        cpu.exec(Line['cmp 3 1'])
        expect(cpu[:c]).to eq(2)
        cpu[:a] = 5
        cpu[:b] = 2
        cpu.exec(Line['cmp a b'])
        expect(cpu[:c]).to eq(3)
      end
    end

    describe 'je' do
      it 'jump if equal' do
        code = <<~EOS
          main:
          cmp 0 0
          je main
        EOS
        cpu = CPU.new(code: code)
        cpu[:pc] = 2
        cpu[:c] = 0
        cpu.exec(Line['je main'])
        expect(cpu[:pc]).to eq(0)
      end
    end

    describe 'je' do
      it 'jump if equal' do
        code = <<~EOS
          main:
          cmp 0 1
          jle main
        EOS
        cpu = CPU.new(code: code)
        cpu[:pc] = 2
        cpu[:c] = -1
        cpu.exec(Line['jle main'])
        expect(cpu[:pc]).to eq(0)
        cpu[:pc] = 2
        cpu[:c] = 0
        cpu.exec(Line['jle main'])
        expect(cpu[:pc]).to eq(0)
        cpu[:pc] = 2
        cpu[:c] = +1
        cpu.exec(Line['jle main'])
        expect(cpu[:pc]).to eq(3)
      end
    end

    describe 'jmp' do
      it 'jumps' do
        code = <<~EOS
          main:
          jmp main
        EOS
        cpu = CPU.new(code: code)
        cpu[:pc] = 1
        cpu.exec(Line['jmp main'])
        expect(cpu[:pc]).to eq(0)
      end
    end

    describe 'mov' do
      it 'moves value from one register to another' do
        cpu = CPU.new
        cpu[:b] = 3
        cpu.exec(Line['mov b a'])
        expect(cpu[:a]).to eq(3)
        expect(cpu[:b]).to eq(3)
        expect(cpu[:c]).to be_nil
        cpu.exec(Line['mov 7 a'])
        expect(cpu[:a]).to eq(7)
      end
    end

    describe 'neg' do
      it 'negates a register' do
        cpu = CPU.new
        cpu[:b] = 3
        cpu.exec(Line['neg b'])
        expect(cpu[:b]).to eq(-3)
        cpu.exec(Line['neg b'])
        expect(cpu[:b]).to eq(+3)
      end

      it 'negates an empty register' do
        cpu = CPU.new
        cpu.exec(Line['neg a'])
        expect(cpu[:a]).to eq(0)
      end
    end

    describe 'rnd' do
      it 'moves value from one register to another' do
        cpu = CPU.new
        results = []
        50.times do
          cpu[:a] = 100
          cpu.exec(Line['rnd a'])
          results << cpu[:a]
        end
        results.each do |result|
          expect((0..100)).to cover(result)
        end
      end
    end

    describe 'sub' do
      it 'subtracts a constant' do
        cpu = CPU.new
        cpu[:a] = 5
        cpu.exec(Line['sub a 3'])
        expect(cpu[:a]).to eq(2)
        cpu[:b] = 1
        cpu.exec(Line['sub a b'])
        expect(cpu[:a]).to eq(1)
      end

      it 'subtracts a register' do
        cpu = CPU.new
        cpu[:a] = 2
        cpu[:b] = 1
        cpu.exec(Line['sub a b'])
        expect(cpu[:a]).to eq(1)
      end
    end
  end
end
