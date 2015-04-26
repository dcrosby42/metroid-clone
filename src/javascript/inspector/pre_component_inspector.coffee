
class PreComponentInspector
  constructor: (@holder) ->

  update: (comp) ->
    @holder.textContent = comp.toString()

module.exports = PreComponentInspector

