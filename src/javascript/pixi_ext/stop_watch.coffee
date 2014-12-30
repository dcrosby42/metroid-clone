class StopWatch
  constructor: ->

  start: ->
    @startMillis = @currentTimeMillis()
    @millis = @startMillis

  currentTimeMillis: ->
    new Date().getTime()

  lapInMillis: ->
    newMillis = @currentTimeMillis()
    lapMillis = newMillis - @millis
    @millis = newMillis
    lapMillis

  elapsedMillis: ->
    @currentTimeMillis() - @startMillis

  lapInSeconds: ->
    @lapInMillis() / 1000.0

  elapsedSeconds: ->
    @elapsedMillis() / 1000.0


module.exports = StopWatch
