Common = require '../../components'

GUN_SETTINGS =
  offsetX: 10
  offsetY: -22
  muzzleVelocity: 200/1000
  bulletLife: 50 / (200/1000)

newBullet = (x,y,dir) ->
  offsetX = GUN_SETTINGS.offsetX
  offsetY = GUN_SETTINGS.offsetY
  velocity = GUN_SETTINGS.muzzleVelocity

  if dir == 'left'
    offsetX = -offsetX
    velocity = -velocity

  fireX = x + offsetX
  fireY = y + offsetY

  return [
    Common.Bullet
    Common.Visual.merge
      layer: 'creatures'
      spriteName: 'bullet'
      state: 'normal'

    Common.Position.merge
      x: fireX
      y: fireY
    Common.Velocity.merge
      x: velocity
      y: 0
    Common.HitBox.merge
      width: 4
      height: 4
      anchorX: 0.5
      anchorY: 0.5
    Common.HitBoxVisual.merge
      color: 0xffffff

    Common.Sound.merge
      soundId: 'short_beam'
      volume: 0.2
      playPosition: 0
      timeLimit: 55
      resound: true

    Common.DeathTimer.merge
      time: GUN_SETTINGS.bulletLife

  ]

module.exports =
  config:
    filters: ['samus', 'short_beam','position']

  update: (comps,input,u) ->
    shortBeam = comps.get('short_beam')

    switch shortBeam.get('state')
      when 'released'
        0
      when 'pulled'
        samus = comps.get('samus')
        position = comps.get('position')
        u.newEntity newBullet(position.get('x'), position.get('y'), samus.get('direction'))

      when 'held'
        0 # TODO repeat fire 

