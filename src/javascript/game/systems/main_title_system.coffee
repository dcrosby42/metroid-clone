StateMachineSystem = require '../../ecs/state_machine_system'
Common = require '../entity/components'

forEidsByName = (estore, name, fn) ->
  res = estore.search([{match: { type: 'name', name: name}, as: 'nameComp'}])
  res.forEach (comps) ->
    fn(comps.getIn(['nameComp', 'eid']))


class MainTitleSystem extends StateMachineSystem
  @Subscribe: [ 'main_title', 'controller' ]
  @StateMachine:
    componentProperty: ['main_title','state']
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
    @publishEvent 'ready'

  showMainTitleAction: ->
    @_newLabel(50,50,'PUSH START BUTTON', name:'mainMenu')

  showMainMenuAction: ->
    @_destroyEntityWithName 'mainMenu'
    @_createSubMenu()

  selectNewGameAction: ->
    forEidsByName @estore, 'cursor', (eid) =>
      if pos = @getEntityComponent eid, 'position'
        @updateComp pos.set('y',50)

  selectContinueAction: ->
    forEidsByName @estore, 'cursor', (eid) =>
      if pos = @getEntityComponent eid, 'position'
        @updateComp pos.set('y',66)

  newGameAction: ->
    @_destroySubMenu()
    @publishGlobalEvent 'StartNewGame'
    console.log "start new game"

  continueAction: ->
    @_destroySubMenu()
    console.log "continue game"
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
    layer ?= 'overlay'
    comps = [
      Common.Label.merge
        content: content
        layer: layer
      Common.Position.merge
        x: x
        y: y
    ]
    if name?
      comps.push(Common.Name.merge(name: name))
    @newEntity comps

  _destroyEntityWithName: (name) ->
    forEidsByName @estore, name, (eid) => @destroyEntity(eid)


module.exports = MainTitleSystem

