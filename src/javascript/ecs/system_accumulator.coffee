class SystemAccumulator
  constructor: ->
    @systems = []
  add: (sysNs, name) ->
    if sysNs
      if system = sysNs[name]
        @systems.push system
      else
        console.log "!! No system '#{name}' found in namespace:",sysNs
        throw "No system '#{name}' found in namespace"
    else
      throw "Null namespace given when adding system named '#{name}"

module.exports = SystemAccumulator
