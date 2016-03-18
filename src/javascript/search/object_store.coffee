Immutable = require 'immutable'
EmptySet = Immutable.Set()

ObjectStore = {}

ObjectStore.Empty = Immutable.Map
  data: Immutable.Map()
  dataKey: 'id'
  indexedData: Immutable.OrderedMap()
  

ObjectStore.mappedBy = (objs,key) ->
  objs.reduce (map, obj) ->
    map.set obj.get(key), obj
  , Immutable.Map()

ObjectStore.indexObjects = (objs, indexKeys, identKey) ->
  objs.reduce (map, obj) ->
    keyPath = indexKeys.map (key) -> obj.get(key)
    map.updateIn keyPath, EmptySet, (set) -> set.add(obj.get(identKey))
  , Immutable.Map()
    
#
# Store fns
#

ObjectStore.create = (dataKey) ->
  ObjectStore.Empty.set('dataKey', dataKey)

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

ObjectStore.addIndex = (store, indexedBy) ->
  reindex(
    store.update 'indexedData', (indexedData) ->
      indexedData.set indexedBy, Immutable.Map()
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
# TODO: allObjects
ObjectStore.allObjects = (store) ->
  Immutable.List(store.get('data').values())


listSize = (l) -> l.size

ObjectStore.bestIndexForKeys = (store, keys) ->
  matchAllKeys = (index) -> index.every (k) -> keys.has(k)
  ObjectStore.getIndices(store)
    .filter(matchAllKeys)
    .sortBy(listSize)
    .last() or null


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
