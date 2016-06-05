#!/usr/bin/env ruby

require_relative 'mk_index'

root = File.expand_path(File.dirname(__FILE__) + "/..")

game = "#{root}/src/javascript/game"
game2 = "#{root}/src/javascript/game2"
view = "#{root}/src/javascript/view"
view2 = "#{root}/src/javascript/view2"

[
  "#{game}/systems",
  "#{game}/entity/samus/systems",
  "#{game}/entity/enemies/systems",
  "#{game}/entity/doors/systems",
  "#{game2}/systems",
  "#{view}/systems",
  "#{view2}/systems",
].each do |dir|
  MkIndex.run(dir)
end
