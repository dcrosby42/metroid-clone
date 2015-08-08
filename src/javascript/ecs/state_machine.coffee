Immutable = require 'immutable'

DefaultHandlerDef = Immutable.Map(action: null, nextState: null)

StateMachine =
  processEvent: (fsm, state, event, obj) ->
    state ||= fsm.get('start')
    handlerDef = fsm.getIn(['states',state,'events',event]) || DefaultHandlerDef
    if actionName = handlerDef.get('action')
      if action = obj[actionName+"Action"]
        action.call(obj)
    return (handlerDef.get('nextState') || state)

  processEvents: (fsm, state, events, obj) ->
    s = state
    events.forEach (e) ->
      s = StateMachine.processEvent(fsm, s, e, obj)
    s

module.exports = StateMachine
