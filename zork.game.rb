Node.root do
  self.intro = <<-INTRO
    Welcome to Zork - IF implementation.
    INTRO
  self.help = <<-HELP
    Help not implemented yet :(.
    HELP

  room(:west_of_house) do
    self.desc = <<-DESC
      You are in an open field on the west side of a white house with a
      boarded front door.
      DESC
    self.short_desc = <<-DESC
      West of House.
      DESC
    item(:mailbox, 'mailbox', 'box', 'mail-box') do
      self.fixed = true
      self.openable = true
      self.desc = "It is a small mailbox."
      self.presence = <<-PRES
        There is a small mailbox here.
        PRES
      item(:leaflet, 'leaflet', 'small') do
        self.desc = <<-DESC
          Welcome to Zork!

          Zork in as game of adventure danger, and low cunning.
          In it you will explore some of the most amazing territory ever seen by mortal man. Hardened adventurers have run screaming from the terrors contained within.
          In Zork, the intrepid explorer delves into the forgotten secrets of a lost labyrinth deep in the bowels of the earth, searching for vast treasures long hidden from prying eyes, treasures guarded by fearsome monsters and diabolical traps!
          No system should be without one!
          \n
          Zork was created at the MIT laboratory for Comuter Science by
          Tim Anderson, Marc Blank, Bruce Daniels, and Dave Lebling.
          It was inspired by the Adventure game of Crowther and Woods,
          and the long tradition of fantasy and science fiction games.

          On-line information may be obtained with the HELP (synonyms are
          ABOUT, INFO, HINT, etc.).
        DESC
        self.short_desc = "A leaflet."
        self.presence = "There is a small leaflet here."
      end
    end

    self.item(:rubber_mat, 'mat') do
      self.size = 12
      self.desc = <<-DESC
        The mat says 'Welcome to Zork'.
      DESC
      self.short_desc = "A rubber mat."
      self.presence = <<-PRES
        A rubber mat saying 'Welcome to Zork' lies by the door.
      PRES
    end

    player do
      item(:business_card, 'card', 'business', '200gsm') do
      end
    end

  end
end