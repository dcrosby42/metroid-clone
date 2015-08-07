Immutable = require 'immutable'

DefaultHandlerDef = Immutable.Map(action: null, nextState: null)

StateMachine =
  processEvent: (fsm, state, event, obj) ->
    state ||= fsm.get('start')
    s1 = null
    handlerDef = fsm.getIn(['states',state,'events',event]) || DefaultHandlerDef
    if actionName = handlerDef.get('action')
      if action = obj[actionName]
        s1 = action.call(obj)
    return (s1 || handlerDef.get('nextState') || state)

  processEvents: (fsm, state, events, obj) ->
    s = state
    events.forEach (e) ->
      s = StateMachine.processEvent(fsm, s, e, obj)
    s

module.exports = StateMachine
