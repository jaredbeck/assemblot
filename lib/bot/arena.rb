# frozen_string_literal: true

module Bot
  class Arena
    attr_reader :height, :width

    def initialize(height:, width:)
      @height = height
      @width = width
    end
  end
end
