
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
AdminToggles = require '../../admin_ui/admin_toggles'
Folder = require '../../admin_ui/folder'

mkDevControlsElement = (address,admin) ->
  Folder.create {title:'Dev Controls',startOpen:false}, => [
    React.createElement AdminToggles, address: address, admin: admin
  ]

exports.view = (address,model) ->
  mkDevControlsElement(address,model.admin)

