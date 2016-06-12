
TheGame = require '../states/the_game'
Admin = require '../../game/states/admin'

class Model
  constructor: (@game,@history,@admin) ->

exports.initialState = () ->
  model = new Model(
    TheGame.initialState()
    "TODO: History"
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
  else
    model.game = TheGame.update(model.game, input)

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

