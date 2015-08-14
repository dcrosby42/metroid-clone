
module.exports =
  systemType: 'output'

  update: (entityFinder, input, ui) ->

    res = entityFinder.search(['map'])
    # console.log "map sync system: res=", res.toJS()
    comps = res.first()
    # console.log "map sync system: comps=", comps.toJS()
    map = comps.get('map')
    # console.log "map sync system: map=", map.toJS()
    mapName = map.get('name')
    # console.log "map sync system: mapName=#{mapName}"

    _.forEach _.keys(ui.layers.maps), (name) ->
        container = ui.layers.maps[name]
        # console.log "  map sync system: name=#{name}, container=",container
        vis = (name == mapName)
        # console.log "  map sync system: vis=#{vis}"
        container.visible = vis
