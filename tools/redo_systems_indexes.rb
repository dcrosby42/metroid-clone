#!/usr/bin/env ruby

require_relative 'mk_index'

root = File.expand_path(File.dirname(__FILE__) + "/..")

game = "#{root}/src/javascript/game"
view = "#{root}/src/javascript/view"

[
  "#{game}/systems",
  "#{game}/entity/samus/systems",
  "#{game}/entity/enemies/systems",
  "#{view}/systems",
].each do |dir|
  MkIndex.run(dir)
end
