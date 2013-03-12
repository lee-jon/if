# Adds debugging methods (REPL verbs) to player class.
#
class Player < Node
  
  # Public: Switches debugmode on and off
  #
  # If called with args that aren't ("on"|"off") it will return look for
  # the object and return that
  def do_debug(*a)
    puts "Recieved debug command with #{a}"

    if a[0] == "on"
      puts "Debug mode ON"
      $debugmode = true
    elsif a[0] == "off"
      $debugmode = false
      puts "Debug mode OFF"
    else
      puts get_root.find(a)
    end
  end
  
  #Public: Displays the node tree
  def do_tree(*a)
    return if $debugmode == false
    
    STDOUT.puts get_root
  end
  
  # Public: Checks if a node responds to a command.
  #
  # Returns log if item responds to command.
  # Returns script if a custom script is called during the command execution
  def do_respond(*words)
    return if $debugmode == false
    
    words1, words2 = *words
    
    item = get_root.find(words1)
    return if item.nil?
    
    command = "script_#{words2}"
    
    if item.respond_to?(command)
      puts "#{words1} responds to script_#{words2}."
      puts "Script called:\n +#{item.send(command)}" if !item.send(command).nil?
    else
      puts "no script found"
    end
  end
end

# Adds methods to the engine to assist in debugging
#
class Node < OpenStruct
  
  # Public: Overrides OpenStruct to_s method to visualise the node.
  #
  # Used in Node and Tree visualisation
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
