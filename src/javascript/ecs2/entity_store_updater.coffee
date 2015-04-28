class EntityStoreUpdater
  constructor: (@estore) ->
  update:         (comp) -> @estore.updateComponent comp
  delete:         (comp) -> @estore.deleteComponent comp
  add:       (eid,props) -> @estore.createComponent eid, props
  newEntity:     (comps) -> @estore.createEntity comps
  destroyEntity:   (eid) -> @estore.destroyEntity eid

module.exports = EntityStoreUpdater
