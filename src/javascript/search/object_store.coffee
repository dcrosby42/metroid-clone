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

  # keypath = index.map (key) -> obj.get(key)
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
      return
    x = iter.next()

  # keypath = index.map (key) -> obj.get(key)
  indexStructure.updateIn keypath, EmptySet, (s) -> s.remove(objectId)

ObjectStore.indexObjects = (objs, index, identKey) ->
  objs.reduce (map, obj) ->
    ObjectStore.addObjectToIndex(obj, index, identKey, map)
    # keyPath = indexKeys.map (key) -> obj.get(key)
    # map.updateIn keyPath, EmptySet, (set) -> set.add(obj.get(identKey))
  , EmptyMap
    
#
# Store fns
#

ObjectStore.create = (dataKey, indices=EmptyList) ->
  ObjectStore.addIndices(
    ObjectStore.Empty.set('dataKey', dataKey),
    indices)

reindex = (store) ->
  objects = store.get('data').toList()
  dataKey = store.get('dataKey')
  store.update 'indexedData', (indexedData) ->
    indexedData.map (_, index) ->
      ObjectStore.indexObjects(objects, index, dataKey)

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

  # reindex(
  #   store.update 'data', (data) -> data.delete(object.get(store.get('dataKey')))
  # )

# TODO: testme
ObjectStore.updateObject = (store, object) ->
  store.setIn ['data', object.get(store.get('dataKey'))], object

ObjectStore.addObjects = (store, objects) ->
  reindex(
    store.set 'data', ObjectStore.mappedBy(objects, store.get('dataKey'))
  )

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
  List(store.get('data').values())


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
class Wrapper
  constructor: (@store) ->
  add: (obj) -> @store = ObjectStore.addObject @store, obj
  addAll: (objs) -> @store = ObjectStore.addObjects @store, objs
  addIndex: (indexedBy) -> @store = ObjectStore.addIndex @store, indexedBy
  get: (key) -> ObjectStore.getObject @store, key
  getIndexedObjectIds: (indexedBy, keyPath) -> ObjectStore.getIndexedObjectIds @store, indexedBy, keyPath
  getIndexedObjects: (indexedBy, keyPath) -> ObjectStore.getIndexedObjects @store, indexedBy, keyPath
  getIndices: () -> ObjectStore.getIndices @store
  hasIndex: (indexedBy) -> ObjectStore.hasIndex @store, indexedBy

ObjectStore.Wrapper = Wrapper

ObjectStore.createWrapper = (dataKey) -> new Wrapper(ObjectStore.create(dataKey))

module.exports = ObjectStore
