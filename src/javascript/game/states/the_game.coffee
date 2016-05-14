Immutable = require 'immutable'
{Map,List} = Immutable

Title = require './title'
Adventure = require './adventure'

Comps = require '../entity/components'
Systems = require '../systems'
EcsMachine = require '../../ecs/ecs_machine'
EntityStore = require '../../ecs/entity_store'

ecsMachine = new EcsMachine(systems: [
  Systems.timer_system
  Systems.death_timer_system
  Systems.animation_timer_system
  Systems.sound_system
  Systems.controller_system
  Systems.main_title_system
])

estore = new EntityStore()

modes = {
  title: Title
  adventure: Adventure
}

exports.initialState = () ->
  m = 'title'
  # m = 'adventure'
  Map(mode: m, gameState: modes[m].initialState())

# Action -> Model -> (Model, Effects Action)
exports.update = (state,input) ->
  s = state.get('gameState')
  mode = modes[state.get('mode')]
  [s1,events] = mode.update(s, input)

  state = state.set('gameState',s1)
  events.forEach (e) ->
    switch e.get('name')
      when 'StartNewGame'
        m = 'adventure'
        state = state
          .set('mode', m)
          .set('gameState', modes[m].initialState())
      else
        console.log "TheGame.update: unhandled event:", e.toJS()

  return [state, null]

exports.assetsToPreload = ->
  List([Adventure,Title])
    .flatMap((s) ->
      s.assetsToPreload())

exports.spriteConfigs = ->
  Adventure.spriteConfigs()
