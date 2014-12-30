# The bigscreen.min.js library, when loaded, sets window.BigScreen
require './bigscreen.min'

window.BigScreen.doTheBigThing = (element) ->
  if BigScreen.enabled
    savedWidth = element.offsetWidth
    savedHeight = element.offsetHeight
    goingBig = ->
      element.style.width = "1200px"
      element.style.height = "900px"
      # element.style.width = "#{window.screen.width}px"
      # element.style.height = "#{window.screen.height}px"
      # console.log "window screen #{window.screen.width} x #{window.screen.height}"
    goingSmall = ->
      element.style.width = "#{savedWidth}px"
      element.style.height = "#{savedHeight}px"
    onError = (el,reason) ->
      console.log "Fullscreen failed because #{reason} on element:", el
    BigScreen.request element, goingBig, goingSmall, onError

module.exports = window.BigScreen
