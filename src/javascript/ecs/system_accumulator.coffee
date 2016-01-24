class SystemAccumulator
  constructor: ->
    @systems = []
  add: (sysNs, name) ->
    if sysNs
      system = sysNs[name]
      if system?
        if system.Instance?
          @systems.push system
        else
          msg = "Object provided as class for system '#{name}' does not support Instance()"
          console.log msg,system
          throw msg
      else
        console.log "!! No system '#{name}' found in namespace:",sysNs
        throw "No system '#{name}' found in namespace"
    else
      throw "Null namespace given when adding system named '#{name}"

module.exports = SystemAccumulator
