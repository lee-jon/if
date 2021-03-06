# Player class
# Player is an extension of the player node type, giving player
# specific methods which respond to the input verbs in the game.
# This class should contain only canonical verbs. Game specific terms
# can be included the game file which is evaluated at run time.

class Player < Node

  # Public: command separates the arguments into a verb and words
  # Returns: sends associated arguments to verb methods
  def command(words)
    verb, *words = words.split(' ')
    verb = "do_#{verb}"

    if $debugmode == true
      puts "Requesting command #{verb} for words #{words} from player."
    end

    if respond_to?(verb)
      if $debugmode == true
        puts "Player responding to method call sending #{words}"
      end

      send(verb, *words)
    else
      puts "I don't know how to do that"
    end
  end

  # Public: Returns the available verb methods
  def self.game_methods
    available = self.instance_methods.grep /do/
    available.collect {|i| i.to_s.gsub('do_','')}
  end

  # Public: moves the player in the direction
  #
  # Method checks the destination node to see whethere there is a script
  # to execute first.
  def do_go(direction=nil, *a)
    dest = get_room.send("exit_#{direction}")

    if dest.nil?
      puts "You can't go that way"
    else
      dest = get_root.find(dest)

      if dest.script('enter', direction)
        get_root.move(self, dest)
      end

      get_room.describe
    end
  end

  %w{ north south east west up down }.each do|dir|
    define_method("do_#{dir}") do
      do_go(dir)
    end

    alias_method :"do_#{dir[0]}", :"do_#{dir}"
  end

  def do_take(*thing)
    thing = get_room.find(thing)

    return if thing.nil?

    if thing.fixed == true
      puts "This cannot be taken."
      return
    end

    if thing.script('take') && get_root.move(thing, self)
      puts 'Taken.'
    end
  end
  alias_method :do_get, :do_take

  def do_drop(*thing)
    thing = get_room.find(thing)
    return if thing.nil?

    if thing.fixed
      puts "You can't drop that."
      return
    end

    puts 'Dropped.' if move(thing, get_room)
  end

  def open_close(thing, state)
    container = get_room.find(thing)
    return if container.nil?

    if container.openable == true
      if container.open == state
        puts "It's already #{state ? 'open' : 'closed'}"
      else
        puts "OK."
        container.open = state
      end
    else
      puts "I cannot #{state ? 'open' : 'close'} that"
    end
  end

  def do_open(*thing)
    if open_close(thing, true)
      item = get_room.find(thing)

      item.script('open')
    end
  end

  def do_close(*thing)
    open_close(thing, false)
  end

  def do_look(*a)
    get_room.tap do |r|
      r.described = false
      r.describe
    end
  end

  def do_examine(*thing)
    item = get_room.find(thing)
    return if item.nil?

    if item.script('examine')
      item.described = false
      item.describe
    end
  end
  alias_method :do_ex, :do_examine

  def do_read(*thing)
    item = get_room.find(thing)
    return if item.nil?

    if item.script('read')
      puts "You cannot read that"
    end
  end

  def do_inventory(*a)
    puts "You are carrying:"

    unless children.empty?
      children.each do|c|
        puts " * #{c.short_description} (#{c.words.join(' ')})"
      end
    else
      puts " * Nothing"
    end
  end
  alias_method :do_inv, :do_inventory
  alias_method :do_i, :do_inventory

  def do_put(*words)
    puts "recieved #{words}"
    prepositions = [' in ', ' on ']

    prep_regex = Regexp.new("(#{prepositions.join('|')})")
    item_words, _, cont_words = words.join(' ').split(prep_regex)

    if cont_words.nil?
      puts "You want to put what where?"
      return
    end

    item = get_room.find(item_words)
    container = get_room.find(cont_words)

    return if item.nil? || container.nil?

    if container.script('accept', item)
      get_room.move(item, container)
    end
  end

  def do_climb(*words)
    prepositions = [' in ', ' on ']

    prep_regex = Regexp.new("(#{prepositions.join('|')})")
    item_words, _, cont_words = words.join(' ').split(prep_regex)

    item = get_room.find(item_words)
    return if item.nil?

    if item.script('climb')
      puts "You cannot climb on that"
    end

  end

  def do_use(*words)
    prepositions = %w{ in on with the }
    prepositions.map!{|p| " #{p} " }

    prep_regex = Regexp.new("(#{prepositions.join('|')})")
    item1_words, _, item2_words = words.join(' ').split(prep_regex)

    # if item2_words.nil?
    #   puts "I don't quite understand you"
    #   return
    # end

    item1 = get_room.find(item1_words)
    item2 = get_room.find(item2_words)
    # return if item1.nil? || item2.nil?
    return if item1.nil?

    if item1.script('use', item2)
      puts "I don't know how to use that."
    end
  end
  alias_method :do_sign, :do_use
  alias_method :do_insert, :do_use

  def do_pull(*words)
    item = get_room.find(words)
    return if item.nil?

    item.script('pull')
  end

  def do_push(*words)
    item = get_room.find(words)
    return if item.nil?

    item.script('push')
  end

  def do_enter(*words)
    item = get_room.find(words)
    return if item.nil?

    if item.script('enter')
      puts "Its not possible to do that."
    end
  end

  def do_exit(*word)
    # Note unlike enter, exit uses get_root for the item, and the room for
    # the script.
    item = get_root.find(word)
    return if item.nil?

    room = self.parent
    parent.script('exit')
  end
  alias_method :do_leave, :do_exit

end
