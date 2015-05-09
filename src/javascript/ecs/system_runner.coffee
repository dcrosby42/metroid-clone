
searchAndUpdate = (system, estore, input, entityUpdater) ->
  filters = system.getIn ['config','filters']
  update = system.get 'update'
  estore.search(filters).forEach (result) ->
    update(result,input,entityUpdater)

class SystemRunner
  constructor: (@estore, @entityUpdater, @systems) ->
    # @systems.forEach (system) ->
    #   console.log "System: #{system.getIn(['config','filters']).toString()}"

  run: (input) ->
    @systems.forEach (system) =>
      switch system.get('type')
        when 'iterating-updating'
          searchAndUpdate system, @estore, input, @entityUpdater
          
        else
          console.log "!! CAN'T RUN SYSTEM OF TYPE: #{system.get('type')} - #{system.toString()}"

module.exports = SystemRunner

