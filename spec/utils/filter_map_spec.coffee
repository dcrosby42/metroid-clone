Immutable = require 'immutable'
imm = Immutable.fromJS
{Map,List,Set} = Immutable

chai = require('chai')
expect = chai.expect
assert = chai.assert
expectIs = require('../helpers/expect_helpers').expectIs

filterMap = require '../../src/javascript/utils/filter_map'

describe "filterMap", ->
  data = imm
    "Samus (e2)":
      animation: [
        { type: "animation", cid: "c1", eid: "e2",  spriteName: "samus", state: "stand-right" }
      ]
      timer: [
        { type: "timer", value: "100" }
      ]
    "Zoomer (e9)":
      zoomer: [
        { type: "zoomer", orientation: "up", crawlDir: "forward" }
      ]
      animation: [
        { type: "animation", cid: "c3", eid: "e9",  spriteName: "basic_zoomer", state: "stand-right" }
      ]
    "myisam (e99)":
      thingy: [
        { type: 'thingy' }
      ]
      animatorator: [
        { type: "whoknows", cid: "c1", eid: "e2",  spriteName: "samus", state: "stand-right" }
      ]

  samusKey = "Samus (e2)"
  zoomerKey = "Zoomer (e9)"
  myisamKey = "myisam (e99)"

  describe "when blank or null", ->
    it "returns data", ->
      expectIs filterMap(data), data
      expectIs filterMap(data,''), data
      expectIs filterMap(data,'     \t \n '), data

  describe "filtering simple maps", ->
    it "returns a Map less the keys that don't match the filter", ->
      simple = Map
        bird: "cardinal"
        region: "NA"
        tird: "lots"

      expectIs filterMap(simple, 'bird'), simple.remove('region').remove('tird')
      expectIs filterMap(simple, 'r'), simple
      expectIs filterMap(simple, 'ird'), simple.remove('region')
      expectIs filterMap(simple, 't'), simple.remove('region').remove('bird')

  describe "filtering the toplevel map", ->
    it "returns a map with only the keys who match the given text", ->
      expected = Map
        "#{zoomerKey}": data.get(zoomerKey)
      expectIs filterMap(data, 'zoome'), expected

      expected = Map
        "#{samusKey}": data.get(samusKey)
      expectIs filterMap(data, 'Samus'), expected
      expectIs filterMap(data, 'samu'), expected
      expectIs filterMap(data, 'amu'), expected

      expected = Map
        "#{samusKey}": data.get(samusKey)
        "#{myisamKey}": data.get(myisamKey)

      expectIs filterMap(data, 'sam'), expected

  describe "keypath-style filter text for first layer of submaps", ->
    it "filters child maps", ->
      expected = Map
        "#{samusKey}": data.get(samusKey).remove("timer")
      expectIs filterMap(data, 'samu.anim'), expected

      expected = Map
        "#{samusKey}": data.get(samusKey).remove("timer")
        "#{myisamKey}": data.get(myisamKey).remove("thingy")
      expectIs filterMap(data, 'sam.anima'), expected

    it "excludes toplevel keys if further steps exclude all children", ->
      expectIs filterMap(data, 'sam.funk'), Map()

    it "filters subarrays", ->
      expected = imm
        "#{samusKey}":
          animation: [
            { cid: "c1", eid: "e2" }
          ]

      expectIs filterMap(data, 'samu.anim.id'), expected

      expected = imm
        "#{samusKey}":
          animation: [ { type: 'animation' } ]
        "#{myisamKey}":
          animatorator: [ { type: 'whoknows' } ]

      expectIs filterMap(data, 'sam.an.type'), expected



