Config = require './config'
FilterExpander1 = require './filter_expander1'
FilterExpander2 = require './filter_expander2'

if Config.entity_store_version == 2
  module.exports = FilterExpander2
else
  module.exports = FilterExpander1
