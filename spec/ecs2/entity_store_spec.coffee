_ = require 'lodash'
Immutable = require 'immutable'
Map = Immutable.Map
Set = Immutable.Set
List = Immutable.List
imm = Immutable.fromJS


ExpectHelpers = require '../helpers/expect_helpers'

expectIs = ExpectHelpers.expectIs

chai = require('chai')
expect = chai.expect
assert = chai.assert

EntityStore = require '../../src/javascript/ecs2/entity_store'

findEntityComponent = (estore, eid, key,val) ->
  found = estore.getEntityComponents(eid).filter((c) -> c.get(key) == val).first()
  if found?
    return found
  else
    console.log "!! NO CAN FIND COMPONENT for eid=#{eid} where #{key}=#{val}"
    return null

describe 'The new EntityStore', ->
  newEntityStore = -> new EntityStore()

  describe "createEntity and getEntityComponents", ->
    it 'builds new components and attaches them to a new Entity ID (eid)', ->
      estore = newEntityStore()

      eid = estore.createEntity [
        { type: 'player', id: '9876' }
        { type: 'character', name: 'Link', race: 'elf' }
        { type: 'armor', name: 'jerkin', defense: 2 }
      ]
    
      comps = estore.getEntityComponents(eid)
      expect(comps).to.be
      expect(Immutable.Set.isSet(comps)).to.be.true
      expect(comps.size).to.eq 3

      compList = comps.toList()
      link = compList.get(1)
      expect(link.get('eid')).to.eq eid
      expect(link.get('cid')).to.match /^c\d+$/
      expect(link.get('type')).to.eq 'character'
      expect(link.get('name')).to.eq 'Link'
      expect(link.get('race')).to.eq 'elf'

    it 'accepts an Immutable.List of JS objects', ->
      estore = newEntityStore()

      eid = estore.createEntity Immutable.List([
        { type: 'player', id: '9876' }
        { type: 'character', name: 'Link', race: 'elf' }
        { type: 'armor', name: 'jerkin', defense: 2 }
      ])
    
      comps = estore.getEntityComponents(eid)
      expect(comps).to.be
      expect(Immutable.Set.isSet(comps)).to.be.true
      expect(comps.size).to.eq 3

      compList = comps.toList()
      link = compList.get(1)
      expect(link.get('eid')).to.eq eid
      expect(link.get('cid')).to.match /^c\d+$/
      expect(link.get('type')).to.eq 'character'
      expect(link.get('name')).to.eq 'Link'
      expect(link.get('race')).to.eq 'elf'

    it 'accepts an Immutable.List of Immutable.Map comps', ->
      estore = newEntityStore()

      eid = estore.createEntity Immutable.fromJS [
        { type: 'player', id: '9876' }
        { type: 'character', name: 'Link', race: 'elf' }
        { type: 'armor', name: 'jerkin', defense: 2 }
      ]
    
      comps = estore.getEntityComponents(eid)
      expect(comps).to.be
      expect(Immutable.Set.isSet(comps)).to.be.true
      expect(comps.size).to.eq 3

      compList = comps.toList()
      link = compList.get(1)
      expect(link.get('eid')).to.eq eid
      expect(link.get('cid')).to.match /^c\d+$/
      expect(link.get('type')).to.eq 'character'
      expect(link.get('name')).to.eq 'Link'
      expect(link.get('race')).to.eq 'elf'

    it 'can create an Entity without components', ->
      estore = newEntityStore()

      eid = estore.createEntity()
      expect(eid).to.match /^e\d+$/

      comps = estore.getEntityComponents(eid)
      expect(comps).to.be
      expect(Immutable.Set.isSet(comps)).to.be.true
      expect(comps.size).to.eq 0

  describe "createComponent", ->
    it "converts properties into a new component and attaches it to the given entity", ->
      estore = newEntityStore()

      eid = estore.createEntity [
        { type: 'player', id: '9876' }
        { type: 'character', name: 'Link', race: 'elf' }
      ]
    
      comps = estore.getEntityComponents(eid)
      expect(comps.size).to.eq 2

      estore.createComponent eid,
        type: 'armor'
        name: 'plate'
        defense: 10

      comps = estore.getEntityComponents(eid)
      expect(comps.size).to.eq 3

      armor = comps.filter((c) -> c.get('type') == 'armor').first()
      expect(armor.get('eid')).to.eq eid
      expect(armor.get('cid')).to.match /^c\d+$/
      expect(armor.get('type')).to.eq 'armor'
      expect(armor.get('name')).to.eq 'plate'
      expect(armor.get('defense')).to.eq 10


  describe "getComponent", ->
    it "retrieves a component by its cid", ->
      estore = newEntityStore()
      
      eid = estore.createEntity [
        { type: 'player', id: '9876' }
        { type: 'character', name: 'Link', race: 'elf' }
      ]
    
      # loop thru components seeing their cid yields the same comp:
      comps = estore.getEntityComponents(eid)
      comps.forEach (comp) ->
        expectIs estore.getComponent(comp.get('cid')), comp

  describe "updateComponent", ->
    it "updates the value of a component in the store", ->
      estore = newEntityStore()
      eid = estore.createEntity [
        { type: 'player', id: '9876' }
        { type: 'character', name: 'Link', race: 'elf' }
      ]

      link = findEntityComponent estore, eid, 'type', 'character'
      linkCid = link.get('cid')
      newLink = link.set('name', 'Big Bad Link')

      estore.updateComponent(newLink)
      expectIs estore.getComponent(linkCid), newLink
      expectIs findEntityComponent(estore,eid,'type','character'), newLink



  describe "deleteComponent", ->
    it "removes the component from its entity and store", ->
      estore = newEntityStore()
      
      eid = estore.createEntity [
        { type: 'player', id: '9876' }
        { type: 'character', name: 'Link', race: 'elf' }
      ]

      char = findEntityComponent estore, eid, 'type', 'character'

      estore.deleteComponent(char)

      comps = estore.getEntityComponents(eid)
      expect(comps.size).to.eq 1
      expect(comps.first().get('type')).to.eq 'player'

  describe "search", ->
    linkData = imm [
      { type: 'tag', value: 'hero' }
      { type: 'character', name: 'Link' }
      { type: 'bbox', shape: [1,2,3,4] }
      { type: 'inventory', stuff: 'items' }
    ]

    tektikeData = imm [
      { type: 'tag', value: 'enemy' }
      { type: 'character', name: 'Tektike' }
      { type: 'bbox', shape: [3,4,5,6] }
      { type: 'digger', status: 'burrowing' }
    ]

    it 'filters and joins components using an object finder', ->
      estore = newEntityStore()
      link = estore.createEntity(linkData)
      tektike = estore.createEntity(tektikeData)

      linkCharacter    = findEntityComponent estore, link, 'type','character'
      linkBox          = findEntityComponent estore, link, 'type','bbox'
      tektikeCharacter = findEntityComponent estore, tektike, 'type','character'
      tektikeBox       = findEntityComponent estore, tektike, 'type','bbox'

      results = estore.search [
        {
          match: { type: 'character' }
        }
        {
          match: { type: 'bbox' }
          join:  "character.eid"
        }
      ]

      expectIs results, imm [
        { character: linkCharacter, bbox: linkBox }
        { character: tektikeCharacter, bbox: tektikeBox }
      ]
  
  describe "search realistic", ->

    samusData = imm [
      { recoil: "no", aim: "straight", floatSpeed: 0.06, action: undefined, motion: "standing", jumpSpeed: 0.4, type: "samus", runSpeed: 0.088, weaponTrigger: "released", direction: "right" }
      { type: "position", x: 50, y: 80}
      { type: "velocity", x: 0, y: 0}
      { type: "gravity", accel: 0.02, max: 0.2 }
      { anchorX: 0.5, touching: { left: false, right: false, top: false, bottom: true }, anchorY: 1, width: 12, height: 32, touchingSomething: true, x: 50, y: 80, type: "hit_box"}
      { type: "controller", inputName: "player1", states: {} }
      { time: 0, spriteName: "samus", state: null, layer: "creatures", type: "visual" }
      { type: "hit_box_visual", color: 39423, anchorColor: 16777215 }
    ]
    it 'filters and joins components using an object finder', ->
      estore = newEntityStore()
      samusEid = estore.createEntity(samusData)

      samus = findEntityComponent estore, samusEid, 'type','samus'
      controller = findEntityComponent estore, samusEid, 'type','controller'

      results = estore.search [
        {
          match: { type: 'samus' }
          as: 'samus'
        }
        {
          match: { type: 'controller' }
          as: 'controller'
          join: 'samus.eid'
        }
      ]

      expectIs results, imm [
        { samus: samus, controller: controller }
      ]

      # expectIs results, imm [
      #   { character: linkCharacter, bbox: linkBox }
      #   { character: tektikeCharacter, bbox: tektikeBox }
      # ]
      


