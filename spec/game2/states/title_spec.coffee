chai = require('chai')
expect = chai.expect
assert = chai.assert

C = require '../../../src/javascript/components'
T = C.Types
Title = require '../../../src/javascript/game2/states/title'
EntityStore = require '../../../src/javascript/ecs2/entity_store'
EntitySearch = require '../../../src/javascript/ecs2/entity_search'
Immutable = require 'immutable'

TestHelpers = require '../../ecs2/test_helpers'


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
    expect(preload.length).to.equal(2)
    for asset in preload
      expect(asset).to.not.be.undefined
      expect(asset.type).to.not.be.undefined
      expect(asset.name).to.not.be.undefined
      expect(asset.file).to.not.be.undefined

  it "can update", ->
    estore = Title.initialState()

    input = Immutable.fromJS
      controllers:
        player1: {}
      dt: 0

    [estore,events] = Title.update(estore,input)

    ents = TestHelpers.searchEntities estore, [{type: T.Name, name: 'mainTitleImg'}]
    expect(ents.length).to.equal(1)

    ents = TestHelpers.searchEntities estore, [{type: T.Name, name: 'mainTitleLabel'}]
    expect(ents.length).to.equal(1)




  
    
