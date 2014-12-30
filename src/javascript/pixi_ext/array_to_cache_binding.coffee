
propertyIdent = (prop) -> (comp) -> comp[prop]

detectAdded = (source,cache,identFn) ->
  _.reject source, (c) -> cache[identFn(c)]?

detectRemoved = (source,cache,identFn) ->
  cacheKeys = _.keys(cache)
  sourceKeys = _.map source, (c) -> identFn(c)
  removedKeys = _.difference cacheKeys, sourceKeys
  _.map removedKeys, (key) -> cache[key]

updateStatefulBinding = ({source,cache,addFn,removeFn,syncFn,identFn,identKey}) ->
  if identKey? and !identFn?
    identFn = propertyIdent(identKey)

  for newItem in detectAdded(source,cache,identFn)
    cache[identFn(newItem)] = addFn(newItem, key)

  for oldItem in detectRemoved(source,cache,identFn)
    key = identFn(oldItem)
    obj = cache[key]
    delete cache[key]
    removeFn obj, key

  for comp in source
    syncFn comp, cache[identFn(comp)]

  cache

ArrayToCacheBinding =
  update: updateStatefulBinding

module.exports = ArrayToCacheBinding
