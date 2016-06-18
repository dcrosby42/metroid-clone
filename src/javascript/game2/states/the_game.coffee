_ = require 'lodash'
Immutable = require 'immutable'
{List} = Immutable

Title = require './title'
Adventure = require './adventure'
Powerup = require './powerup'

Systems = require '../systems'


Modes =
  Title: Title
  Adventure: Adventure
  Powerup: Powerup

class Model
  # modeName: valid key in Modes (see above)
  # gameState: EntityStore
  constructor: (@modeName,@gameState) ->

  clone: ->
    new @constructor(@modeName,@gameState.clone())

initialStateForMode = (modeName) ->
  new Model(
    modeName,
    Modes[modeName].initialState()
  )


exports.initialState = () ->
  initialStateForMode('Title')
  # initialStateForMode('Adventure')

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
        state = initialStateForMode('Adventure')

      when 'ContinueGame'
        state = pretendContinue(initialStateForMode('Adventure'))

      when 'PowerupCelebrationStarted'
        console.log "Powerup!"
        state.modeName = 'Powerup'

      when 'PowerupCelebrationDone'
        console.log "Done Powerup!"
        state.modeName = 'Adventure'

      when 'Killed'
        console.log "Killed!"
        state = initialStateForMode('Title')

      else
        console.log "TheGame.update: unhandled event:", e.toJS()

  return state

exports.assetsToPreload = ->
  assets = Title.assetsToPreload()
  # for a in assets
  #   console.log a
  assets = assets.concat(Adventure.assetsToPreload())
  return assets

exports.spriteConfigs = ->
  cfgs = {}
  _.merge cfgs, Title.spriteConfigs()
  _.merge cfgs, Adventure.spriteConfigs()
  # _.merge cfgs, Powerup.spriteConfigs()
  cfgs


#  TODO move this kinda thing somewhere else

EntitySearch = require '../../ecs2/entity_search'
C = require '../../components'
T = C.Types
Prefab = require '../prefab'

pretendContinue = (state) ->
  estore = state.gameState

  samus = null
  EntitySearch.prepare([{type:T.Tag,name:'samus'}]).run estore, (r) ->
    samus = r.entity

  samus.addComponent C.buildCompForType(T.MaruMari)

  samus.addComponent C.buildCompForType(T.MissileLauncher,
    max: 50
    count: 50
  )

  EntitySearch.prepare([T.CollectedItems]).run estore, (r) ->
    cicomp = r.comps[0]
    cicomp.itemIds.push('item-1')
    cicomp.itemIds.push('item-2')
    cicomp.itemIds.push('item-3')
        
  state.gameState = estore
  return state


