# frozen_string_literal: true

require 'byebug'
require 'yaml'
require 'assemblot/arena'
require 'assemblot/bot'
require 'assemblot/rules'

module Assemblot
  class Game
    MAX_TICKS = 100

    def initialize(rules_path, *bot_paths)
      @rules = Rules.new(rules_path)
      @bot_paths = bot_paths
    end

    # @param channel [Channel]
    def start_game(channel)
      puts 'start_game'
      raise 'invalid state transition' unless @state == 'pending'
      @state = 'started'
      @channel = channel
    end

    def start_thread
      @state = 'pending'
      @thread = Thread.new do
        while @state == 'pending'
          sleep 1
        end
        if @state != 'started'
          puts 'doh never got to start the game'
          break
        end
        puts 'woo really starting game'
        arena = Arena.new(**@rules.arena_atrs)
        @channel.push(
          'arena_new',
          height: arena.height,
          width: arena.width
        )
        bots = @bot_paths.map { |path|
          bot = YAML.safe_load(File.read(path))
          Bot.new(
            arena: arena,
            atrs: bot.fetch('atrs'),
            code: bot.fetch('code'),
            name: bot.fetch('name'),
          )
        }
        tick = 0
        while tick < MAX_TICKS && @state == 'started'
          sleep 0.1 # TODO: frame rate limit, sleep til next frame
          @channel.push('tick', tick: tick)
          bots.each { |b|
            b.tick(tick)
            @channel.push(
              'bot_position',
              botName: b.name,
              x: b.x,
              y: b.y
            )
          }
          tick += 1
        end
        puts 'Game over'
        @channel.push('game_over')
      rescue Exception => e
        warn e.full_message
        raise e
      end
    end

    def stop
      puts 'stopping game'
      @state = 'done'
      @thread.join
    end
  end
end
