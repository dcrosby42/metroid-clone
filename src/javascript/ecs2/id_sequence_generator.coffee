Immutable = require 'immutable'

IdSequenceGenerator =
  new: (prefix='id',number=0) ->
    Immutable.Map
      number: number
      prefix: prefix
      value:  "#{prefix}#{number}"

  next: (gen) ->
    num = gen.get('number') + 1
    gen
      .set('number',num)
      .set('value', "#{gen.get('prefix')}#{num}")

module.exports = IdSequenceGenerator

