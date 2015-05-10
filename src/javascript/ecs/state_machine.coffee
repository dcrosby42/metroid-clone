module.exports =
  update: (fsm, comps, input, u) ->
    fullProperty = fsm.get('property')
    states = fsm.get('states')

    [type,property] = fullProperty.split('.')

    component = comps.get(type)
    s0 = component.get(property)

    s1 = null
    updateFn = states.getIn([s0, 'update'])
    if updateFn?
      s1 = updateFn(comps,input,u)

    if s1? and s1 != s0
      u.update component.set(property, s1)
      enterFn = states.getIn([s1, 'enter'])
      if enterFn?
        enterFn(comps,input,u)
