#!/usr/bin/env ruby
require 'yaml'
require 'readline'

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

  input = Readline.readline('> ', true)
 # input = gets.chomp
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
