C = require '../../components'
T = C.Types
Enemies = require './enemies'

# {Animation,Position,Velocity,Name,Tag} = C.Types
# Helpers = require './helpers'
# {name,tag,buildComp} = Helpers

# 
General = require './general'
Object.assign(exports, General)

exports.enemy = (type,opts={}) ->
  enemyBuilder = Enemies[type]
  if !enemyBuilder?
    throw new Error("Prefab: no builder for type '#{type}'")
  return enemyBuilder(opts)
