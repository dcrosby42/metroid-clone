BaseSystem = require '../../ecs/base_system'

class SoundSystem extends BaseSystem
  @Subscribe: ['sound']

  process: ->
    sound = @getComp('sound')
    newPlayPosition = sound.get('playPosition') + @dt()
    if newPlayPosition > sound.get('timeLimit')
      if sound.get('loop')
        @updateComp sound.set('playPosition', 0)
      else
        @deleteComp sound
    else
      @updateComp sound.set('playPosition', newPlayPosition)

module.exports = SoundSystem
