#!/usr/bin/env ruby
require 'yaml'
require 'readline'

# Fix loadpath and load Requirements
$: << '.'
require 'engine'
require 'player'
require 'grapher'

# Load the required game
file = File.read("zork.game.rb")
game = eval(file)

# Initialize game
AUTOCOMPLETE = Player.game_methods
comp = proc { |s| AUTOCOMPLETE.grep( /^#{Regexp.escape(s)}/ ) }
Readline.completion_append_character = " "
Readline.completion_proc = comp

# Play game
puts game.intro.to_s + "\n\n"

# Main loop
loop do
  player = game.find(:player)
  player.get_room.describe unless player.get_room.described?

  input = Readline.readline('> ', true)
  verb = input.split(' ').first

  case verb
  when "load"
    game = Node.load
    puts "Loaded"
  when "save"
    Node.save(game)
    puts "Saved"
  when "help"
    puts game.help
  when "quit"
    puts "Goodbye!"
    exit
  when "reload"
    file = File.read("alliants.game.rb")
    game = eval(file)
    puts "reloaded"
  else
    player.command(input)
  end
end
