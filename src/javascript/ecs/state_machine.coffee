module.exports =
  update: (stateVarIndicator, stateConfigs, comps, input, u) ->
    [type,prop] = stateVarIndicator.split('.')

    component = comps.get(type)
    s0 = component.get(prop)

    s1 = null
    updateFn = stateConfigs.getIn([s0, 'update'])
    if updateFn?
      s1 = updateFn(comps,input,u)

    if s1? and s1 != s0
      u.update component.set(prop, s1)
      enterFn = stateConfigs.getIn([s1, 'enter'])
      if enterFn?
        enterFn(comps,input,u)
