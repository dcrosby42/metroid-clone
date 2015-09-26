
isFunction = (functionToCheck) ->
  functionToCheck and ({}.toString.call(functionToCheck) == '[object Function]')


propReaderFn = (prop) ->
  (comp) -> comp[prop]

detectAdded = (source,cache,keyFn) ->
  _.reject source, (c) -> cache[keyFn(c)]?

detectRemovedKeys = (source,cache,keyFn) ->
  cacheKeys = _.keys(cache)
  sourceKeys = _.map source, (c) -> keyFn(c)
  removedKeys = _.difference cacheKeys, sourceKeys
  removedKeys

_updateStatefulBinding = (source,cache,keyFn,addFn,syncFn,removeFn) ->
  for newItem in detectAdded(source,cache,keyFn)
    key = keyFn(newItem)
    obj = addFn(newItem,key)
    cache[key] = obj

  for removedKey in detectRemovedKeys(source,cache,keyFn)
    obj = cache[removedKey]
    delete cache[removedKey]
    removeFn obj, removedKey

  for comp in source
    syncFn comp, cache[keyFn(comp)]

  return cache

updateStatefulBinding = ({source,cache,addFn,removeFn,syncFn,keyFn,keyProp}) ->
  if keyProp? and !keyFn?
    keyFn = propReaderFn(keyProp)
  if !isFunction(keyFn)
    console.log "updateStatefulBinding: keyFn not a fn:",keyFn
  return _updateStatefulBinding(source,cache,keyFn,addFn,syncFn,removeFn)


makeUpdater = ({addFn,removeFn,syncFn,keyFn,keyProp}) ->
  if keyProp? and !keyFn?
    keyFn = propReaderFn(keyProp)
  if !isFunction(keyFn)
    console.log "makeUpdater: keyFn not a fn:",keyFn
  fn = (source,cache) ->
    _updateStatefulBinding(source,cache,keyFn,addFn,syncFn,removeFn)


ArrayToCacheBinding =
  update: updateStatefulBinding
  getUpdateFn: makeUpdater

module.exports = ArrayToCacheBinding
