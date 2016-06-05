Immutable = require 'immutable'
imm = Immutable.fromJS
{OrderedMap,Map,List,Set} = Immutable
OMap=OrderedMap

chai = require('chai')
expect = chai.expect
assert = chai.assert
expectIs = require('../helpers/expect_helpers').expectIs

filterMap = require '../../src/javascript/utils/filter_map'

describe "filterMap", ->
  data = OMap(
    "Samus (e2)": OMap(
      animation: List([
        OMap( type: "animation", cid: "c1", eid: "e2",  spriteName: "samus", state: "stand-right" )
      ])
      timer: List([
        OMap( type: "timer", value: "100" )
      ]))
    "Zoomer (e9)": OMap(
      zoomer: List([
        OMap( type: "zoomer", orientation: "up", crawlDir: "forward" )
      ])
      animation: List([
        OMap( type: "animation", cid: "c3", eid: "e9",  spriteName: "basic_zoomer", state: "stand-right" )
      ]))
    "myisam (e99)": OMap(
      thingy: List([
        OMap( type: 'thingy' )
      ])
      animatorator: List([
        OMap( type: "whoknows", cid: "c1", eid: "e2",  spriteName: "samus", state: "stand-right" )
      ]))
  )

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
      simple = OrderedMap
        bird: "cardinal"
        region: "NA"
        tird: "lots"

      expectIs filterMap(simple, 'bird'), simple.remove('region').remove('tird')
      expectIs filterMap(simple, 'r'), simple
      expectIs filterMap(simple, 'ird'), simple.remove('region')
      expectIs filterMap(simple, 't'), simple.remove('region').remove('bird')

  describe "filtering the toplevel map", ->
    it "returns a map with only the keys who match the given text", ->
      expected = OrderedMap
        "#{zoomerKey}": data.get(zoomerKey)
      expectIs filterMap(data, 'zoome'), expected

      expected = OrderedMap
        "#{samusKey}": data.get(samusKey)
      expectIs filterMap(data, 'Samus'), expected
      expectIs filterMap(data, 'samu'), expected
      expectIs filterMap(data, 'amu'), expected

      expected = OrderedMap
        "#{samusKey}": data.get(samusKey)
        "#{myisamKey}": data.get(myisamKey)

      expectIs filterMap(data, 'sam'), expected

  describe "keypath-style filter text for first layer of submaps", ->
    it "filters child maps", ->
      expected = OMap(
        "#{samusKey}": data.get(samusKey).remove("timer"))
      expectIs filterMap(data, 'samu.anim'), expected

      expected = OMap(
        "#{samusKey}": data.get(samusKey).remove("timer")
        "#{myisamKey}": data.get(myisamKey).remove("thingy")
      )
      expectIs filterMap(data, 'sam.anima'), expected

    it "excludes toplevel keys if further steps exclude all children", ->
      expectIs filterMap(data, 'sam.funk'), OMap()

    it "filters subarrays", ->
      expected = OMap(
        "#{samusKey}": OMap(
          animation: List([
            OMap( cid: "c1", eid: "e2" )
          ]))
      )

      expectIs filterMap(data, 'samu.anim.id'), expected

      expected = OMap(
          "#{samusKey}": OMap(
            animation: List([ OMap( type: 'animation' ) ]))
          "#{myisamKey}": OMap(
            animatorator: List([ OMap( type: 'whoknows' ) ]))
      )

      expectIs filterMap(data, 'sam.an.type'), expected

    it "supports wildcards", ->
      expected = OMap(
        "#{samusKey}": OMap(
          animation: List([ OMap(type: 'animation' ) ])
          timer: List([ OMap( type: 'timer' ) ]))

        "#{zoomerKey}": OMap(
          zoomer: List([ OMap( type: 'zoomer' ) ])
          animation: List([ OMap( type: 'animation' ) ]))
        "#{myisamKey}": OMap(
          thingy: List([ OMap( type: 'thingy' ) ])
          animatorator: List([ OMap( type: 'whoknows' ) ]))
      )
          

      expectIs filterMap(data, '*.*.type'), expected



