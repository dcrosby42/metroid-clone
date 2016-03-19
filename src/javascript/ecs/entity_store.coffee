Config = require './config'
EntityStore1 = require './entity_store1'
EntityStore2 = require './entity_store2'

if Config.entity_store_version == 2
  module.exports = EntityStore2
else
  module.exports = EntityStore1
