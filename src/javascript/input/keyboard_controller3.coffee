MousetrapWrapper = require '../vendor/mousetrap_wrapper'
Immutable = require 'immutable'
ControllerEvent = require './controller_event'

bindKey = (key,control,address) ->
  MousetrapWrapper.bind(key,
    (-> address.send ControllerEvent.create(control, 'down')),
    'keydown')
  MousetrapWrapper.bind(key,
    (-> address.send ControllerEvent.create(control, 'up')),
    'keyup')

exports.bindKeys = (address, mappings) ->
  for k,c of mappings
    bindKey(k,c,address)
