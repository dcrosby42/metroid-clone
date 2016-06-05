chai = require('chai')
expect = chai.expect
assert = chai.assert

C = require '../../../src/javascript/components'
T = C.Types
Title = require '../../../src/javascript/game2/states/title'
EntityStore = require '../../../src/javascript/ecs2/entity_store'
EntitySearch = require '../../../src/javascript/ecs2/entity_search'
Immutable = require 'immutable'

describe "Title mode", ->
  it "has initialState", ->
    estore = Title.initialState()
    expect(estore.constructor).to.equal(EntityStore)

    mainTitleComp = null
    EntitySearch.prepare([T.MainTitle]).run estore, (r) ->
      mainTitleComp = r.comps[0]
    expect(mainTitleComp,"MainTitle").to.exist

    controller = null
    EntitySearch.prepare([T.Controller]).run estore, (r) ->
      controller = r.comps[0]
    expect(controller,"Controller").to.exist
  

  it "has assetsToPreload", ->
    preload = Title.assetsToPreload()
    expect(Immutable.List.isList(preload)).to.equal(true)

  it "can update", ->
    estore = Title.initialState()

    input = Immutable.fromJS
      controllers:
        player1: {}
      dt: 0

    estore = Title.update(estore,input)


  
    
