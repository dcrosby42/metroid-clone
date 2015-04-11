FilterExpander = require './filter_expander'

class EntityStoreFinder
  constructor: (@estore) ->
  search:      (filters) -> @estore.search FilterExpander.expandFilters(filters)

module.exports = EntityStoreFinder
