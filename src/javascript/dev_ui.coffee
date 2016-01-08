$ = require 'jquery'
Immutable = require 'immutable'

class DevUI
  constructor: (@element) ->
    @meta = [
      ['#paused', 'toggle_pause', 'paused']
      ['#draw-hitboxes', 'toggle_draw_hitboxes', 'draw-hitboxes']
    ]
    for [sel,evt,_] in @meta
      @_clickToBoolEvent(sel,evt)

    @events = Immutable.Map()

  _clickToBoolEvent: (sel, evtName) ->
    @element.find(sel).on 'click', (e)=>
      @_addEvent(evtName)
      e.preventDefault()


  _addEvent: (name) ->
    @events = @events.set(name,true)

  getEvents: ->
    events = @events
    @events = @events.clear()
    events

  setState: (adminState) ->
    state = Immutable.Map()
      .set('paused', adminState.get('paused'))
      .set('draw-hitboxes', adminState.get('drawHitBoxes'))

    return if state.equals(@state)
    @state = state
    # console.log "DevUI updated state to",@state.toJS()
    for [sel,_,key] in @meta
      @element.find(sel).toggleClass('enabled',@state.get(key))

    
exports.create = (el) ->
  new DevUI(el)
  
