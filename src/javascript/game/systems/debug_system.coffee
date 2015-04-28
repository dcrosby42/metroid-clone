module.exports =
  systemType: 'output'

  update: (entityFinder,input,ui) ->
    entityFinder.allComponentsByCid().forEach (comp) ->
        ui.componentInspector.update comp
