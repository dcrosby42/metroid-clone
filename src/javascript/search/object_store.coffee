Immutable = require 'immutable'
{List,Set,Map,OrderedMap} = Immutable
EmptySet = Set()
EmptyMap = Map()
EmptyList = List()
EmptyOrderedMap = OrderedMap()

ObjectStore = {}

ObjectStore.Empty = Map
  data: EmptyMap
  dataKey: 'id'
  indexedData: EmptyOrderedMap
  
ObjectStore.mappedBy = (objs,key) ->
  objs.reduce (map, obj) ->
    map.set obj.get(key), obj
  , EmptyMap

ObjectStore.addObjectToIndex = (obj,index,identKey,map) ->
  keypath = []
  iter = index.values()
  x = iter.next()
  while !x.done
    v = obj.get(x.value)
    if v?
      keypath.push(v)
    else
      return
    x = iter.next()
  map.updateIn keypath, EmptySet, (s) -> s.add(obj.get(identKey))

ObjectStore.removeObjectFromIndex = (indexStructure,indexKeys,object,objectId) ->
  keypath = []
  iter = indexKeys.values()
  x = iter.next()
  while !x.done
    v = object.get(x.value)
    if v?
      keypath.push(v)
    else
      return indexStructure
    x = iter.next()

  # Remove id from set:
  ids = indexStructure.getIn(keypath)
  if !ids?
    console.log "!! ObjectStore.removeObjectFromIndex: no id set in index for keypath #{keypath}", indexStructure.toJS(), indexKeys.toJS(),object.toJS(),objectId
    return indexStructure
  ids = ids.remove(objectId)
  if ids.isEmpty()
    # Last member in the set! Remove this node from the index:
    indexStructure = indexStructure.removeIn(keypath)
    keypath.pop()
    # Walk back up the path cleaning up as we go:
    while keypath.length > 0 and indexStructure.getIn(keypath).isEmpty()
      indexStructure = indexStructure.removeIn(keypath)
      keypath.pop()
  else
    # no cleanup, just put the reduced set back:
    indexStructure = indexStructure.setIn(keypath,ids)

  return indexStructure

ObjectStore.indexObjects = (objectsIter, indexKeys, identKey) ->
  indexStructure = EmptyMap
  x = objectsIter.next()
  while !x.done
    object = x.value
    indexStructure = ObjectStore.addObjectToIndex(object, indexKeys, identKey, indexStructure)
    x = objectsIter.next()
  return indexStructure
    
#
# Store fns
#

ObjectStore.create = (dataKey, indices=EmptyList) ->
  ObjectStore.addIndices(
    ObjectStore.Empty.set('dataKey', dataKey),
    indices)

reindex = (store) ->
  # objects = store.get('data').toList()
  dataKey = store.get('dataKey')
  store.update 'indexedData', (indexedData) ->
    indexedData.map (_, index) ->
      ObjectStore.indexObjects(store.get('data').values(), index, dataKey)

ObjectStore.addObject = (store, object) ->
  dataKey = store.get('dataKey')
  store = store.setIn ['data', object.get(dataKey)], object
  # updateIndexedData
  store.update 'indexedData', (indexedData) ->
    indexedData.map (indexStructure, indexKeys) ->
      ObjectStore.addObjectToIndex(object, indexKeys, dataKey, indexStructure)

  # reindex(
  #   store.setIn ['data', object.get(store.get('dataKey'))], object
  # )

ObjectStore.removeObject = (store,object) ->
  objectId = object.get(store.get('dataKey'))
  store = store.update 'data', (data) -> data.delete(objectId)
  store.update 'indexedData', (indexedData) ->
    indexedData.map (indexStructure, indexKeys) ->
      ObjectStore.removeObjectFromIndex(indexStructure, indexKeys, object, objectId)

# TODO: testme
ObjectStore.updateObject = (store, object) ->
  store.setIn ['data', object.get(store.get('dataKey'))], object

ObjectStore.addObjects = (store, objects) ->
  objects.forEach (o) -> store = ObjectStore.addObject(store,o)
  store

ObjectStore.getObject = (store, key) ->
  store.get('data').get(key) or null

ObjectStore.addIndex = (store, indexKeyset) ->
  reindex(
    store.update 'indexedData', (m) -> m.set(indexKeyset, EmptyMap)
  )

ObjectStore.addIndices = (store, indexKeysets) ->
  reindex(
    store.update 'indexedData', (indexedData) ->
      indexKeysets.reduce (indexedData,keyset) ->
        indexedData.set(keyset, EmptyMap)
      , indexedData
  )

ObjectStore.hasIndex = (store, indexedBy) ->
  store.get('indexedData').has(indexedBy)

ObjectStore.getIndices = (store) ->
  store.get('indexedData').keySeq()

# TODO return a Seq instead of the actual Set?
ObjectStore.getIndexedObjectIds = (store, indexedBy, keyPath) ->
  index = store.get('indexedData').get(indexedBy)
  if index?
    index.getIn(keyPath) || EmptySet
  else
    EmptySet

ObjectStore.getIndexedObjects = (store, indexedBy, keyPath) ->
  ObjectStore.getIndexedObjectIds(store,indexedBy,keyPath).map (cid) ->
    ObjectStore.getObject(store,cid)


ObjectStore.allObjects = (store) ->
  store.get('data').valueSeq()

ObjectStore.allObjectsIter = (store) ->
  store.get('data').values()

listSize = (l) -> l.size

ObjectStore.selectMatchingIndex = (indices, keys) ->
  matchAllKeys = (index) -> index.every (k) -> keys.has(k)
  indices
    .filter(matchAllKeys)
    .sortBy(listSize)
    .last() or null

ObjectStore.bestIndexForKeys = (store, keys) ->
  ObjectStore.selectMatchingIndex(ObjectStore.getIndices(store), keys)

#
# ObjectStore wrapper class:
#
# class Wrapper
#   constructor: (@store) ->
#   add: (obj) -> @store = ObjectStore.addObject @store, obj
#   addAll: (objs) -> @store = ObjectStore.addObjects @store, objs
#   addIndex: (indexedBy) -> @store = ObjectStore.addIndex @store, indexedBy
#   get: (key) -> ObjectStore.getObject @store, key
#   getIndexedObjectIds: (indexedBy, keyPath) -> ObjectStore.getIndexedObjectIds @store, indexedBy, keyPath
#   getIndexedObjects: (indexedBy, keyPath) -> ObjectStore.getIndexedObjects @store, indexedBy, keyPath
#   getIndices: () -> ObjectStore.getIndices @store
#   hasIndex: (indexedBy) -> ObjectStore.hasIndex @store, indexedBy
#
# ObjectStore.Wrapper = Wrapper
#
# ObjectStore.createWrapper = (dataKey) -> new Wrapper(ObjectStore.create(dataKey))

module.exports = ObjectStore
