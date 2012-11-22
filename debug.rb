#!/usr/bin/env ruby
require 'yaml'
require 'readline'

# Fix loadpath and load Requirements
$: << '.'
require 'engine'
require 'player'
require 'grapher'

#
# game = eval(File.read('./games/seabase_delta.game.rb'))
#
#