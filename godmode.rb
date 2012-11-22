#!/usr/bin/env ruby
# Debug environment for IF
require 'yaml'
require 'readline'

# Fix loadpath and load Requirements
$: << '.'
require 'engine'
require 'player'
require 'grapher'

game = eval(File.read('./games/seabase_delta.game.rb'))
player = game.find(:player)