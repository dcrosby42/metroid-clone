C = require '../../components'
T = C.Types
Enemies = require './enemies'
Drops = require './drops'

# {Animation,Position,Velocity,Name,Tag} = C.Types
Helpers = require './helpers'
{name,tag,buildComp} = Helpers

# 
General = require './general'
Object.assign(exports, General)

exports.enemy = (type,opts={}) ->
  builder = Enemies[type]
  if !builder?
    throw new Error("Prefab.enemy: no builder for type '#{type}'")
  return builder(opts)

exports.drop = Drops.build

  
