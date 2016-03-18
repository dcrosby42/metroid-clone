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

ObjectStore.indexObjects = (objs, indexKeys, identKey) ->
  objs.reduce (map, obj) ->
    keyPath = indexKeys.map (key) -> obj.get(key)
    map.updateIn keyPath, EmptySet, (set) -> set.add(obj.get(identKey))
  , EmptyMap
    
#
# Store fns
#

ObjectStore.create = (dataKey, indices=EmptyList) ->
  ObjectStore.addIndices(
    ObjectStore.Empty.set('dataKey', dataKey),
    indices)

reindex = (store) ->
  store.update 'indexedData', (indexedData) ->
    indexedData.map (_, indexedBy) ->
      ObjectStore.indexObjects(
        store.get('data').toList()
        indexedBy
        store.get('dataKey')
      )

ObjectStore.addObject = (store, object) ->
  reindex(
    store.setIn ['data', object.get(store.get('dataKey'))], object
  )

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

# TODO: removeObject
ObjectStore.removeObject = (store,object) ->
  reindex(
    store.update 'data', (data) -> data.delete(object.get(store.get('dataKey')))
  )

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
