chai = require('chai')
expect = chai.expect
assert = chai.assert

C = require '../../../src/javascript/components'
T = C.Types
Systems = require '../../../src/javascript/game2/systems'
# EntityStore = require '../../../src/javascript/ecs2/entity_store'
# EntitySearch = require '../../../src/javascript/ecs2/entity_search'
# Immutable = require 'immutable'

describe "Systems", ->
  it "can be constructed and have process() methods", ->
    for key,val of Systems
      expect(typeof val).to.equal('function',key)
      sys = val()
      expect(sys.constructor.name,key).to.not.be.undefined
      expect(typeof sys.process).to.equal('function',key)
