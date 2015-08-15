Immutable = require 'immutable'
SeqGen = require './id_sequence_generator'
Finder = require '../search/immutable_object_finder'

class EntityStore
  @initialState: ->
    Immutable.Map
      componentsByCid: Immutable.Map()
      indices:         Immutable.Map()
      eidGen:          SeqGen.new('e', 0)
      cidGen:          SeqGen.new('c', 0)

  constructor: ->
    @restoreSnapshot EntityStore.initialState()

  takeSnapshot: ->
    Immutable.Map
      componentsByCid: @componentsByCid
      indices: @indices
      eidGen: @eidGen
      cidGen: @cidGen

  restoreSnapshot: (state) ->
    @componentsByCid = state.get('componentsByCid')
    @indices = state.get('indices')
    @eidGen = state.get('eidGen')
    @cidGen = state.get('cidGen')
  
  createEntity: (compProps) ->
    eid = @_nextEntityId()
    if compProps?
      Immutable.List(compProps).forEach (props) =>
        @createComponent eid, props
    eid

  getEntityComponents: (eid,type,matchKey=null,matchVal=null) ->
    # Shortcut: instead of searching, jump straight to the eid index:
    comps = (@indices.getIn(['eid',eid]) || Immutable.Set()).map (cid) => @componentsByCid.get(cid)
    if type?
      if matchKey? and matchVal?
        comps.filter (comp) ->
          (comp.get('type') == type) and (comp.get(matchKey) == matchVal)
      else
        comps.filter (comp) -> comp.get('type') == type
    else
      comps

  getEntityComponent: (eid,type,matchKey=null,matchVal=null) ->
    @getEntityComponents(eid,type,matchKey,matchVal).first()
    

  createComponent: (eid,props) ->
    cid = @_nextComponentId()
    comp = @_newComponent eid, cid, props
    @componentsByCid = @componentsByCid.set cid, comp
    @_addToIndex 'eid', comp
    comp

  getComponent: (cid) ->
    @componentsByCid.get cid

  updateComponent: (comp) ->
    # ASSUMES NO INDEXABLE FIELDS ON COMP CAN BE CHANGED... otherwise our indices are now invalid
    # That goes for entity id (eid) as well!
    cid = comp.get('cid')
    @componentsByCid = @componentsByCid.set(cid, comp)

  deleteComponent: (comp) ->
    cid = comp.get('cid')
    @componentsByCid = @componentsByCid.delete cid
    @_deleteFromIndex 'eid', comp
    null

  destroyEntity: (eid) ->
    @getEntityComponents(eid).forEach (comp) =>
      @deleteComponent(comp)

  search: (filters) ->
    Finder.search @componentsByCid.toList(), filters

  allComponentsByCid: -> @componentsByCid

  readOnly: ->
    @_readOnly ?= new ReadOnlyEntityStore(@)

  #
  # PRIVATE
  #

  _newComponent: (eid, cid, props) ->
    comp = Immutable.fromJS(props)
      .set('eid',eid)
      .set('cid',cid)
    if !comp.get('type')
      console.log "EntityStore#_newComponent: creating component with no 'type' field", comp
    comp
      

  # ID generators:

  _nextEntityId: ->
    @eidGen = SeqGen.next(@eidGen)
    @eidGen.get('value')

  _nextComponentId: ->
    @cidGen = SeqGen.next(@cidGen)
    @cidGen.get('value')

  # Indexing:

  _addToIndex: (indexName, comp) ->
    cid = comp.get('cid')
    key = comp.get(indexName)
    @indices = @indices.updateIn [indexName,key], (s) -> if s? then s.add(cid) else Immutable.Set([cid])

  _deleteFromIndex: (indexName,comp) ->
    cid = comp.get('cid')
    key = comp.get(indexName)

    @indices = @indices.update indexName, (index) ->
      if index
        if bucket = index.get(key)
          cids = bucket.delete(cid)
          if cids.size > 0
            index.set(key, cids)
          else
            index.delete(key)
        else
          console.log "!!EntityStore._deleteFromIndex: no bucket for index #{indexName}, key #{key}", comp.toJS()
      else
        console.log "!!EntityStore._deleteFromIndex: no index #{indexName}, key #{key}", comp.toJS()

class ReadOnlyEntityStore
  constructor: (@estore) ->

  search:             (filters) -> @estore.search(filters)
  allComponentsByCid:           -> @estore.allComponentsByCid()
  getEntityComponents: (eid,type,matchKey=null,matchVal=null) ->
    @estore.getEntityComponents(eid,type,matchKey,matchVal)
  getEntityComponent: (eid,type,matchKey=null,matchVal=null) ->
    @estore.getEntityComponent(eid,type,matchKey,matchVal)
    
module.exports = EntityStore




