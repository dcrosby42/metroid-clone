class Failure
  constructor: (@clazz,@comp,@message,@cloned) ->
  toString: ->
    s = "!! Component '#{@clazz.name}': #{@message}. comp=#{JSON.stringify(@comp)}"
    if @cloned?
      s += " cloned=#{JSON.stringify(@cloned)}"
    s

runComponentTest = (clazz) ->
  # console.log "Comp test for #{clazz.name}"
  comp = null
  fails = []
  fail = (args...) -> fails.push new Failure(clazz,comp,args...)

  if clazz == null or typeof clazz != 'function'
    fail "Can't run component test on this"
    return fails
  if !clazz.name?
    fail "Object #{clazz} doesn't have a name"
    return fails

  if !clazz.default?
    fail "#{clazz.name}.default() not implemented"
    return fails

  comp = clazz.default()

  if !comp.type? then fail "type not set"
  if !comp.clone? then fail "#{clazz.name}.clone() not implemented"
  if !comp.equals? then fail "#{clazz.name}.equals() not implemented"

  comp.eid = 1000
  comp.cid = 2222
  if comp.clone?
    cloned = comp.clone()
    if !cloned?
      fail "comp.clone() returned #{typeof cloned}"
      return fails
    if cloned.eid != comp.eid then fail "expected clone to have eid=#{comp.eid}",cloned
    if cloned.cid != comp.cid then fail "expected clone to have cid=#{comp.cid}",cloned
    if comp.equals?
      if comp.equals(cloned) != true then fail "expected comp.equals(cloned) to be true",cloned
      other = comp.clone()
      other.eid = 12345
      if comp.equals(other) != false then fail "expected comp.equals(other) to be false due to mismatched eid",other
      other.eid = 98765
      if comp.equals(other) != false then fail "expected comp.equals(other) to be false due to mismatched cid",other
  
  return fails


exports.run = (module, {types,excused}) ->
  fails = []
  count = 0
  for key,clazz of module
    if excused.indexOf(key) == -1
      count++
      try
        fails = fails.concat(runComponentTest(clazz))
      catch err
        fails.push new Failure(clazz,null,"TOTAL BONAGE: #{err.stack}")

  if fails.length > 0
    console.log "============================"
    console.log "COMPONENT SMOKE TESTS FAILED"
    console.log "============================"
    for fail in fails
      console.log fail.toString()
  # else
  #   console.log "==============================="
  #   console.log "Passed #{count} component tests"
  #   console.log "==============================="



 

# eid, cid
# exported
# equals
# clone
