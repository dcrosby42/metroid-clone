
TheGame = require '../states/the_game'
Admin = require '../../game/states/admin'
RollingBuffer = require '../../utils/rolling_buffer'

class Model
  constructor: (@game,@history,@admin) ->

exports.initialState = () ->
  model = new Model(
    TheGame.initialState()
    new RollingBuffer(5*60)
    Admin.initialState()
  )
  # console.log "DevUI model",model
  model

exports.update = (model,input) ->
  admin = Admin.update(input, model.admin)
  if admin.get('paused')
    if admin.get('step_forward')
      input1 = input.set('dt', admin.get('stepDt'))
      model.game = TheGame.update(model.game, input1)
      console.log "truncating history cuz step while paused"
      model.history.truncate()
      model.history.add(model.game.clone())

    else if admin.get('replay_back')
      model.history.back()
      model.game = model.history.current()

    else if admin.get('replay_forward')
      model.history.forward()
      model.game = model.history.current()

  else
    model.game = TheGame.update(model.game, input)
    if admin.get('truncate_history')
      console.log "truncating history cuz admin said too"
      model.history.truncate()
    model.history.add(model.game.clone())

  model.admin = admin
  model

#
# VIEW
#
React = require 'react'
{div,span,table,tbody,td,tr} = React.DOM

AdminToggles = require '../../admin_ui/admin_toggles'
Folder = require '../../admin_ui/folder'
Structures = require '../../admin_ui/structures'


exports.view = (address,model) ->
  div {key:'wat'}, [
    Folder.create {title:'Dev Controlz',startOpen:false, folderkey:'devctrls'}, =>
      [
        React.createElement AdminToggles, address: address, admin: model.admin, key: 'admintoggles'
      ]
    Folder.create {title:'Entities',startOpen:false,folderkey:'entityinsp'}, =>
      entities = mutableEstoreToEntityMap(model.game.gameState)
      [
        React.createElement Structures.FilterableMap, data: entities, key: 'entities'
      ]
  ]

Immutable = require 'immutable'
{Map,List,OrderedMap} = Immutable
C = require '../../components'
T = C.Types

mutableEstoreToEntityMap = (estore) ->
  entities = OrderedMap()
  estore.eachEntity (entity) ->
    # window.entity = entity
    # throw new Error("boom")
    name = entity.get(T.Name)
    name = if name?
      "#{name.name} (e#{entity.eid})"
    else
      "e#{entity.eid}"

    compsByType = OrderedMap()
    entity.eachComponentType (type) ->
      if type != T.Name
        typeName = T.nameFor(type)
        compList = List()
        entity.each type, (comp) ->
          immComp = OrderedMap()
          for key,val of comp
            if key != 'eid' and key != 'type' and typeof comp[key] != 'function'
              val = if val? and typeof val == 'object'
                if typeof val['length'] == 'number'
                  List(val)
                else
                  OrderedMap(val)
              else
                val
              immComp = immComp.set(key,val)
          compList = compList.push(immComp)

        compsByType = compsByType.set(typeName,compList)

    entities = entities.set(name, compsByType)
  entities
