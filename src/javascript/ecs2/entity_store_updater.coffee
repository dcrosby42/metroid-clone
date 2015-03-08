class EntityStoreUpdater
  constructor: (@estore) ->
  update:         (comp) -> @estore.updateComponent comp
  delete:         (comp) -> @estore.deleteComponent comp
  add:       (eid,props) -> @estore.createComponent eid, props
  newEntity: (propsList) -> @estore.createEntity propsList

module.exports = EntityStoreUpdater
