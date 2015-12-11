Immutable = require 'immutable'
SeqGen = require './id_sequence_generator'
Finder = require '../search/immutable_object_finder'
ObjectStore = require './object_store'

EidIndex     = Immutable.List(['eid'])
TypeIndex    = Immutable.List(['type'])
EidTypeIndex = Immutable.List(['eid','type'])

class ReadOnlyEntityStore
  constructor: (@state) ->

  takeSnapshot: ->
    @state

  getComponent: (cid) ->
    ObjectStore.getObject(@state.get('compStore'), cid)

  getEntityComponent: (eid,type,matchKey=null,matchVal=null) ->
    @getEntityComponents(eid,type,matchKey,matchVal).first()
    
  getEntityComponents: (eid,type,matchKey=null,matchVal=null) ->
    if type?
      comps = ObjectStore.getIndexedObjects(@state.get('compStore'), EidTypeIndex, [eid])
      if matchKey? and matchVal?
        comps.filter (comp) -> comp.get(matchKey) == matchVal
      else
        comps
    else
      ObjectStore.getIndexedObjects(@state.get('compStore'), EidIndex, [eid])

  allComponentsByCid: ->
    ObjectStore.allObjects(@state.get('compStore'))

  search: (filters) ->
    ObjectStoreSearch.search @state.get('compStore'), filters

class EntityStore extends ReadOnlyEntityStore

  @initalCompStore: ->
    s = ObjectStore.create('cid')
    s = ObjectStore.addIndex(s, TypeIndex)
    s = ObjectStore.addIndex(s, EidIndex)
    s = ObjectStore.addIndex(s, EidTypeIndex)
    s

  @initialState: ->
    Immutable.Map
      compStore: EntityStore.initialCompStore()
      eidGen:    SeqGen.new('e', 0)
      cidGen:    SeqGen.new('c', 0)

  constructor: ->
    super EntityStore.initialState()
    # @restoreSnapshot EntityStore.initialState()

  #
  # WRITE
  #

  restoreSnapshot: (@state) ->
  
  createEntity: (compProps) ->
    eid = @_nextEntityId()
    if compProps?
      Immutable.List(compProps).forEach (props) =>
        @createComponent eid, props
    eid

  createComponent: (eid,props) ->
    comp = @_newComponent eid, @_nextComponentId(), props
    @_update 'compStore', (compStore) -> ObjectStore.addObject(compStore,comp)
    comp

  updateComponent: (comp) ->
    # ASSUMES NO INDEXABLE FIELDS ON COMP CAN BE CHANGED... otherwise our indices are now invalid
    @_update 'compStore', (compStore) -> ObjectStore.updateObject(compStore,comp)
    comp

  deleteComponent: (comp) ->
    @_update 'compStore', (compStore) -> ObjectStore.removeObject(compStore,comp)
    null

  destroyEntity: (eid) ->
    @getEntityComponents(eid).forEach (comp) =>
      @deleteComponent(comp)

  #
  # PRIVATE
  #
  _update: (key,fn) -> @state = @state.upddate key, fn

  _newComponent: (eid, cid, props) ->
    comp = Immutable.fromJS(props)
      .set('eid',eid)
      .set('cid',cid)
    if !comp.get('type')
      console.log "EntityStore#_newComponent: creating component with no 'type' field", comp
    comp

  # ID generators:

  _nextEntityId: ->
    @_update('eidGen', SeqGen.next)
      .getIn(['eidGen','value'])

  _nextComponentId: ->
    @_update('cidGen', SeqGen.next)
      .getIn(['cidGen','value'])


module.exports = EntityStore




