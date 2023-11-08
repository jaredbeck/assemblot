# frozen_string_literal: true

require 'bot/cpu'

module Bot
  RSpec.describe CPU do
    describe 'add' do
      it 'adds value of second arg to first' do
        cpu = CPU.new
        cpu[:a] = 1
        cpu.exec('add a 1')
        expect(cpu[:a]).to eq(2)
        cpu[:b] = 3
        cpu.exec('add a b')
        expect(cpu[:a]).to eq(5)
      end
    end

    describe 'cmp' do
      it 'subtracts second arg from first, saves result in register c' do
        cpu = CPU.new
        cpu.exec('cmp 3 1')
        expect(cpu[:c]).to eq(2)
        cpu[:a] = 5
        cpu[:b] = 2
        cpu.exec('cmp a b')
        expect(cpu[:c]).to eq(3)
      end
    end

    describe 'mov' do
      it 'moves value from one register to another' do
        cpu = CPU.new
        cpu[:b] = 3
        cpu.exec('mov b a')
        expect(cpu[:a]).to eq(3)
        expect(cpu[:b]).to eq(3)
        expect(cpu[:c]).to be_nil
      end
    end

    describe 'sub' do
      it 'subtracts value of second arg from first' do
        cpu = CPU.new
        cpu[:a] = 5
        cpu.exec('sub a 3')
        expect(cpu[:a]).to eq(2)
        cpu[:b] = 1
        cpu.exec('sub a b')
        expect(cpu[:a]).to eq(1)
      end
    end
  end
end
