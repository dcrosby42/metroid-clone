class A
  constructor: (@name) ->
    @stringer = @toString.bind(@)
  toString: ->
    "Hi my name is #{@name}"

class B extends A
  constructor: ->
    super()

  toString: ->
    "I am the B"


a = new A("fart")
console.log a.toString()

fn = a.toString
console.log fn()

fn = a.toString.bind(a)
console.log fn()

fn = a.stringer
console.log fn()

b = new B()
console.log b.toString()
fn = b.stringer
console.log fn()




