#!/user/bin/env ruby
#
# A Game by Lee-Jon Ball used to test the if engine

require 'yaml'
require 'ostruct'

$: << '.'
require 'engine'
require 'player'
require 'grapher'

game = Node.root do
  room(:downstairs_office) do
    self.exit_north = :universal_marina
    self.exit_up    = :upstairs_office
    self.desc = <<-DESC
      You are in the with the developers of Alliants. One wall is mysteriously
      painted lime green. There are desks everywhere, and a whiteboard has
      lines criss-crossing it. There are stairs leading up and to the north
      is the exit.
      DESC
    self.short_desc = <<-DESC
      Alliants' downstairs office.
      DESC
    item(:manequin, 'manequin') do
      self.desc = <<-DESC
        The manequin has a male torso and a horses head. Like a reverse centaur.
        DESC
      self.presence = <<-PRES
        A manequin.
        PRES
    end

    player do
      item(:business_card, 'card', 'business', '200gsm') do
        self.desc = <<-DESC
          Its the size of a standard business card, with the Alliants logo
          on the front.
          It reads:
          \n Tristan Gadsby, CEO, Alliants Ltd.
          DESC
        self.short_desc = <<-DESC
          A business card.
          DESC
        self.presence = <<-PRES
          A business card.
          PRES
      end
      item(:bacon_sandwich, 'sandwich', 'bacon') do
        self.desc = <<-DESC
          Its a bacon sandwich on rye bread, tomato sause has leaked out and soaked
          into the bread. There's something about this that tells you it is Friday.
          DESC
        self.short_desc =<<-DESC
          A bacon sandwich
          DESC
        self.presence = <<-PRES
          Someone has dropped a bacon sandwich on the floor. Urgh.
          PRES
      end
    end
  end
  room(:upstairs_office) do
    self.exit_down  = :downstairs_office
    self.exit_north = :meeting_room
    self.exit_west  = :recruiters_office
    self.desc = <<-DESC
      You are stood by some stairs leading down. To the north is a glass-fronted meeting
      room and to the west is more office space.
      DESC
    self.short_desc = <<-DESC
      Upstairs office.
      DESC
  end
  room (:meeting_room) do
    self.exit_south = :upstairs_office
  end
  room (:recruiters_office) do
  end
  room(:universal_marina) do
    self.exit_west  = :boat_universal
    self.exit_south = :downstairs_office
    self.desc = <<-DESC
      You are stood in Universal Marina. It is a clear day and brilliant blue
      sky shines through the masts of the ships. Office blocks are to the
      south, and the boats are to the west.
      DESC
    self.short_desc = <<-DESC
      You are stood within Universal Marina.
      DESC
  end
  room(:boat_universal) do
    self.exit_east  = :universal_marina
    self.exit_south = :warsash_dock
    self.desc = <<-DESC
      You are sat in a Jenneau Cap Camerant boat. It has twin engines. Safe
      you think. The seats smell of rich leather. But the interior could do
      with a woman's touch.
      The river runs to the south, and the marina is back to the east.
      DESC
    self.short_desc = <<-DESC
      In a boat at Universal Marina.
      DESC
  end
  room(:warsash_dock) do
    self.exit_north = :boat_universal
    self.exit_east  = :rising_sun
    self.desc = <<-DESC
      You are sat in a Jenneau Cap Camerant boat. It has twin engines. Safe
      you think. The seats smell of rich leather. But the interior could do
      with a woman's touch.
      The river leads north up the Hamble, and the Rising Sun pub is to the
      east.
      DESC
    self.short_desc = <<-DESC
      In a boat docked at Warsash.
      DESC
  end
  room(:rising_sun) do
    self.exit_west = :warsash_dock
    self.desc = <<-DESC
      You are standing out sith the Rising Sun. As your eyes scan the
      building you wonder why it looks like such an  irregularly shaped
      pub in Warsash.
      To the east is the boat.
      DESC
    self.short_desc = <<-DESC
      You are standing outside the Rising Sun pub.
      DESC
  end
  room(:void)

end

saved = false
introduction = <<-INTRO
  \n
  Welcome to the Alliants test game.
  INTRO
puts introduction + "\n"

loop do
  player = game.find(:player)
  player.get_room.describe unless player.get_room.described?
  print "\n> "
  input = gets.chomp
  verb  = input.split(' ').first

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
      puts "Game not saved! Are you sure? (Y/N)"
      if gets.chomp.downcase == "y"
        puts "Goodbye!"
        exit
      end
    end
  else
    saved = false
    player.command(input)
  end
end
