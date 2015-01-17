_ = require 'lodash'

class CompositeEvent
  @create: (events,handler) ->
    new CompositeEvent(events,handler)

  constructor: (@events,@handler) ->
    @results = {}
    @completed = []
    @done = false

  notify: (event,result) ->
    if @done
      console.log "CompositeEvent[#{@events.join(",")}] notified of #{event} after done.  result:", result
    @completed.push event
    @results[event] = result
    @_checkCompletion()

  notifier: (event) ->
    (result) => @notify(event,result)

  _checkCompletion: ->
    if _.isEmpty(_.difference(@events, @completed))
      @done = true
      @handler(@results)

module.exports = CompositeEvent
