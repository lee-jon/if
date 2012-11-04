#!/usr/bin/env ruby
#
# Grapher requires svg2png installed on OSX 
# brew install svg2png if you have homebrew installed

class Node < OpenStruct
  def graph(gr=Graph.new)
    gr.edge tag.to_s, parent.tag.to_s unless parent.nil?
    gr.node_attribs << gr.filled

    if tag == :player || tag == :root
      gr.tomato << gr.node(tag.to_s)
    elsif parent && parent.tag == :root
      gr.mediumspringgreen << gr.xnode(tag.to_s)
    end

    children.each{|c| c.graph(gr) }
    return gr
  end

  def save_graph
    graph.save 'graph', 'svg'
    `svg2png graph.svg graph.png`
    `open graph.png`
  end

  def map(gr=Graph.new)
    if parent && parent.tag == :root
      methods.grep(/^exit_[a-z]+(?!=)$/) do|e|
        dir = e.to_s.split(/_/).last.split(//).first
        gr.edge(tag.to_s, send(e).to_s).label(dir)
      end
    end

    children.each{|c| c.map(gr) }
    return gr
  end

  def save_map
    map.save 'map', 'svg'
    `svg2png map.svg map.png`
    `open map.png`
  end
end