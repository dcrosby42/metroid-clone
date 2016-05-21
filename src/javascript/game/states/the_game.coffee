Immutable = require 'immutable'
{Map,List} = Immutable

Title = require './title'
Adventure = require './adventure'
Powerup = require './powerup'

Comps = require '../entity/components'
Systems = require '../systems'
EcsMachine = require '../../ecs/ecs_machine'
EntityStore = require '../../ecs/entity_store'
FilterExpander = require '../../ecs/filter_expander'

Items =  require '../entity/items'

ecsMachine = new EcsMachine(systems: [
  Systems.timer_system
  Systems.death_timer_system
  Systems.animation_timer_system
  Systems.sound_system
  Systems.controller_system
  Systems.main_title_system
])

modes = {
  title: Title
  adventure: Adventure
  powerup: Powerup
}

initialState = (mode) ->
  Map(
    mode: mode,
    gameState: modes[mode].initialState(),
    systemLogs: null
  )

exports.initialState = () -> initialState('title')

# Action -> Model -> (Model, Effects Action)
exports.update = (state,input) ->
  s = state.get('gameState')
  mode = modes[state.get('mode')]
  [s1,events,systemLogs] = mode.update(s, input)

  state = state
    .set('gameState',s1)
    .set('systemLogs',systemLogs)

  events.forEach (e) ->
    console.log "TheGame.update handling #{e.get('name')} event:",e.toJS()
    state = switch e.get('name')

      when 'StartNewGame'
        initialState('adventure')

      when 'ContinueGame'
        pretendContinue(initialState('adventure'))

      when 'PowerupTouched'
        state.set('mode', 'powerup')

      when 'PowerupInstalled'
        state.set('mode', 'adventure')

      when 'Killed'
        initialState('title')

      else
        console.log "TheGame.update: unhandled event:", e.toJS()
        state

  return [state, null]

exports.assetsToPreload = ->
  List([Adventure,Title])
    .flatMap((s) ->
      s.assetsToPreload())

exports.spriteConfigs = ->
  Adventure.spriteConfigs()


pretendContinue = (state) ->
  estore = new EntityStore(state.get('gameState'))

  filter = EntityStore.expandSearch(['samus'])
  samEid = estore.search(filter).first().getIn(['samus','eid'])
  estore.createComponent(samEid, Items.components.MaruMari)

  filter2 = EntityStore.expandSearch(['collected_items'])
  collectedItems = estore.search(filter2).first().get('collected_items')
  collectedItems = collectedItems.update 'itemIds', (ids) -> ids.add('item-1')
  estore.updateComponent(collectedItems)

  state.set('gameState',estore.takeSnapshot())
        


