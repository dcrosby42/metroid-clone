Immutable = require 'immutable'

default = Immutable.fromJS
  systems: []


createSystem = (props) ->
  system = Immutable.fromJS(props)
  
  
