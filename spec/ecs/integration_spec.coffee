Immutable = require 'immutable'
imm = Immutable.fromJS

chai = require('chai')
expect = chai.expect
assert = chai.assert
expectIs = require('../helpers/expect_helpers').expectIs

EntityStore = require '../../src/javascript/ecs/entity_store'
EntityStoreFinder = require '../../src/javascript/ecs/entity_store_finder'
EntityStoreUpdater = require '../../src/javascript/ecs/entity_store_updater'
SystemRunner = require '../../src/javascript/ecs/system_runner'
FilterExpander = require '../../src/javascript/ecs/filter_expander'
SystemExpander = require '../../src/javascript/ecs/system_expander'

newEntityStore = -> new EntityStore()

newSystemRunner = (estore,systems) ->
  entityFinder = new EntityStoreFinder(estore)
  entityUpdater = new EntityStoreUpdater(estore)
  new SystemRunner(entityFinder, entityUpdater, systems)

findEntityComponent = (estore, eid, key, val) ->
  found = estore.getEntityComponents(eid).filter((c) -> c.get(key) == val).first()
  if found?
    return found
  else
    console.log "!! NO CAN FIND COMPONENT for eid=#{eid} where #{key}=#{val}"
    return null

checkByType = (estore, eid, m) ->
  pairs = Immutable.fromJS(m)
  pairs.toKeyedSeq().forEach (atts,type) ->
    comp = findEntityComponent(estore, eid, 'type', type)
    if !comp?
      assert.fail null,null, "NO COMPONENT, checking entity #{eid} for a component of type #{type}, examining attrs #{atts.toString()}"
    if !comp.isSuperset(atts)
      assert.fail comp,atts, "WRONG ATTRIBUTES, entity #{eid}'s #{type} component #{comp.toString()} should have matched attributes #{atts.toString()}"
      
defaultInput = imm({})

describe 'An ECS integration test', ->
  counterSystem = imm
    config:
      filters: [
        { match: { type: 'counter' }, as: 'counter' }
      ]
      
    update: (comps,input,u) ->
      counter = comps.get('counter').update 'ticks', (ticks) -> ticks + 1
      u.update counter


  it "updates game state by executing a system over the EntityStore", ->
    systems = imm [
      counterSystem
    ].map SystemExpander.expandSystem

    estore = newEntityStore()
    runner = newSystemRunner(estore, systems)

    counterEid = estore.createEntity [
      { type: 'counter', ticks: 0 }
    ]

    comp1 = findEntityComponent estore, counterEid, 'type','counter'
    expect(comp1.get('ticks')).to.eq 0

    runner.run(defaultInput)

    comp2 = findEntityComponent estore, counterEid, 'type','counter'
    expect(comp2.get('ticks')).to.eq 1

    runner.run(defaultInput)
    runner.run(defaultInput)

    comp3 = findEntityComponent estore, counterEid, 'type','counter'
    expect(comp3.get('ticks')).to.eq 3

  moverSystem = imm
    config:
      filters: [
        { match: { type: 'position' }, as: 'target' }
        { match: { type: 'velocity' }, join: 'target.eid', as: 'speed' }
      ]
      
    update: (comps,input,u) ->
      speed = comps.get('speed')
      target = comps.get('target')
        .update 'x', (x) -> x += speed.get('x')
        .update 'y', (y) -> y += speed.get('y')
      u.update target

  gravitySystem = imm
    config:
      filters: [
        { match: { type: 'gravity' } }
        { match: { type: 'velocity' }, join: 'gravity.eid' }
      ]
      
    update: (comps,input,u) ->
      gravity = comps.get('gravity')
      velocity = comps.get('velocity')
        .update 'y', (y) -> y += gravity.get('mag')
      u.update velocity

  it "process multiple systems combining multiple joined components", ->

    estore = newEntityStore()
    systems = imm [
      gravitySystem
      moverSystem
    ].map SystemExpander.expandSystem

    runner = newSystemRunner(estore, systems)

    m1 = estore.createEntity [
      { type: 'gravity', mag: 0.1 }
      { type: 'velocity', x: 5, y: 1 }
      { type: 'position', x: 50, y: 30 }
    ]
    m2 = estore.createEntity [
      { type: 'gravity', mag: 0.2 }
      { type: 'velocity', x: 3, y: 2 }
      { type: 'position', x: 100, y: 30 }
    ]

    checkByType estore, m1,
      velocity: { x: 5, y: 1 }
      position: { x: 50, y: 30 }

    checkByType estore, m2,
      velocity: { x: 3, y: 2 }
      position: { x: 100, y: 30 }

    runner.run(defaultInput)

    checkByType estore, m1,
      velocity: { x: 5, y: 1.1 }
      position: { x: 55, y: 31.1 }

    checkByType estore, m2,
      velocity: { x: 3, y: 2.2 }
      position: { x: 103, y: 32.2 }


  moverSystem2 = imm
    config:
      filters: [ 'position', 'velocity' ]
      
    update: (comps,input,u) ->
      velocity = comps.get('velocity')
      position = comps.get('position')
        .update 'x', (x) -> x += velocity.get('x')
        .update 'y', (y) -> y += velocity.get('y')
      u.update position

  gravitySystem2 = imm
    config:
      filters: [ 'gravity', 'velocity' ]
      
    update: (comps,input,u) ->
      gravity = comps.get('gravity')
      velocity = comps.get('velocity')
        .update 'y', (y) -> y += gravity.get('mag')
      u.update velocity


  it "systems using abbreviated filter config", ->

    estore = newEntityStore()
    systems = imm([
      gravitySystem2
      moverSystem2]).map SystemExpander.expandSystem

    runner = newSystemRunner(estore, systems)

    m1 = estore.createEntity [
      { type: 'gravity', mag: 0.1 }
      { type: 'velocity', x: 5, y: 1 }
      { type: 'position', x: 50, y: 30 }
    ]
    m2 = estore.createEntity [
      { type: 'gravity', mag: 0.2 }
      { type: 'velocity', x: 3, y: 2 }
      { type: 'position', x: 100, y: 30 }
    ]

    checkByType estore, m1,
      velocity: { x: 5, y: 1 }
      position: { x: 50, y: 30 }

    checkByType estore, m2,
      velocity: { x: 3, y: 2 }
      position: { x: 100, y: 30 }

    runner.run(defaultInput)

    checkByType estore, m1,
      velocity: { x: 5, y: 1.1 }
      position: { x: 55, y: 31.1 }

    checkByType estore, m2,
      velocity: { x: 3, y: 2.2 }
      position: { x: 103, y: 32.2 }
