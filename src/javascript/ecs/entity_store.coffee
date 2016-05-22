Immutable = require 'immutable'
{Map,List} = Immutable

ObjectStore = require '../search/object_store'
ObjectStoreSearch = require '../search/object_store_search'
FilterExpander = require './filter_expander'

SeqGen = require './id_sequence_generator'

EidIndex     = List(['eid'])
TypeIndex    = List(['type'])
EidTypeIndex = List(['eid','type'])

Indices = List [
  EidIndex
  TypeIndex
  EidTypeIndex
]

CleanSlate = Map
  compStore: ObjectStore.create('cid',Indices)
  eidGen:    SeqGen.new('e', 0)
  cidGen:    SeqGen.new('c', 0)


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
      comps = ObjectStore.getIndexedObjects(@state.get('compStore'), EidTypeIndex, List([eid,type]))
      if matchKey? and matchVal?
        comps.filter (comp) -> comp.get(matchKey) == matchVal
      else
        comps
    else
      ObjectStore.getIndexedObjects(@state.get('compStore'), EidIndex, List([eid]))

  forEachComponent: (f) ->
    ObjectStore.allObjects(@state.get('compStore')).forEach f

  search: (filters) ->
    ObjectStoreSearch.search @state.get('compStore'), filters

class EntityStore extends ReadOnlyEntityStore
  @expandSearch: (filterGroups) ->
    FilterExpander
      .expandFilterGroups(filterGroups)
      .map (filter) ->
        ObjectStoreSearch.convertMatchesToIndexLookups(filter, Indices)

  constructor: (state=null) ->
    super(state or CleanSlate)

  #
  # WRITE
  #

  restoreSnapshot: (@state) ->
  
  createEntity: (compProps) ->
    eid = @_nextEntityId()
    if compProps?
      List(compProps).forEach (props) =>
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
  _update: (key,fn) -> @state = @state.update key, fn

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

EntityStore.Indices = Indices
EntityStore.EidIndex = EidIndex
EntityStore.TypeIndex = TypeIndex
EntityStore.EidTypeIndex = EidTypeIndex

module.exports = EntityStore
if typeof window != 'undefined' then window.EntityStore = EntityStore



