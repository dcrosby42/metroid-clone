Common = require '../../components'

# tweak = {x:0,y:0}
# window.tweak = tweak
GUN_SETTINGS =
  x_offset: 10
  y_offset: -22
  muzzle_velocity: 200/1000
  bullet_life: 50 / (200/1000)

class SamusWeapon

  run: (estore,dt,input) ->
    for samus in estore.getComponentsOfType('samus')
      position = estore.getComponent(samus.eid, 'position')

      switch samus.weaponTrigger
        when 'released'
          0
        when 'pulled'
          xoff = GUN_SETTINGS.x_offset
          vel = GUN_SETTINGS.muzzle_velocity

          if samus.direction == 'left'
            xoff = -xoff
            vel = -vel

          fireX = position.x + xoff
          fireY = position.y + GUN_SETTINGS.y_offset

          estore.createEntity [
            new Common.Visual
              layer: 'creatures'
              spriteName: 'bullet'
              state: 'normal'
              time: 0

            new Common.Position
              x: fireX
              y: fireY
            new Common.Velocity
              x: vel
              y: 0
            new Common.HitBox
              width: 3
              height: 3
              anchorX: 0.5
              anchory: 0.5

            new Common.Sound
              soundId: 'short_beam'
              volume: 0.2
              playPosition: 0
              timeLimit: 55

            new Common.DeathTimer
              time: GUN_SETTINGS.bullet_life
          ]

        when 'held'
          0 # TODO repeat fire 

module.exports = SamusWeapon

