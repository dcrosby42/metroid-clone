Immutable = require 'immutable'

FilterExpander = require './filter_expander'

expandSystemConfig = (system) ->
  system.updateIn ['config','filters'], FilterExpander.expandFilters

module.exports =
  expandSystemConfig: expandSystemConfig
