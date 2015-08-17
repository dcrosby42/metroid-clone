expect = require('chai').expect

describe 'an array', ->
  # arr = [1,2,3]
  # it 'should be 3 long', ->
  #   expect(arr.length).to.eq(3)
  # it 'should have a 2 in the middle', ->
  #   expect(arr[1]).to.eq(2)
  it 'box', ->
    x = 0
    y = 0
    w = 4
    h = 4
    left = x+w
    right = x+w
    top = y
    bottom = y+h

    ts = 16


