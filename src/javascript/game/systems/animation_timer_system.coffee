BaseSystem = require '../../ecs/base_system'

class AnimationTimerSystem extends BaseSystem
  @Subscribe: ['animation']

  process: ->
    unless @getProp('animation','paused')
      @updateProp 'animation', 'time', (t) => t + @input.get('dt')

module.exports = AnimationTimerSystem
