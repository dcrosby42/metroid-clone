Common = require '../../components2'

GUN_SETTINGS =
  x_offset: 10
  y_offset: -22
  muzzle_velocity: 200/1000
  bullet_life: 50 / (200/1000)

module.exports =
  config:
    filters: ['samus','position']

  update: (comps,input,u) ->
    samus = comps.get('samus')
    position = comps.get('position')

    switch samus.get('weaponTrigger')
      when 'released'
        0
      when 'pulled'
        xoff = GUN_SETTINGS.x_offset
        vel = GUN_SETTINGS.muzzle_velocity

        if samus.get('direction') == 'left'
          xoff = -xoff
          vel = -vel

        fireX = position.get('x') + xoff
        fireY = position.get('y') + GUN_SETTINGS.y_offset

        u.newEntity [
          Common.Bullet
          Common.Visual.merge
            layer: 'creatures'
            spriteName: 'bullet'
            state: 'normal'

          Common.Position.merge
            x: fireX
            y: fireY
          Common.Velocity.merge
            x: vel
            y: 0
          Common.HitBox.merge
            width: 4
            height: 4
            anchorX: 0.5
            anchorY: 0.5

          Common.Sound.merge
            soundId: 'short_beam'
            volume: 0.2
            playPosition: 0
            timeLimit: 55
            resound: true

          Common.DeathTimer.merge
            time: GUN_SETTINGS.bullet_life

          # Common.HitBoxVisual.merge
          #   color: 0xffffff
        ]

      when 'held'
        0 # TODO repeat fire 

