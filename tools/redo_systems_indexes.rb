#!/usr/bin/env ruby

require_relative 'mk_index'

root = File.expand_path(File.dirname(__FILE__) + "/..")

game = "#{root}/src/javascript/game"

[
  "#{game}/systems",
  "#{game}/entity/samus/systems",
  "#{game}/entity/enemies/systems",
].each do |dir|
  MkIndex.run(dir)
end
