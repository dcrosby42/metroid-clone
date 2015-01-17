CompositeEvent = require '../utils/composite_event'

window.createjs ||= {}
createjs = window.createjs
require '../vendor/soundjs-0.6.0.min'

createjs.Sound.alternateExtensions = ["mp3"]

class SoundController
  @wrapper: {}

  # Preload sound assets.
  #   soundMap is structured like { id: src }
  #   callback will be called when all sounds have loaded
  @loadSoundMap: (soundMap, callback) ->
    # Transform { id: src ... } map into a manifest like [ { id:id, src:src } ... ]
    ids = []
    manifest = []
    _.forOwn soundMap, (src,id) ->
      ids.push id
      manifest.push {id:id, src:src}

    # Create an event that will invoke callback once all soundIds are reported as loaded
    soundsLoadedEvent = CompositeEvent.create ids, callback

    createjs.Sound.addEventListener "fileload", (event) ->
      soundsLoadedEvent.notify event.id
    createjs.Sound.registerSounds manifest

  @playSound: (soundId) ->
    createjs.Sound.play soundId


module.exports = SoundController

