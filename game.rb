#!/usr/bin/env ruby
require 'yaml'

# Fix loadpath and load files
$: << '.'
require 'engine'
require 'player'
require 'grapher'


# Load the world - this should be done with ARGV
game = Node.root do
  room(:living_room) do
    self.exit_north = :kitchen
    self.exit_east = :hall
    self.desc = <<-DESC
      You are in a dark living room.  Heavy drapes cover
      the windows, the only light comes from a dim lamp in
      the corner.  The only furniture in the room is a
      well-used couch, covered in blankets and pillows.
      
      Exits are north to the kitchen and east to the hall.
    DESC
    self.short_desc = <<-DESC
      You are in a dark, messy living room.
    DESC
    item(:cat, 'cat', 'sleeping', 'fuzzy') do
      self.script_take = <<-SCRIPT
        if find(:dead_mouse)
          puts "The cat makes a horrifying noise and throws up a dead mouse"
          get_room.move(:dead_mouse, get_room, false)
        end

        puts "The cat refused to be picked up, how degrading!"
        return false
      SCRIPT

      self.script_control = <<-SCRIPT
        puts "The cat sits upright, awaiting your command"
        return true
      SCRIPT

      self.desc = <<-DESC
        A pumpkin-colored long-haired cat.  He is well-groomed
        and certainly a house cat and seems perfectly content
        to sleep the day away on the couch.
      DESC

      self.short_desc = <<-DESC
        A pumpkin-colored long-haired cat.
      DESC

      self.presence = <<-PRES
        A cat dozes lazily here.
      PRES

      item(:dead_mouse, 'mouse', 'dead', 'eaten') do
        self.presence = <<-PRES
          A dead mouse
        PRES
      end
    end

    item(:remote_control, 'remote', 'control') do
      self.openable = true
      self.presence = <<-PRES
        There's a remote control.
      PRES

      self.script_accept = <<-SCRIPT
        if [:new_batteries, :dead_batteries].include?(args[0].tag) &&
            children.empty?
          return true
        elsif !children.empty?
          puts "There are already batteries in the remote"
          return false
        else
          puts "That won't fit into the remote"
          return false
        end
      SCRIPT

      self.script_use = <<-SCRIPT
        if !find(:new_batteries)
          puts "The remote doesn't seem to work"
          return
        end

        if args[0].tag == :cat
          args[0].script('control')
          return
        else
          puts "The remote doesn't seem to work with that"
          return
        end
      SCRIPT

      item(:dead_batteries, 'batteries', 'dead', 'AA')
    end
  end

  room(:kitchen) do
    self.exit_south = :living_room
    
    self.desc = <<-DESC
      You are in a run down 1960s kitchen. You think you saw
      cockroaches scatter, but your mind is still fuzzy.
      The only exit is to the south.
    DESC
    
    self.short_desc = <<-DESC
      You are in a run down kitchen.
    DESC

    player do
      item(:ham_sandwich, 'sandwich', 'ham') do
        self.desc = <<-DESC
          A ham sandwich on rye bread. You remember you like ham sandwiches.
          Especially with cheese. And pickle or mustard. You start to
          salivate at the thought of eating the ham sandwich. But something
          tells you it isn't meant for you.
        DESC

        self.short_desc = <<-DESC
          A ham-sandwich.
        DESC
        
        self.presence = <<-PRES
          Someone has dropped a ham-sandwich on the floor.
        PRES
      end
    end
    
    item(:drawer, 'drawer', 'kitchen') do
      self.open = false
      self.openable = true
      self.desc = <<-DESC
        You see a drawer fronted in birch laminate.
      DESC
      self.short_desc = <<-DESC
        A drawer fronted in birch laminate.
      DESC
      self.presence = <<-PRES
        A kitchen unit is in the corner with a single drawer.
      PRES
      item(:new_batteries, 'batteries', 'new', 'AA') do
        self.desc = <<-DESC
          You look at the gleaming AA batteries. They look new, unused and
          full of charge.
        DESC
        self.presence = <<-PRES
          New AA Batteries.
        PRES
      end
    end
  end

  room(:hall) do
    self.exit_west = :living_room
    self.desc = <<-DESC
      You are in a massive hallway. Its a lot larger than the other rooms.
      Why would someone design a house like that. Then again, why would 
      someone design a game like this. 
    DESC
    self.short_desc = <<-DESC
      You are in a massive hallway.
    DESC
    self.script_enter = <<-SCRIPT
      puts "A forcefield stops you from entering the hall"
      return false
    SCRIPT
  end
end


# initialize game
saved = false
introduction = <<-INTRO
  \n
  Welcome to the test game. Please be careful as you move around!
  INTRO
puts introduction + "\n"
turn = 0


# Main loop
loop do
  turn += 1

  player = game.find(:player)
  player.get_room.describe if player.get_room.described? == false

  puts ""  
  print "> "
  input = gets.chomp
  verb = input.split(' ').first

  
  case verb
  when "load"
    game = Node.load
    puts "Loaded"
  when "save"
    Node.save(game)
    puts "Saved"
    saved = true
  when "quit"
    if saved == false
      puts "Game not saved. Are you sure? (Y/N)?"
      input = gets.chomp
      if input.downcase == "y"
        puts "Goodbye!"
        exit
      end
    end
  when "qq"
    exit
  else
    saved = false
    player.command(input)
  end
end