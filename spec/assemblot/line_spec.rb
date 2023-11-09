# frozen_string_literal: true

require 'assemblot/line'

module Assemblot
  RSpec.describe Line do
    describe '.new' do
      it 'parses label with comment' do
        l = Line.new('  main: # the start', 7)
        expect(l.label?).to eq(true)
        expect(l.label).to eq('main')
        expect(l.comment).to eq('the start')
        expect(l.num).to eq(8)
      end

      it 'parses instruction' do
        l = Line['and a b']
        expect(l.label?).to eq(false)
        expect(l.ins).to eq('and')
        expect(l.args).to eq(%w[a b])
        expect(l.comment).to be_nil
        expect(l.num).to eq(1)
      end
    end
  end
end
