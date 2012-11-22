# Non-canonical verbs
class Player < Node
  def do_fastern(*words)
    item = get_room.find(words)
    return if item.nil?
    item.script('fastern')
  end
  def do_unfastern(*words)
    item = get_room.find(words)
    return if item.nil?
    item.script('unfastern')
  end
end

# Game
Node.root do
  self.intro = "Seabase delta, classic 1984 game by Firebird software"
  self.help = "Use your 'ed Ed, & always EXAMINE things."
  
  # Start & Station Charlie
  room(:walkway) do
    self.exit_east = :food_farm
    self.desc = <<-DESC
      I am in a LARGE TUBULAR WALKWAY. Through the transparent walls of the 
      tube I can see the murky depths of the ocean. The walkway stretches EAST.
    DESC
    self.short_desc = "Large Tubular Walkway."
    
    item(:brief_case, 'briefcase', 'case') do
      self.openable   = true
      self.short_desc = "A briefcase."
      self.presence   = "Briefcase."
      
      item(:documents, 'documents') do
        self.desc = <<-DESC
        oo TOP SECRET TELEX MESSAGE oo
        We have captured another sub but
        all other personel have had to
        leave due to a strange epidemic.
        I have managed to neutralize the
        disease but still feel very ill.
        I have left the central computer
        in control of the base in case I
        don't make it. The missile aimed
        at the British base will fire as
        planned. MESSAGE ENDS - SPY BASE
        DESC
        self.short_desc = "Documents"
        self.presence = "Documents"
      end
    end
    
    item(:dead_body, 'body') do
      self.fixed = true
      self.short_desc = "Dead body."
      self.presence   = "Dead body."
      self.desc = "No signs of life - perhaps his pockets..."
      self.script_take = <<-SCRIPT
        puts "Thanks-but NO THANKS!"
        return false
      SCRIPT
      self.script_examine = <<-SCRIPT
          get_root.move(:pockets, parent, false)
          return true
        SCRIPT
    end
    
    player
  end
  
  room(:food_farm) do
    self.exit_west  = :walkway
    self.exit_south = :station_charlie
    self.exit_east  = :at_long_table
    self.desc = <<-DESC
      I've entered the FOOD-FARM AREA. Yuk! The floor is almost completely 
      covered with GREEN SLIMEY SEAWEED! Exits are SOUTH and WEST.
    DESC
    self.short_desc = "Food farm."
    item(:long_table, 'table', 'long') do
      self.desc = "It's to the EAST - at the other side of the room..."
      self.short_desc = "A table."
      self.presence   = "Long table."
    end
    scenery(:seaweed, 'seaweed') do
    end
  end
  
  room(:at_long_table) do
    self.exit_west = :food_farm
    self.short_desc ="Long Table"
    self.script_enter = <<-SCRIPT
        puts "WHEEEEEE!!!"
        puts "You slide majestically across the room on the seaweed."
        puts "Feet won't grip!"
        puts ""
        puts "What's that on the TABLE?"
        puts "You slide past the table back to the entrance of the room.."
        puts ""
        
        return false
    SCRIPT
  end
  
  room(:station_charlie) do
    self.exit_north = :food_farm
    self.destination = :station_delta
    self.desc = <<-DESC
      I am standing on a metallic platform in a large dome. A brightly lit
      sign above the walkway says TRAVEL-TUBE STATION CHARLIE. A walkway
      leads NORTH.
    DESC
    self.short_desc = "Charlie Station."
    self.script_enter_car = <<-SCRIPT
      puts "You enter the travel-tube car"
      # TODO
    SCRIPT
    
    item(:lever, 'lever') do
      self.presence = "Lever"
      self.script_pull = <<-SCRIPT
        puts "Whoosh! A travel-car arrives."
        puts "The door opens"
        get_root.move(:tube_car, parent, false)
      SCRIPT
    end
    item(:rail_tracks, 'tracks', 'rail-tracks') do
      self.desc = "OUCH! Your hair stands on end!"
      self.presence = "Rail-tracks"
    end
  end
  
  # The carriage
  room(:carriage) do
    self.desc = <<-DESC 
      I'm in the Travel-Tube car. A metallic voice from the
      loudspeaker-"CLUNK-CLICK OR YOU'RE SURE TO BE SICK"
    DESC
    self.short_desc = <<-DESC
      A metallic voice from the loudspeaker-"CLUNK-CLICK OR YOU'RE
      SURE TO BE SICK"
    DESC
    self.script_exit = <<-SCRIPT
      if get_room.open
        current_station = get_root.find(:tube_car).get_room
        get_root.move(:player, current_station, false)
        puts current_station.short_desc
      else
        puts "You are still fastened in."
      end
    SCRIPT
    
    item(:seatbelt, 'belt', 'seatbelt') do
      self.fixed = true
      self.short_desc = 'seat belt.'
      self.presence = "seat belt."
      self.script_fastern = <<-SCRIPT
        puts "OK"
        self.get_room.open = false
      SCRIPT
      self.script_unfastern = <<-SCRIPT
        puts "OK"
        self.get_room.open = true
      SCRIPT
    end
    item(:smallslot, 'slot', 'small') do
      self.fixed = true
      self.short_desc = "small slot."
      self.presence = "small slot"
    end
  end
  
  # Around Station Delta
  room(:station_delta) do
    self.exit_north = :observation_dome
    self.destination = :station_echo
    self.desc = <<-DESC
      I am on a platform at STATION DELTA. The platform
      opens out to the NORTH.
    DESC
    self.short_desc = "Station Delta"
  end
  room(:observation_dome) do
    self.exit_south = :station_delta
    self.desc = <<-DESC
      This is the OBSERVATION DOME. The exit is to the SOUTH.
      DESC
    self.short_desc = "Observation dome."
    item(:huge_window, 'window') do
      self.fixed = true
      self.desc = <<-DESC
        The murky sea stretches out before me. In on direction I see a
        SMALL MISSILE BAY and in the other- some sort of POLE sticking
        out of some WRECKAGE.
        DESC
      self.presence = "Huge viewing window"
    end
  end
  
  # Around Station Echo
  room(:station_echo) do
  end
  
  # Blank room for moving items rather than root
  room(:void) do
    self.desc = "You are in the void - how did you get here?"
    self.short_desc = "The Void"
    item(:mover, 'mover', 'metallic') do
      self.presence = "The mover is here."
    end
    
    item(:tube_car, 'car') do
      self.presence = "Travel-Tube car"
      self.script_enter = <<-SCRIPT
        get_root.move(:player, :carriage)
        return false
      SCRIPT
    end
    scenery(:pockets, 'pocket') do
      self.script_examine = <<-SCRIPT
        if self.children.nil?
          return false
        else
          puts "You look through the pockets and see a card!"
          self.open = true
          get_root.find(:dead_body).presence = 
            "Dead body - with pockets hanging out"
          get_root.move(:plastic_card, parent)
          return false
        end
      SCRIPT
      item(:plastic_card, 'card', 'plastic') do
        self.desc = <<-DESC
          TRAVEL PERMIT issues to and for use of secret agent -
          SIGNED -"MAJOR I.RON.FOIL"
        DESC
        self.short_desc = "Plastic card"
        self.presence = "Plastic card"
        self.script_use = <<-SCRIPT
          puts "Script called"
          if args[0].nil?
            puts "Args nil"
            return false
          elsif args[0].tag != :smallslot
            puts "args not small slot"
            return false
          elsif get_room.open
            puts get_room.short_desc
            return false
          else
            puts "SHHHHH...sliding doors close."
            puts "The car hurtles along the tunnel at high speed"
            puts " and then jolts to a halt"
            puts "POING! Card pops out."
            
            dest = get_root.find(:tube_car).get_room.destination
            get_root.move(:tube_car, dest, false)
            
            return false
          end
        SCRIPT
      end
    end
  end
end