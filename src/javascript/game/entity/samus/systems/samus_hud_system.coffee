BaseSystem = require '../../../../ecs/base_system'

class SamusHudSystem extends BaseSystem
  @Subscribe: [
    ['samus', 'health']
    ['hud', 'label']
  ]

  process: ->
    # samus = @getComp('samus')
    # samusHealth = @getComp('samus-health')
    # hud = @getComp('hud')
    # hudLabel = @getComp('hud-label')
    @setProp 'hud-label', 'content', "E.#{@getProp('samus-health','hp')}"

module.exports = SamusHudSystem

