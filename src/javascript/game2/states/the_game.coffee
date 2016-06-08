_ = require 'lodash'
Immutable = require 'immutable'
{List} = Immutable

Title = require './title'
# Adventure = require './adventure'
# Powerup = require './powerup'

Systems = require '../systems'

# Items =  require '../entity/items'

Modes =
  Title: Title
  # Adventure: Adventure
  # Powerup: Powerup

class TheState
  # modeName: valid key in Modes (see above)
  # gameState: EntityStore
  constructor: (@modeName,@gameState) ->

initialStateForMode = (modeName) ->
  new TheState(
    modeName,
    Modes[modeName].initialState()
  )


exports.initialState = () ->
  initialStateForMode('Title')
  # pretendContinue(initialStateForMode('adventure'))

# Action -> Model -> (Model, Effects Action)
exports.update = (state,input) ->
  # console.log "TheGame.update", state,input.toJS()
  mode = Modes[state.modeName]
  # console.log "  mode",mode
  [state.gameState,events] = mode.update(state.gameState, input)

  events.forEach (e) ->
    # console.log "TheGame.update handling #{e.get('name')} event:",e.toJS()
    switch e.get('name')

      when 'StartNewGame'
        console.log "Start new game! TODO"
        # state = initialStateForMode('Adventure')

      when 'ContinueGame'
        console.log "Continue new game! TODO"
        # pretendContinue(initialStateForMode('Adventure'))

      when 'PowerupCelebrationStarted'
        console.log "Powerup!"
        # state.modeName = 'Powerup'

      when 'PowerupCelebrationDone'
        console.log "Done Powerup!"
        # state.modeName = 'Adventure'

      when 'Killed'
        console.log "Killed!"
        initialStateForMode('Title')

      else
        console.log "TheGame.update: unhandled event:", e.toJS()

  return state

exports.assetsToPreload = ->
  List([
    # Adventure
    Title
  ]).flatMap((s) ->
      s.assetsToPreload())

exports.spriteConfigs = ->
  cfgs = {}
  _.merge cfgs, Title.spriteConfigs()
  # _.merge cfgs, Adventure.spriteConfigs()
  # _.merge cfgs, Powerup.spriteConfigs()
  cfgs



# pretendContinue = (state) ->
#   estore = new EntityStore(state.get('gameState'))
#
#   filter = EntityStore.expandSearch(['samus'])
#   samEid = estore.search(filter).first().getIn(['samus','eid'])
#
#   estore.createComponent(samEid, Items.components.MaruMari)
#
#   estore.createComponent(samEid,
#     # Items.components.MissileLauncher.merge(max:5,count:4))
#     Items.components.MissileLauncher.merge(max:50,count:50))
#
#   filter2 = EntityStore.expandSearch(['collected_items'])
#   collectedItems = estore.search(filter2).first().get('collected_items')
#   collectedItems = collectedItems.update 'itemIds', (ids) -> ids.add('item-1').add('item-2')
#   estore.updateComponent(collectedItems)
#
#   state.set('gameState',estore.takeSnapshot())
        


