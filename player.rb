# requires engine to describe Node behaviour

class Player < Node
  def command(words)
    verb, *words = words.split(' ')
    verb = "do_#{verb}"

    if respond_to?(verb)
      send(verb, *words)
    else
      puts "I don't know how to do that"
    end
  end

  def do_go(direction, *a)
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

    define_method("do_#{dir[0]}") do
      do_go(dir)
    end
  end

  def do_take(*thing)
    thing = get_room.find(thing)
    return if thing.nil?

    if thing.script('take')
      puts 'Taken.' if get_root.move(thing, self)
    end
  end
  alias_method :do_get, :do_take

  def do_drop(*thing)
    move(thing, get_room)
  end

  def open_close(thing, state)
    container = get_room.find(thing)
    return if container.nil?

    if container.openable == true
      if container.open == state
        puts "It's already #{state ? 'open' : 'closed'}"
      else
        container.open = state
      end
    else
      puts "I cannot #{state ? 'open' : 'close'} that"
    end
  end

  def do_open(*thing)
    open_close(thing, true)
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

    item.described = false
    item.describe
  end
  alias_method :do_ex, :do_examine

  def do_inventory(*a)
    puts "You are carrying:"

    if children.empty?
      puts " * Nothing"
    else
      children.each do|c|
        puts " * #{c.short_description} (#{c.words.join(' ')})"
      end
    end
  end
  alias_method :do_inv, :do_inventory
  alias_method :do_i, :do_inventory

  def do_put(*words)
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

  def do_use(*words)
    prepositions = %w{ in on with }
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

    item1.script('use', item2)
  end
  alias_method :do_sign, :do_use

  def do_debug(*a)
    STDOUT.puts get_root
  end

  def play
    loop do
      do_look
      print "What now? "
      command(gets.chomp)
    end
  end
end
