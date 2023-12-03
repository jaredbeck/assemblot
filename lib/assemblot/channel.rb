# frozen_string_literal: true

require 'json'

module Assemblot
  # Wrapper around EM::Channel. Responsible for e.g. serialization.
  class Channel
    def initialize(em_channel)
      @em_channel = em_channel
    end

    def push(type, data = {})
      @em_channel.push(JSON.generate(data.merge(type: type)))
    end
  end
end
