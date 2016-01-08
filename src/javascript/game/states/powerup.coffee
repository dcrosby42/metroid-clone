Common = require '../entity/components'

class PowerupState
  @Name: 'adventure'

  constructor: (@machine) ->
    # @level = RoomsLevel
    @ecsMachine = new EcsMachine(systems: @_getSystems())

  enter: (data=null) ->
    @estore.restoreSnapshot(data)
    @estore.createEntity [
      General.PoweupJingle
      Common.Name.merge
        name: 'Powerup Jingle'
      Common.Timer.merge
        time: 750
        event: 'jingleOver'
      Common.Sound.merge
        soundId: 'powerup_jingle'
        volume: 0.2
        playPosition: 0
        timeLimit: 750
    ]

  update: (gameInput) ->
    [@estore,events] = @ecsMachine.update(@estore,gameInput)
    events.forEach (e) -> @["event_#{e.get('name')}"]?(e)

  exit: ->

  gameData: ->
    @estore.takeSnapshot()

  event_Done: (e) ->
    @machine.transition 'adventure'

  _getSystems: ->
    [

      # TODO: small subset of game systems, such as TimerSystem
    ]

module.exports = PowerupState
