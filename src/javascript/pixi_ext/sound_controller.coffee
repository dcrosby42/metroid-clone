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
      callback()

    for name,url of soundMap
      h = new HowlerJs.Howl
        src: [url]
        preload: true
        onload: ->
          soundsLoadedEvent.notify @__soundName
        onloaderror: (soundId, err) ->
          console.log "!! ERR SoundController.loadSoundMap Howl name=#{name} url=#{url}: soundId=#{soundId} err=",err
      h.__soundName = name
      howls[name] = h

  @playSound: (soundName) ->
    howl = howls[soundName]
    if howl?
      sound = new SoundRef(howl)
      sound.play()
      sound
    else
      console.log "!! FAIL: SoundController.playSound '#{soundName}': no howl cached with this name"
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

  playPositionMillis: ->
    return 0 unless @howl? and @id?
    @howl.seek(@id) * 1000
    
  seekMillis: (millis) ->
    return 0 unless millis? and @howl? and @id?
    sec = millis/1000
    @howl.seek(sec,@id)

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

