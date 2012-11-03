#!/usr/bin/env ruby

# Load external dependencies


# Load internal dependencies
$: << '.'
require 'engine.rb'
require 'world.rb'


loop do
  player = root.find(:player)
  player.get_room.describe
  
  print "What now? "
  input = gets.chomp
  verb = input.split(' ').first

  case verb
  when "load"
    root = Node.load
    puts "Loaded"
  when "save"
    Node.save(root)
    puts "Saved"
  when "quit" or "exit"
    puts "Goodbye!"
    exit
  when "state" 
    # define the current state of the game
    puts root
  else
    player.command(input)
  end
end