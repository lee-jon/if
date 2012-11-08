#!/usr/bin/env ruby
require 'yaml'

# Fix loadpath and load
$: << '.'
require 'engine'
require 'player'
require 'grapher'

# Load the required game
file = File.read("alliants.game.rb")
game = eval(file)

puts game.intro.to_s + "\n\n\n"

# Main loop
loop do
  player = game.find(:player)
  player.get_room.describe unless player.get_room.described?
  print "\n> "
  input = gets.chomp
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
  else
    player.command(input)
  end
end
