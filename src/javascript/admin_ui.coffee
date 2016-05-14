$ = require 'jquery'
Immutable = require 'immutable'
{Map}=Immutable

class AdminUI
  constructor: (@postOffice, @element) ->
    mbox = @postOffice.newMailbox()
    address = mbox.address
    @signal = mbox.signal

    @meta = [
      ['#paused', 'toggle_pause', 'paused']
      ['#muted', 'toggle_mute', 'muted']
      ['#draw-hitboxes', 'toggle_bounding_box', 'draw-hitboxes']
    ]

    _subscribeClick = (sel, evtName) =>
      @element.find(sel).on 'click', (e) ->
        address.send Map(type: 'AdminUIEvent', name: evtName)
        e.preventDefault()

    for [sel,evtName,_] in @meta
      _subscribeClick(sel,evtName)


  update: (adminState) ->
    state = Immutable.Map()
      .set('paused', adminState.get('paused'))
      .set('muted', adminState.get('muted'))
      .set('draw-hitboxes', adminState.get('drawHitBoxes'))

    return if state.equals(@state)
    @state = state
    # console.log "DevUI updated state to",@state.toJS()
    for [sel,_,key] in @meta
      @element.find(sel).toggleClass('enabled',@state.get(key))

module.exports = AdminUI
  
