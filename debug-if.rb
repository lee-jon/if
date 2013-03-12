# Adds debugging methods to player class.

# Player verbs in debug mode
class Player < Node
  
  def do_displaytree(*a)
    STDOUT.puts get_root
  end
  
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
  
  def do_respond(*words)
    words1, words2 = *words
    
    item = get_root.find(words1)
    return if item.nil?
    
    command = "script_#{words2}"
    if item.respond_to?(command)
      puts "#{words1} responds to script_#{words2}:"
      puts item.send(command)
    else
      puts "no script found"
    end
  end

end

