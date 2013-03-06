# Debug methods

# Player verbs in debug mode
class Player < Node
  def do_debug(*a)
    STDOUT.puts get_root
  end
end

