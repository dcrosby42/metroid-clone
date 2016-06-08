StateMachineSystem = require '../../ecs2/state_machine_system'
EntitySearch = require '../../ecs2/entity_search'
C = require '../../components'
T = C.Types

# forEidsByName = (estore, name, fn) ->
#   res = estore.search([{match: { type: 'name', name: name}, as: 'nameComp'}])
#   res.forEach (comps) ->
#     fn(comps.getIn(['nameComp', 'eid']))

nameSearcher = EntitySearch.prepare([T.Name])

class MainTitleSystem extends StateMachineSystem
  @Subscribe: [ T.MainTitle, T.Controller ]

  @StateMachine:
    componentProperty: [0,'state']
    property: 'state'
    start: 'begin'
    states:
      begin:
        events:
          ready:
            action: 'showMainTitle'
            nextState: 'mainTitle'
      mainTitle:
        events:
          startPressed:
            action: 'showMainMenu'
            nextState: 'newGameSelected'
      newGameSelected:
        events:
          startPressed:
            action: 'newGame'
          upPressed:
            action: 'selectContinue'
            nextState: 'continueSelected'
          downPressed:
            action: 'selectContinue'
            nextState: 'continueSelected'
      continueSelected:
        events:
          startPressed:
            action: 'continue'
          upPressed:
            action: 'selectNewGame'
            nextState: 'newGameSelected'
          downPressed:
            action: 'selectNewGame'
            nextState: 'newGameSelected'

  beginState: ->
    @publishEvent @eid, 'ready'

  showMainTitleAction: ->
    anim = C.Animation.default()
    anim.spriteName = 'main_title'
    anim.state = 'main'
    anim.layer = 'overlay'
    @estore.createEntity [
      anim
      new C.Position(0,0)
      new C.Name('mainTitleImg')
    ]

    @_newLabel(5*16,9*16,'PUSH START BUTTON', name:'mainTitleLabel')

  showMainMenuAction: ->
    @_destroyEntityWithName 'mainTitleImg'
    @_destroyEntityWithName 'mainTitleLabel'
    @_createSubMenu()

  selectNewGameAction: ->
    @_withCursorPosition (pos) ->
      pos.y = 50

  selectContinueAction: ->
    @_withCursorPosition (pos) ->
      pos.y = 65

  newGameAction: ->
    @_destroySubMenu()
    @publishGlobalEvent 'StartNewGame'

  continueAction: ->
    @_destroySubMenu()
    @publishGlobalEvent 'ContinueGame'

  _createSubMenu: ->
    @_newLabel 50,50, 'NEW GAME', name: 'newGameChoice'
    @_newLabel 50,66, 'CONTINUE', name: 'continueChoice'
    @_newLabel 34,50, 'x', name: 'cursor'
    
  _destroySubMenu: ->
    @_destroyEntityWithName 'newGameChoice'
    @_destroyEntityWithName 'continueChoice'
    @_destroyEntityWithName 'cursor'

  _newLabel: (x,y,content,{name,layer}) ->
    comps = [
      Object.assign C.Label.default(), content:content,layer:(layer or 'overlay')
      # label
      new C.Position(x,y)
    ]
    comps.push(new C.Name(name)) if name?
    @estore.createEntity comps

  _destroyEntityWithName: (name) ->
    nameSearcher.run @estore, (r) ->
      if r.comps[0].name == name
        r.entity.destroy()

  _withCursorPosition: (fn) ->
    nameSearcher.run @estore, (r) ->
      if r.comps[0].name == 'cursor'
        pos = r.entity.get(T.Position)
        fn(pos) if pos?


module.exports = -> new MainTitleSystem()

