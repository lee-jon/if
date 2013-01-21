require "yaml"
require "ostruct"

# Public: The node class.
#
# A node which describes the data tree behaviour, and all methods
# to be called on a data node. Node inherits from (OpenStruct)[http://www.ruby-doc.org/stdlib-1.9.3/libdoc/ostruct/rdoc/OpenStruct.html]
# which is part of Ruby standard library. OpenStruct is like a Struct
# where you can also arbitrarily define attributes at runtime.ß
#
# Although any type of node is valid, the default types of root, room,
# item and player have their own constructors. These have their own
# key/value pairs.
#
# Example: Create the root node and then any number of child nodes. To
# recreate the first room of Zork (http://en.wikipedia.org/wiki/Zork)
# we could use the following code:
#
#   game = Node.root do
#     room(:west_of_house) do
#       player
#       item(:mailbox, 'mailbox') do
#         item(:leaflet, 'leaflet', 'small')
#       end
#       item(:rubber_mat, 'rubber', 'mat')
#     end
#   end

class Node < OpenStruct
  def init_with(c)
    c.map.keys.each do |k|
      instance_variable_set("@#{k}", c.map[k])
    end

    @table.keys.each do |k|
      new_ostruct_member(k)
    end
  end

  def self.save(node, file='save.yaml')
    File.open(file, 'w+') do |f|
      f.puts node.to_yaml
    end
  end

  def self.load(file='save.yaml')
    YAML::load_file(file)
  end

  def puts(*s)
    STDOUT.puts( s.join(' ').word_wrap )
  end

  # Public: Defaults for whether a node type is open or not.
  # When interacting with the game world, open nodes will show their
  # contents. If a node is also defined with openable? = true its :open
  # state can be changed using the ingame open and close commands.
  DEFAULTS = {
    :root => { :open => true },
    :room => { :open => true },
    :item => { :open => false },
    :scenery => { :open => false, :fixed => true },
    :player => { :open => true }
  }

  # Public: Initialize a node
  #
  # parent   - reference to the new node's parent node. This defaults to
  # nil if not given. nil should only be used for the root node.
  #            not given.
  # tag      - unique ID (as a symbol) given to the node
  # defaults - block containing default key/values of the node.
  # &block   - this enables us to define its children. instance_eval is
  # used instead of yield self, eliminating the need to think
  # of unique block parameter names. A node can accessed using
  # `self`.
  def initialize(parent=nil, tag=nil, defaults={}, &block)
    super()
    defaults.each {|k,v| send("#{k}=", v) }

    self.parent = parent
    self.parent.children << self unless parent.nil?
    self.tag = tag
    self.children = []

    instance_eval(&block) unless block.nil?
  end

  # Public: *Room* constructor.
  def room(tag, &block)
    Node.new(self, tag, DEFAULTS[:room], &block)
  end

  # Public: *Item* constructor.
  def item(tag, name, *words, &block)
    i = Node.new(self, tag, DEFAULTS[:item])
    i.name = name
    i.words = words
    i.instance_eval(&block) if block_given?
  end

  # Public: *Scenery* constructor
  #
  # used for item behaviour without item properties
  def scenery(tag, name, *words, &block)
    i = Node.new(self, tag, DEFAULTS[:scenery])
    i.name = name
    i.words = words
    i.instance_eval(&block) if block_given?
  end

  # Public: *Player* constructor.
  #
  # Requires: Player < Node to be defined.
  def player(&block)
    Player.new(self, :player, DEFAULTS[:player], &block)
  end

  # Public: *Root* constructor.
  def self.root(&block)
    Node.new(nil, :root, &block)
  end


  # Public: Traverses the tree until a room is found.
  #
  # This is useful because not all parents of items / player are rooms.
  # For example an item can be within an item.
  #
  # Returns: the room node on the called object.
  def get_room
    return self if parent.tag == :root
    parent.get_room
  end

  # Public: Traverses the tree upwards until the root node is found
  def get_root
    return self if tag == :root || parent.nil?
    parent.get_root
  end

  # Public:
  def ancestors(list=[])
    return list if parent.nil?

    list << parent
    parent.ancestors(list)
  end

  # Public: Helper, will return false if described == false or the
  # key/value isn't defined (nil) on the node.
  #
  # Returns true or false
  def described?
    if respond_to?(:described)
      self.described
    else
      false
    end
  end

  # Public: Constructs the node's description and outputs it to STDOUT
  #
  # Returns description or short description if described? is true.
  # Returns presence description of children if the node is open.
  def describe
    base = ""
    base += if !described? && respond_to?(:desc)
      self.described = true
      desc
    elsif respond_to?(:short_desc)
      short_desc
    else
      "I see nothing special"
    end

    if open && !children.empty?
      base += "<br>"
      if parent.tag != :root
        # If its not a room add this text, when it has child nodes
        base << "Inside it you see:" + "<br>"
      end
      children.each do |c|
        base << (c.presence || '')
        base += "<br>" unless c.presence.nil?
      end
    end

    puts base
  end

  # Public: Evaluates whether a node has a key for it's short description.
  #
  # Returns: self.short_desc if defined. Otherwise returns the node's tag
  # as a String.
  def short_description
    if respond_to?(:short_desc)
      short_desc
    else
      tag.to_s
    end
  end

  # Public: returns true if the node is hidden (a child in a closed node).
  def hidden?
    return false if parent.tag == :root
    return true  if parent.open == false
    parent.hidden?
  end

  # Public: This looks at the node to see whether there is a script
  #
  # Returns:
  # if true  - calls the script
  # if false - returns true
  def script(key, *args)
    return true unless respond_to?("script_#{key}")

    eval(self.public_send("script_#{key}"))
  end

  # Public: Moves the position of a Node in the tree from a parent to another
  # parent.
  #
  # Inputs:
  # thing - Node to be moved
  # to    - target parent Node
  # check - when false the method skips validating hidden items or whether a
  # node is open.
  #
  # Method calls find to get the object and destination nodes. If the
  # destination is hidden, or doesn't respond to 'self.open == true'
  # then the method replies it can't do that. Otherwise the object's parent
  # child-node reference is deleted, and this is added to the target's children
  # node. The parent of the object is set as the destination note
  #
  # Returns: Modifies the Node tree
  def move(thing, to, check=true)
    item = find(thing)
    dest = find(to)

    return if item.nil?
    if check && item.hidden?
      puts "You can't get to that right now"
      return
    end

    return if dest.nil?
    if check && (dest.hidden? || dest.open == false)
      puts "You can't put that there"
      return
    end

    if dest.ancestors.include?(item)
      puts "Are you trying to destroy the universe?"
      return
    end

    item.parent.children.delete(item)
    dest.children << item
    item.parent = dest
  end

  # Public: Helper method which evaluates the object and issues the correct
  # function to find the node described by 'thing'
  #
  # Returns Node found in by searching for thing or nil
  def find(thing)
    case thing
    when Symbol
      find_by_tag(thing)
    when String
      find_by_string(thing)
    when Array
      find_by_string(thing.join(' '))
    when Node
      thing
    end
  end

  def find_by_tag(tag)
    return self if self.tag == tag

    children.each do|c|
      res = c.find_by_tag(tag)
      return res unless res.nil?
    end

    return nil
  end

  def find_by_string(words)
    words = words.split unless words.is_a?(Array)
    nodes = find_by_name(words)

    if nodes.empty?
      puts "I don't see that here"
      return nil
    end

    # Score the nodes by number of matching adjectives
    nodes.each do |i|
      i.search_score = (words & i.words).length
    end

    # Sort the score so that highest scores are
    # at the beginning of the list
    nodes.sort! do |a,b|
      b.search_score <=> a.search_score
    end

    # Remove any nodes with a search score less
    # than the score of the first item in the list
    nodes.delete_if do |i|
      i.search_score < nodes.first.search_score
    end

    # Interpret the results
    if nodes.length == 1
      return nodes.first
    else
      puts "Which item do you mean?"
      nodes.each do |i|
        puts " * #{i.name} (#{i.words.join(', ')})"
      end

      return nil
    end
  end

  def find_by_name(words, nodes=[])
    words = words.split unless words.is_a?(Array)
    nodes << self if words.include?(name)

    children.each do |c|
      c.find_by_name(words, nodes)
    end

    return nodes
  end

  # Public: Overrides OpenStruct to_s method to visualise the node.
  def to_s(verbose=false, indent='')
    bullet = if parent && parent.tag == :root
               '#'
             elsif tag == :player
               '@'
             elsif tag == :root
               '>'
             elsif open == true
               'O'
             else
               '*'
             end

    str = "#{indent}#{bullet} #{tag}\n"
    if verbose
      self.table.each do|k,v|
        if k == :children
          str << "#{indent+'  '}#{k}=#{v.map(&:tag)}\n"
        elsif v.is_a?(Node)
          str << "#{indent+'  '}#{k}=#{v.tag}\n"
        else
          str << "#{indent+'  '}#{k}=#{v}\n"
        end
      end
    end

    children.each do|c|
      str << c.to_s(verbose, indent + '  ')
    end

    return str
  end
end

# Public: adds word_wrap method to String for better screen formatting.
class String
  def word_wrap(width=80)
    # Replace newlines with spaces
    gsub(/\n/, ' ').

    # Replace more than one space with a single space
    gsub(/\s+/, ' ').

    # Replace spaces at the beginning of the
    # string with nothing
    gsub(/^\s+/, '').

    # This one is hard to read.  Replace with any amount
    # of space after it with that punctuation and two
    # spaces
    gsub(/([\.\!\?]+)(\s+)?/, '\1  ').

    # Similar to the call above, except replace commas
    # with a comma and one space
    gsub(/\,(\s+)?/, ', ').

    # The meat of the method, replace between 1 and width
    # characters followed by whitespace or the end of the
    # line with that string and a newline.  This works
    # because regular expression engines are greedy,
    # they'll take as many characters as they can.
    gsub(%r[(.{1,#{width}})(?:\s|\z)], "\\1\n").

    # Now add some paragraphs
    gsub(/<br>/, "\n")
  end
end
