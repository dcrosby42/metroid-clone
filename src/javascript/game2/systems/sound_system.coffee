BaseSystem = require '../../ecs/base_system'
BaseSystem = require '../../ecs2/base_system'
C = require '../../components'
T = C.Types

class SoundSystem extends BaseSystem
  @Subscribe: [T.Sound]

  process: (r) ->
    sound = r.comps[0]
    newPlayPosition = sound.playPosition + @dt()
    if newPlayPosition > sound.timeLimit
      if sound.loop
        sound.playPosition = 0
      else
        if sound.selfDestruct
          r.entity.destroy()
        else
          r.entity.deleteComponent(sound)
    else
      sound.playPosition = newPlayPosition

module.exports = -> new SoundSystem()
