Immutable = require 'immutable'

class EntityStoreUpdater
  constructor: (@estore) ->
  update:         (comp) -> @estore.updateComponent comp
  delete:         (comp) -> @estore.deleteComponent comp
  add:       (eid,props) -> @estore.createComponent eid, props
  newEntity:     (comps) -> @estore.createEntity comps
  destroyEntity:   (eid) -> @estore.destroyEntity eid

  getEntityComponents: (eid,type) -> @estore.getEntityComponents(eid,type)
  getEntityComponent: (eid,type) -> @estore.getEntityComponent(eid,type)

  # TODO: rethink... try not to do this under normal circumstances:
  # updateEntityComponent: (eid,type,atts) ->
  #   comp = @getEntityComponent(eid,type)
  #   @update comp.merge(Immutable.fromJS(atts))

module.exports = EntityStoreUpdater
