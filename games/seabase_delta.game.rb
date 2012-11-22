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
      self.openable = false
      self.short_desc = "Dead body."
      self.presence   = "Dead body."
      self.desc = "No signs of life - perhaps his pockets..."
      self.script_take = <<-SCRIPT
        puts "Thanks-but NO THANKS!"
        return false
      SCRIPT
      
      item(:plastic_card, 'plastic-card', 'plastic', 'card') do
        self.desc = <<-DESC
          TRAVEL PERMIT issues to and for use of secret agent -
          SIGNED -"MAJOR I.RON.FOIL"
        DESC
        self.short_desc = "Plastic card"
        self.presence = "Plastic card"
      end
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
    item(:seaweed, 'seaweed') do
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
    self.direction  = :station_delta
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
    item(:rail_tracks, 'rail-tracks', 'tracks') do
      self.desc = "OUCH! Your hair stands on end!"
      self.presence = "Rail-tracks"
    end
  end
  
  room(:carriage) do
    self.desc = <<-DESC 
      I'm in the Travel-Tube car. A metallic voice from the
      loudspeaker-"CLUNK-CLICK OR YOU'RE SURE TO BE SICK"
    DESC
    self.short_desc = <<-DESC
      Travel-tube car.
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
  end
  
  room(:void) do
    self.desc = "You are in the void - how did you get here"
    item(:tube_car, 'car') do
      self.presence = "Travel-Tube car"
      self.script_enter = <<-SCRIPT
        get_root.move(:player, :carriage)
        return false
      SCRIPT
    end
    item(:mover, 'mover', 'metallic') do
      self.presence = "The mover is here."
    end
  end
end