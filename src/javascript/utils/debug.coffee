$ = require 'jquery'
Immutable = require 'immutable'

exports.scratch1 = (str) -> $('#scratch1').text(str)
# exports.scratch1 = (str) -> console.log str.toString()

exports.scratch2 = (str) -> $('#scratch2').text(str)
# exports.scratch2 = (str) -> console.log str.toString()

exports.scratch3 = (str) -> $('#scratch3').text(str)

exports.Immutable = Immutable
exports.imm = Immutable.fromJS

class Bencher
  constructor: ->
    @onLoopListeners = {}
    @records = {}
    @reset()

  updateBegin: (dt) ->
    @reset()

  updateEnd: ->
    for tag, h of @onLoopListeners
      h(tag, @things[tag], @records[tag])

  notice: (tag, obj) ->
    @things[tag] ?= []
    @things[tag].push obj

  onLoop: (tag,h) ->
    @onLoopListeners[tag] = h
    @records[tag] = []

  reset: ->
    @things = {}

exports.bencher = new Bencher()

window.bencher = exports.bencher

window.postBencherData = ->
  fo = bencher.records["filterObjects"]
  url = "http://localhost:3100"
  $.ajax(
    type: 'post'
    url: url
    data: JSON.stringify({_objects:fo}))
  $.ajax(
    type: 'post'
    url: url
    data: JSON.stringify({_action:'cut'}))

window.peekBencherData = ->
  fo = bencher.records["filterObjects"]
  console.log fo[fo.length-1]

# n = 1
# exports.hiThere = ->
#   console.log "Hi there! #{n} times."
#   n += 1
