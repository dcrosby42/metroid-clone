

searchEvent = (indexedEvents,t) ->
  len = indexedEvents.length
  i = 0
  while (i < len-1) and (indexedEvents[i+1][0] <= t)
    i++
  indexedEvents[i]

class Timeline
  @createEvent: (span,item) ->
    [span,item]

  @createTimedEvents: (eventSpan, items,looped=false) ->
    events = _.map items, (x) -> Timeline.createEvent(eventSpan,x)
    new Timeline(events,looped)


  constructor: (events,@looped=false) ->
    @_indexedEvents = []
    t = 0
    for [span,item] in events
      @_indexedEvents.push [t,span,item]
      t += span
    @span = t

  _eventAtTime: (t) ->
    time = if @looped
      t % @span
    else
      t
    searchEvent(@_indexedEvents,time)
   
  itemAtTime: (t) ->
    @_eventAtTime(t)[2]

module.exports = Timeline

