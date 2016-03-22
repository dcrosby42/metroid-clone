SystemLogInspector = require './system_log_inspector'


module.exports =
  create: (args...) -> new SystemLogInspector(args...)
