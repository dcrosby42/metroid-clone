_ = require 'lodash'
SystemsRunner = require './systems_runner'

class SystemRegistry
  constructor: ->
    @_registry = {}

  sequence: (systemSpecs) ->
    systems = _.map systemSpecs, (s) =>
      if _.isArray(s)
        [name,config] = s
        @create name,config
      else
        @create s
    new SystemsRunner(systems)

  create: (name,config=null) ->
    clazz = @_registry[name]
    if clazz?
      if config?
        new clazz(config)
      else
        new clazz()
    else
      console.log "Systems.create FAILED: no constructor for '#{name}'"

  register: (name,clazz) ->
    if _.isPlainObject(name)
      _.forOwn name, (clazz,name) ->
        @register name,clazz
    else
      @_registry[name] = clazz

module.exports = SystemRegistry

