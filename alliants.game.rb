Node.root do
  self.intro = <<-INTRO

    Welcome to the Alliants test game. This is based around our offices.
    All likenesses to any real people is completely on purpose and you
    probably should get offended.

    Type help for a list of commands.
    INTRO
  self.help = <<-HELP
Here are a list of active commands:
    Movement      = north, south, east, west, up, down
                    See the room description for allowed directions.
    get  <obj>    = pick up the object and put in inventory, Also: take
    drop <obj>    = put down object in room
    inventory     = list items held by player
                    Also: inv, i
    look          = describe the room again in long form.
    examine <obj> = look at object
    ex            = ALIAS for examine
    open <obj>    = open container or object
    close <obj>   = close container or object
    HELP

  room(:downstairs_office) do
    self.exit_north = :universal_marina
    self.exit_up    = :upstairs_office
    self.exit_down  = :void
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
        The manequin has a male torso and a horses head.
        Like a reverse centaur.
        DESC
      self.presence = <<-PRES
        A manequin is stood here looking ominous.
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
          A business card is lying on the floor.
          PRES
      end
      item(:bacon_sandwich, 'sandwich', 'bacon') do
        self.desc = <<-DESC
          Its a bacon sandwich on rye bread, tomato sauce has leaked out and
          soaked into the bread. There's something about this that tells
          you it is Friday.
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
      You are stood by some stairs leading down. To the north is a
      glass-fronted meeting room and to the west is more office space.
      DESC
    self.short_desc = <<-DESC
      Upstairs office.
      DESC
  end
  room (:meeting_room) do
    self.exit_south = :upstairs_office
    self.desc = <<-DESC
      You are in a typical meeting room. There is a table in front of you
      that looks like its made of a glass panel on top of an aircraft
      wing. The wall on one side of the room is covered in whiteboard paint.
      There is a television at another end. The room smells of work and men.
      DESC
    self.short_desc = "Meeting room."
    self.item(:whiteboard, 'whiteboard', 'wall') do
    end
    self.item(:wing_table, 'table', 'wing') do
    end
  end
  room (:recruiters_office) do
    self.exit_east  = :upstairs_office
    self.desc = <<-DESC
      You are stood in the recruitment side of the office. There is no lime
      green here. Only company blue - which you not is Pantone 308. The
      recruiters are here but seem engrossed in what they're doing.
      DESC
    self.short_desc = "Recruitment office."

    item(:timesheet, 'timesheet', 'blank') do
      self.open = true
      self.desc = <<-DESC
        The time sheet has an Alliants logo on the top and boxes blank to
        enter your hours in it. Someone should automate this process. It
        seems laborious. You notice that the logo hasn't been placed
        properly, and that its been slightly distored.
        DESC
      self.short_desc = <<-DESC
        A paper timesheet.
        DESC
      self.presence  = <<-PRES
        A paper timesheet is lying here.
        PRES
      self.script_sign = <<-SCRIPT
        if !parent.find(:pen)
          puts "with what exactly?"
          return
        end
        SCRIPT
    end
  end
  room(:universal_marina) do
    self.exit_west  = :boat_universal
    self.exit_south = :downstairs_office
    self.desc = <<-DESC
      You are stood in Universal Marina. It is a clear day and
      brilliant blue sky shines through the masts of the ships.
      Office blocks are to the south, and the boats are to the west.
      DESC
    self.short_desc = <<-DESC
      You are stood within Universal Marina.
      DESC
    self.script_enter = <<-SCRIPT
        puts "Donna screams at you, no leaving the office until you've
              completed your timesheets."
        return false
      SCRIPT
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
  room(:void) do
    self.exit_up  = :downstairs_office
    item(:signed_timesheet, 'timesheet', 'signed') do
      self.desc = <<-DESC
        The timesheet with the misaligned logo is now decorated with all the
        hours you've worked in the last month. All you need to do now is
        find Donna and give it to her.
        DESC
      self.short_desc = <<-DESC
        A signed timesheet
        DESC
      self.presence = <<-PRES
        A complete and signed timesheet is lying here.
        PRES
    end
  end
end
