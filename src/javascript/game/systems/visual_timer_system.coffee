BaseSystem = require '../../ecs/base_system'

class VisualTimerSystem extends BaseSystem
  @Subscribe: ['visual']

  process: ->
    unless @getProp('visual','paused')
      @updateProp 'visual', 'time', (t) => t + @input.get('dt')

instance = new VisualTimerSystem()

module.exports =
  config:
    filters: VisualTimerSystem.Subscribe

  update: (comps,input,u,eventBucket) ->
    instance.handleUpdate(comps, input, u, eventBucket)
