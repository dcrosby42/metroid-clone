CompositeEvent = require '../utils/composite_event'

HowlerJs = require 'howler'
window.howler = HowlerJs

howls = {}

class SoundController
  # Preload sound assets.
  #   soundMap is structured list { sndName: srcUrl, ... }
  #   callback (no args) will be called when all sounds have loaded.
  @loadSoundMap: (soundMap, callback) ->
    # Create a composite event keyed on all the sound names:
    names = []
    names.push name for name,_ of soundMap
    soundsLoadedEvent = CompositeEvent.create names, ->
      console.log "HowlerSoundController.loadSoundMap soundsLoadedEvents"
      callback()

    for name,url of soundMap
      h = new HowlerJs.Howl
        src: [url]
        preload: true
        onload: ->
          console.log "HowlerSoundController.loadSoundMap onload sn=#{@__soundName} this=",@
          soundsLoadedEvent.notify @__soundName

        onloaderror: (soundId, err) ->
          console.log "HowlerSoundController.loadSoundMap ERROR while building Howl name=#{name} url=#{url}: soundId=#{soundId} err=",err
      h.__soundName = name
      howls[name] = h

  @playSound: (soundName) ->
    console.log "HowlerSoundController.playSound #{soundName}"
    howl = howls[soundName]
    if howl?
      sound = new SoundRef(howl)
      console.log "HowlerSoundController.playSound '#{soundName}'"
      sound.play()
      sound
    else
      console.log "!! FAIL: HowlerSoundController.playSound '#{soundName}': no howl cached with this name"
      null

# Wraps a Howl and the sound id of a playable sound.
class SoundRef
  constructor: (@howl) ->
    @resound = false
    @id = @howl.play()
    @howl.pause(@id)

  play: ->
    return unless @howl? and @id?
    @howl.play(@id)

  pause: ->
    return unless @howl? and @id?
    @howl.pause(@id)

  setVolume: (v) ->
    return unless v?  and @howl? and @id?
    @howl.volume(v,@id)

  setLooping: (looping) ->
    return unless looping? and @howl? and @id?
    @howl.loop(looping,@id)

  setResound: (resound) ->
    return unless resound? and @howl? and @id?
    @resound = resound

  stop: ->
    @howl.stop(@id)

  remove: ->
    if @resound
      # Don't invoke stop, but don't allow looping forever either
      @setLooping(false)
    else
      @stop()
    # Decommision this sound wrapper
    @id = null
    @howl = null


module.exports = SoundController

