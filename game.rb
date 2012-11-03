#!/usr/bin/env ruby

# Fix loadpath and load files
$: << '.'
require 'engine'


# Load the world - this should be done with ARGV
root = Node.root do
  room(:living_room) do
    self.exit_north = :kitchen
    self.exit_east = :hall

    self.desc = <<-DESC
      You are in a dark living room.  Heavy drapes cover
      the windows, the only light comes from a dim lamp in
      the corner.  The only furniture in the room is a
      well-used couch, covered in blankets and pillows.
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

      item(:dead_mouse, 'mouse', 'dead', 'eaten')
    end

    item(:remote_control, 'remote', 'control') do
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

    player do
      item(:ham_sandwich, 'sandwich', 'ham')
    end
    
    item(:drawer, 'drawer', 'kitchen') do
      self.open = false

      item(:new_batteries, 'batteries', 'new', 'AA')
    end
  end

  room(:hall) do
    self.exit_west = :living_room

    self.script_enter = <<-SCRIPT
      puts "A forcefield stops you from entering the hall"
      return false
    SCRIPT
  end
end


# initialize game
saved = false


# Main loop
loop do
  puts ""
  
  player = root.find(:player)
  player.get_room.describe
  
  print "> "
  input = gets.chomp
  verb = input.split(' ').first

  
  case verb
  when "load"
    root = Node.load
    puts "Loaded"
  when "save"
    Node.save(root)
    puts "Saved"
    saved = true
  when "quit"
    if saved == true
      puts "Goodbye!"
      exit
    else
      puts "Game not saved. Are you sure? (Y/N)?"
      input = gets.chomp
      if input.downcase == "y"
        Node.save(root)
        exit
      else
        exit
      end
    end
  else
    saved = false
    player.command(input)
  end
end