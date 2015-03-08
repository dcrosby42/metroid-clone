Immutable = require 'immutable'
_ = require 'lodash'

SeqGen = require './id_sequence_generator'

class EntityStore
  constructor: ->
    @eidGen = SeqGen.new 'e', 0
    @cidGen = SeqGen.new 'c', 0

    @componentsByCid = Immutable.Map()
    @indices = Immutable.Map()

  createEntity: (compProps) ->
    eid = @_nextEntityId()
    if compProps?
      for props in compProps
        @createComponent eid, props
    eid

  getEntityComponents: (eid) ->
    # Shortcut: instead of searching, jump straight to the eid index:
    (@indices.getIn(['eid',eid]) || Immutable.Set()).map (cid) => @componentsByCid.get(cid)

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
      cids = index.get(key).delete(cid)
      if cids.size > 0
        index.set(key, cids)
      else
        index.delete(key)
    
    

module.exports = EntityStore




