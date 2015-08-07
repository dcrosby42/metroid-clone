BaseSystem = require '../../ecs/base_system'

class VisualTimerSystem extends BaseSystem
  @Subscribe: ['visual']

  process: ->
    unless @getProp('visual','paused')
      @updateProp 'visual', 'time', (t) => t + @input.get('dt')

module.exports = VisualTimerSystem
