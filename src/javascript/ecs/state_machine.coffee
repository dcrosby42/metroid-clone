module.exports =
  update: (fsm, comps, input, u) ->
    fullProperty = fsm.get('property')
    states = fsm.get('states')

    [compName,property] = fullProperty.split('.')

    component = comps.get(compName)
    s0 = component.get(property)

    s1 = null
    updateFn = states.getIn([s0, 'update'])
    if updateFn?
      s1 = updateFn(comps,input,u)

    if s1? and s1 != s0
      updatedComponent = component.set(property, s1)
      u.update updatedComponent
      enterFn = states.getIn([s1, 'enter'])
      if enterFn?
        comps = comps.set compName, updatedComponent # Ensure any changes to component within enterFn are using the updated component
        enterFn(comps,input,u)
