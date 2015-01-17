
propertyIdent = (prop) -> (comp) -> comp[prop]

detectAdded = (source,cache,identFn) ->
  _.reject source, (c) -> cache[identFn(c)]?

detectRemovedKeys = (source,cache,identFn) ->
  cacheKeys = _.keys(cache)
  sourceKeys = _.map source, (c) -> identFn(c)
  removedKeys = _.difference cacheKeys, sourceKeys
  removedKeys

updateStatefulBinding = ({source,cache,addFn,removeFn,syncFn,identFn,identKey}) ->
  if identKey? and !identFn?
    identFn = propertyIdent(identKey)

  for newItem in detectAdded(source,cache,identFn)
    key = identFn(newItem)
    obj = addFn(newItem,key)
    cache[key] = obj

  for removedKey in detectRemovedKeys(source,cache,identFn)
    obj = cache[removedKey]
    delete cache[removedKey]
    removeFn obj, removedKey

  for comp in source
    syncFn comp, cache[identFn(comp)]

  cache

ArrayToCacheBinding =
  update: updateStatefulBinding

module.exports = ArrayToCacheBinding
