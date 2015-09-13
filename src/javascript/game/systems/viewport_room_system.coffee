Immutable = require 'immutable'
BaseSystem = require '../../ecs/base_system'
MathUtils = require '../../utils/math_utils'

class ViewportRoomSystem extends BaseSystem
  @Subscribe: [
    ['viewport', 'position']
    ['room_watcher']
  ]

  process: ->

    viewport = @getComp('viewport')
    config = viewport.get('config')
    position = @getComp('viewport-position')

    worldMap = @input.getIn(['static','worldMap'])
    rooms = worldMap.searchRooms(
      position.get('y'), position.get('x'),
      position.get('y')+config.get('height'), position.get('x')+config.get('width')
    )

    roomIds = Immutable.Set(_.map(rooms, (r) -> r.id()))
    @setProp 'room_watcher', 'roomIds', roomIds


module.exports = ViewportRoomSystem

