
module.exports =
  config:
    filters: [ 'samus', 'velocity' ]

  update: (comps,input,u) ->
    # samus actions: run | drift | stand | jump | fall
    samus = comps.get('samus')
    # console.log "samus: #{samus}"
    velocity = comps.get('velocity')

    direction = samus.get('direction')

    v2 = switch samus.get('action')
      when 'run'
        if direction == 'right'
          velocity.set('x', samus.get('runSpeed'))
        else
          velocity.set('x', -samus.get('runSpeed'))

      when 'drift'
        if direction == 'right'
          velocity.set('x', samus.get('floatSpeed'))
        else
          velocity.set('x', -samus.get('floatSpeed'))

      when 'stop'
        velocity.set('x', 0)

      when 'jump'
        velocity.set('y', -samus.get('jumpSpeed'))

      when 'fall'
        velocity.set('y', 0)

      else
        velocity#.set('y',0).set('x',0)

    if v2 != velocity
      u.update v2

