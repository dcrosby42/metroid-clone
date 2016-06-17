C = require '../../components'
T = C.Types
Enemies = require './enemies'

# {Animation,Position,Velocity,Name,Tag} = C.Types
Helpers = require './helpers'
{name,tag,buildComp} = Helpers

# 
General = require './general'
Object.assign(exports, General)

exports.enemy = (type,opts={}) ->
  enemyBuilder = Enemies[type]
  if !enemyBuilder?
    throw new Error("Prefab: no builder for type '#{type}'")
  return enemyBuilder(opts)

exports.stash = (entity, name,comp) ->
  stashed = buildComp T.Stashed, stashed: comp, name: name
  entity.addComponent comp
  # entity.deleteComponent comp
  return stashed

exports.unstash = (entity,name)->
  restored = null
  entity.each T.Stashed, (st) ->
    if st.name == name
      restored = st.stashed
      entity.addComponent
      entity.deleteComponent st
  return restored
      

  
