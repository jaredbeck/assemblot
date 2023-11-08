# frozen_string_literal: true

require 'byebug'
require 'yaml'
require 'bot/arena'
require 'bot/bot'
require 'bot/rules'

module Bot
  class Game
    MAX_TICKS = 100

    def initialize(rules_path, *bot_paths)
      @rules = Rules.new(rules_path)
      @bot_paths = bot_paths
    end

    def run
      arena = Arena.new(**@rules.arena_atrs)
      basic = YAML.safe_load(File.read(@bot_paths.first))
      bot = Bot.new(
        arena: arena,
        atrs: basic.fetch('atrs'),
        code: basic.fetch('code'),
        name: basic.fetch('name'),
      )
      bots = [bot]
      tick = 0
      while tick <= MAX_TICKS
        bots.each { |b| b.tick(tick) }
        tick += 1
      end
      puts 'Game over'
    end
  end
end

Bot::Game.new(*ARGV).run
