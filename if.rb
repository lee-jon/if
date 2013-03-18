#!/usr/bin/env ruby

# IF
#
# The interactive fiction game engine

require 'yaml'
require 'readline'

# Fix loadpath and require IF files
$: << '.'
require 'engine'
require 'player'

# Load files if developer mode is selected
if ARGV[0] == "d"
  $debugmode = true
  require 'grapher'
  require 'debug-if'
end

ARGV.clear

# Start IF and select the required game
puts "Welcome to IF, the interactive fiction / adventure game interpreter.\n\n"
puts "Select a game to load."

file_index = Dir.glob('games/*.game*')
file_index.each_with_index do |file, index|
  puts "#{index+1}. #{file.gsub('games/','').gsub('game.rb','')}"
end
file_number = gets.chomp.to_i - 1

# Load game
file = File.read(file_index[file_number])
game = eval(file)

# Initialize game
if game.prompt.nil?
  game.prompt = ""
end
PROMPT = "\n"+ game.prompt + "> "

AUTOCOMPLETE = Player.game_methods
comp = proc { |s| AUTOCOMPLETE.grep( /^#{Regexp.escape(s)}/ ) }
Readline.completion_append_character = " "
Readline.completion_proc = comp

# Clear the screen and print the game's intro.
#
print "\e[2J\e[f\n\n"
puts game.intro.to_s + "\n\n"

# Main game loop
#
# Master verbs of load, save, help and quit are coded here in the loop
# If the command isn't one of these the loop asks the Player class.
loop do
  player = game.find(:player)
  player.get_room.describe unless player.get_room.described?

  input = Readline.readline(PROMPT, true)
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
