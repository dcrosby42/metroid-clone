Immutable = require 'immutable'
{Map,List,Set} = Immutable

EmptyMap = Map()
EmptyList = List()

isBlank = (s) -> !s? or s.match(/^\s*$/)

filterMap_string = (data,filter) ->
  return data if isBlank(filter)
  filterMap(data,List(filter.split('.')))

filterMap = (data,filterSteps) ->
  return data if filterSteps.size == 0 or filterSteps.size == 1 and isBlank(filterSteps.get(0))
  
  if Map.isMap(data)
    # console.log "filter map",data,filterSteps
    step = filterSteps.first()
    restSteps = filterSteps.shift()
    res = EmptyMap
    data.forEach (val,key) ->
      # console.log "  applying filter",key,step
      if key.match(///#{step}///i)
        #console.log "    matched key. val=",val
        if Map.isMap(val) or List.isList(val)
          #console.log "    submap is iterable."
          val1 = filterMap(val,restSteps)
          if val1.size > 0
            res = res.set(key,val1)
        else
          res = res.set(key,val)
        if ((Map.isMap(val1) or List.isList(val1)) and val1.size)
          res = res.set(key,val1)
      #   else
      #     console.log "dropping key #{key} due to empty filtered child",val1
      # else
      #   console.log "dropping key #{key}; not match",step
    res
  else if List.isList(data)
    # console.log "filter list",data,filterSteps
    res = EmptyList
    data.forEach (val) ->
      # console.log " applying filter",val,filterSteps
      val1 = filterMap(val,filterSteps)
      if val1.size > 0
        # console.log "including",val1
        res = res.push(val1)
    res
  else
    # console.log "passthru",data
    data


module.exports = filterMap_string
