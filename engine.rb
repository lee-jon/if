#!/usr/bin/env ruby
require "yaml"
require "ostruct"

class Node < OpenStruct
  def init_with(c)
    c.map.keys.each do|k|
      instance_variable_set("@#{k}", c.map[k])
    end

    @table.keys.each do|k|
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


  DEFAULTS = {
    :root => { :open => true },
    :room => { :open => true },
    :item => { :open => false },
    :player => { :open => true }
  }

  def initialize(parent=nil, tag=nil, defaults={}, &block)
    super()
    defaults.each {|k,v| send("#{k}=", v) }

    self.parent = parent
    self.parent.children << self unless parent.nil?
    self.tag = tag
    self.children = []

    instance_eval(&block) unless block.nil?
  end


  def room(tag, &block)
    Node.new(self, tag, DEFAULTS[:room], &block)
  end

  def item(tag, name, *words, &block)
    i = Node.new(self, tag, DEFAULTS[:item])
    i.name = name
    i.words = words
    i.instance_eval(&block) if block_given?
  end

  def player(&block)
    Player.new(self, :player, DEFAULTS[:player], &block)
  end

  def self.root(&block)
    Node.new(nil, :root, &block)
  end


  def get_room
    if parent.tag == :root
      return self
    else
      return parent.get_room
    end
  end

  def get_root
    if tag == :root || parent.nil?
      return self
    else
      return parent.get_root
    end
  end

  def ancestors(list=[])
    if parent.nil?
      return list
    else
      list << parent
      return parent.ancestors(list)
    end
  end


  def described?
    if respond_to?(:described)
      self.described
    else
      false
    end
  end

  def describe
    base = ""
    base += if !described? && respond_to?(:desc)
      self.described = true
      desc
    elsif respond_to?(:short_desc)
      short_desc
    else
      "#{tag}"
    end

    # Append presence of children nodes if open
    if open
      if parent.tag != :root
        # If its not a room add this text
        base << "Inside it you see "
      end
        
      children.each do |c|
        base << (c.presence || '')
      end
    end

    puts base
  end

  def short_description
    if respond_to?(:short_desc)
      short_desc
    else
      tag.to_s
    end
  end


  def hidden?
    if parent.tag == :root
      return false
    elsif parent.open == false
      return true
    else
      return parent.hidden?
    end
  end


  def script(key, *args)
    if respond_to?("script_#{key}")
      return eval(self.send("script_#{key}"))
    else
      return true
    end
  end


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
    gsub(%r[(.{1,#{width}})(?:\s|\z)], "\\1\n")
  end
end
