# frozen_string_literal: true

require 'em-websocket'
require 'assemblot/channel'
require 'assemblot/game'

game = Assemblot::Game.new(*ARGV)

EventMachine.run {
  channel = EM::Channel.new
  EventMachine::WebSocket.start(debug: false, host: "localhost", port: 7654) do |ws|
    ws.onopen {
      puts 'begin ws.onopen'
      sid = channel.subscribe { |msg| ws.send msg }
      ws.onmessage { |msg|
        # noop. ignore messages from browser for now. might want a
        # "start game" button later.
      }
      ws.onclose {
        puts 'ws.onclose'
        channel.unsubscribe(sid)
        game.stop
      }
      game.start_thread
      game.start_game(::Assemblot::Channel.new(channel))
      puts 'end ws.onopen'
    }
  end
  puts "Server started"
}
# EventMachine.run blocks main thread. EventMachine::WebSocket traps SIGINT
# and calls EM.stop.
puts 'exiting game main thread'
