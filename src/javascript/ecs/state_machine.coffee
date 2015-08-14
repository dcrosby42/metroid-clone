Immutable = require 'immutable'

DefaultHandlerDef = Immutable.Map(action: null, nextState: null)

StateMachine =
  processEvent: (fsm, state, event, obj) ->
    state ||= fsm.get('start')
    eventName = event.get('name')
    handlerDef = fsm.getIn(['states',state,'events',eventName]) || DefaultHandlerDef
    if actionName = handlerDef.get('action')
      if action = obj[actionName+"Action"]
        action.call(obj,event.get('data'))
    return (handlerDef.get('nextState') || state)

  processEvents: (fsm, state, events, obj) ->
    s = state
    events.forEach (e) ->
      s = StateMachine.processEvent(fsm, s, e, obj)
    s

module.exports = StateMachine
