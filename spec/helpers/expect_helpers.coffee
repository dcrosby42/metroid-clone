Immutable = require 'immutable'
chai = require('chai')
assert = chai.assert

exports.expectIs = (actual,expected) ->
  if !Immutable.is(actual,expected)
    assert.fail(actual,expected,"Immutable structures not equal.\nExpected: #{expected.toString()}\n  Actual: #{actual.toString()}")

