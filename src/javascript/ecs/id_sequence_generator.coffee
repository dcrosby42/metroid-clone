class IdSequenceGenerator
  constructor: ({@prefix,firstId}) ->
    @i = firstId || 1

  nextId: ->
    eid = @i
    @i++
    if @prefix?
      "#{@prefix}#{eid}"
    else
      eid
    

module.exports = IdSequenceGenerator
