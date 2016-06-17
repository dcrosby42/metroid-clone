Immutable = require 'immutable'

DefaultHandlerDef = Immutable.Map(action: null, nextState: null)

processEvent = (fsm, state, event, obj) ->
  state ||= fsm.get('start')
  eventName = event.get('name')
  # console.log "StateMachine: event", event.toJS()
  handlerDef = fsm.getIn(['states',state,'events',eventName]) || DefaultHandlerDef
  
  nextState = getNextState(handlerDef,state,event,obj)
  # if actionName = handlerDef.get('action')
  #   if action = obj[actionName+"Action"]
  #     action.call(obj,event.get('data'))
  return nextState

getNextState = (handlerDef, state, event, obj) ->
  if cond = handlerDef.get('condition')
    if condName = cond.get('if')
      if condFn = obj["#{condName}Condition"]
        res = condFn.call(obj,event.get('data'))
        if res and thenHandler = cond.get('then')
          return getNextState(thenHandler,state,event,obj)
    return state
  else
    if actionName = handlerDef.get('action')
      if action = obj[actionName+"Action"]
        action.call(obj,event.get('data'))

    if nextState = handlerDef.get('nextState')
      return nextState

  return state

StateMachine =

  processEvents: (fsm, state, events, obj) ->
    s = state
    events.forEach (e) ->
      s = processEvent(fsm, s, e, obj)
    s

module.exports = StateMachine
