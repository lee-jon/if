#!/usr/bin/env ruby
require 'yaml'
require 'readline'

# Fix loadpath and load Requirements
$: << '.'
require 'engine'
require 'player'
require 'grapher'

# Start IF and select the required game
puts "Welcome to IF, the interactive fiction / adventure game interpreter.\n\n"
puts "Select a game to load."

a = Dir.glob('games/*.game*')
a.each_with_index do |file, index|
  puts "#{index+1}. #{file.gsub('games/','').gsub('game.rb','')}"
end
file_number = gets.chomp.to_i - 1

# Load game
file = File.read(a[file_number])
game = eval(file)

# Initialize game
AUTOCOMPLETE = Player.game_methods
comp = proc { |s| AUTOCOMPLETE.grep( /^#{Regexp.escape(s)}/ ) }
Readline.completion_append_character = " "
Readline.completion_proc = comp

# Start game
print "\e[2J\e[f\n\n"
puts game.intro.to_s + "\n\n"

# Play game loop
loop do
  player = game.find(:player)
  player.get_room.describe unless player.get_room.described?

  input = Readline.readline("\n> ", true)
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
