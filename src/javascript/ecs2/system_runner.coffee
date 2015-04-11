
searchAndUpdate = (system, entityFinder, input, entityUpdater) ->
  filters = system.getIn ['config','filters']
  update = system.get 'update'
  entityFinder.search(filters).forEach (result) ->
    update(result,input,entityUpdater)

class SystemRunner
  constructor: (@entityFinder, @entityUpdater, @systems) ->

  run: (input) ->
    @systems.forEach (system) =>
      switch system.get('type')
        when 'iterating-updating'
          searchAndUpdate system, @entityFinder, input, @entityUpdater
          
        else
          console.log "!! CAN'T RUN SYSTEM OF TYPE: #{system.get('type')} - #{system.toString()}"

module.exports = SystemRunner

