# frozen_string_literal: true

module Assemblot
  # A parsed line of code.
  class Line
    LABEL_OPERATOR = ':'

    attr_reader :command, :comment, :ix

    def initialize(raw, ix)
      @ix = ix
      parse(raw.strip)
    end

    class << self
      def [](raw)
        new(raw, 0)
      end
    end

    def args
      @toks[1..-1]
    end

    def empty?
      @empty
    end

    def label
      @toks.first.chomp(LABEL_OPERATOR).downcase
    end

    def label?
      !empty? && @toks.first.end_with?(LABEL_OPERATOR)
    end

    def ins
      @toks.first.downcase
    end

    def num
      @ix + 1
    end

    private

    def parse(line)
      @empty = line.start_with?('#') || line.empty?
      return if @empty
      comment_match = line.split('#').map(&:strip)
      if comment_match.length == 2
        @command, @comment = comment_match
      else
        @command = line
      end
      @toks = @command.split
    end
  end
end
