PIXI = require 'pixi.js'
# SpriteDeck = require "../sprite_deck"
_ = require 'lodash'
$ = require 'jquery'
Mousetrap = require '../vendor/mousetrap_wrapper'

KeyboardController = require '../keyboard_controller'
AnimatedSprite = require '../animated_sprite'

class SkreePreview
  constructor: ->

  setupInput: ->
    # $('#d-pad-right').on "click", =>
    #   @buttonRight()
    # $('#reset').on "click", =>
    #   @reset()

    # Mousetrap.bind 'r', => @reset()

    Mousetrap.bind 'f', =>
      @skree.components.skree.action = 'hanging'
    Mousetrap.bind 'g', =>
      @skree.components.skree.action = 'launching'
      @skree.components.skree.countdown = null
    Mousetrap.bind 'h', =>
      @skree.components.skree.action = 'diving'

    # @keyboardController = new KeyboardController
    #   "right": 'right'
    #   "left": 'left'
    #   "up": 'up'
    #   "down": 'down'
    #   "a": 'jump'
    #   "s": 'shoot'

  graphicsToPreload: ->
    [
      @skreeData().spriteSheet
      "images/room0_blank.png"
    ]

  setupStage: (@stage, width, height) ->
    zoom = height / 240

    base = new PIXI.DisplayObjectContainer()
    base.scale.set(1.25*zoom,zoom)
    @stage.addChild base

    @mapLayer = new PIXI.DisplayObjectContainer()
    base.addChild @mapLayer

    @sampleMapBg = PIXI.Sprite.fromFrame("images/room0_blank.png")
    @mapLayer.addChild @sampleMapBg
    
    @spriteLayer = new PIXI.DisplayObjectContainer()
    base.addChild @spriteLayer

    @overlay = new PIXI.DisplayObjectContainer()
    base.addChild @overlay


    @skree = @createSkree()
    @spriteLayer.addChild @skree.ui.sprite

    @setupInput()

    window.stage = @stage
    window.skree = @skree

  updateSkree: (skreeComp, animComp, posComp, motionComp, dt) ->
    # hanging -> launching -> diving -> drilling -> splode
    motionComp.y = 0
    motionComp.x = 0
    switch skreeComp.action
      when 'launching'
        if skreeComp.countdown == null
          skreeComp.countdown = 1000
        else
          skreeComp.countdown -= dt

        if skreeComp.countdown <= 0
          skreeComp.countdown = null
          skreeComp.action = 'diving'

      when 'diving'
        height = 24
        floor = 208
        if posComp.y + height < floor
          motionComp.y = 5
        else
          posComp.y = floor-height
          skreeComp.action = 'drilling'

      when 'drilling'
        if skreeComp.countdown == null
          skreeComp.countdown = 1000
        else
          skreeComp.countdown -= dt

        if skreeComp.countdown <= 0
          skreeComp.countdown = null
          skreeComp.action = 'explode'

    # Animation state:
    oldAnimState = animComp.state
    if skreeComp.action == 'hanging'
      animComp.state = 'wait'
    else
      animComp.state = 'attack'
    if animComp.state != oldAnimState
      animComp.time = 0
    

  updateAnimation: (animComp, dt) ->
    animComp.time += dt

  # updateControls: (comp, kbUpdate) ->
  #   comp = _.merge(comp,kbUpdate)

  # updateMotion: (motionComp, controlsComp, dt) ->
  #   motionComp.x = 0
  #   motionComp.y = 0
  #
  #   speed = (44 / dt) * 0.75
  #   if controlsComp.right
  #     motionComp.x = speed
  #   else if controlsComp.left
  #     motionComp.x = -speed

  updatePosition: (posComp, motionComp) ->
    posComp.x += motionComp.x
    posComp.y += motionComp.y

  syncUI: (ui, posComp, animComp) ->
    # ui.animator.display animComp.state, animComp.time
    ui.sprite.position.set posComp.x, posComp.y
    ui.sprite.displayAnimation animComp.state, animComp.time

  update: (dt) ->
    # keyboardUpdate = @keyboardController.update()

    c = @skree.components
    #
    # @updateControls  c.controls, keyboardUpdate
    @updateSkree c.skree, c.animation, c.position, c.motion, dt #, c.controls
    # @updateMotion    c.motion, c.controls, dt
    # @updateCharacter c.character, c.controls
    
    @updatePosition  c.position, c.motion
    @updateAnimation c.animation, dt
    #
    @syncUI @skree.ui, c.position, c.animation

  skreeData: ->
    spriteSheet: "images/skree.json"
    states:
      "wait":
        frames: [
          "skree-green-01"
          "skree-green-02"
          "skree-green-03"
        ]
        fps: 7.5
      "attack":
        frames: [
          "skree-green-01"
          "skree-green-02"
          "skree-green-03"
        ]
        fps: 30
    modify:
      anchor: { x: 0.5, y: 0 }

  createSkree: ->
    config = @skreeData()
    e = {}
    e.ui = {}
    e.ui.sprite = AnimatedSprite.create(config)

    e.components = {}

    e.components.skree =
      type: 'skree'
      action: 'hanging' # hanging | launching | diving | drilling
      
    e.components.motion =
      type: 'action'
      x: 0
      y: 0

    e.components.position =
      type: 'position'
      x: 64
      y: 16

    # e.components.controls =
    #   type: 'controls'
    #   left: false
    #   right: false
    #   up: false
    #   down: false
    #   jump: false
    #   shoot: false

    e.components.animation =
      type: 'animation'
      state: 'wait'
      time: 0

    e


  samusData: ->
    spriteSheet: "images/samus.json"
    states:
      "stand-right":
        frame: "samus1-04-00"
      "run-right":
        frames: [
          "samus1-06-00"
          "samus1-07-00"
          "samus1-08-00"
        ]
        fps: 20
      "stand-left":
        frame: "samus1-04-00"
        modify:
          scale: { x: -1 }
      "run-left":
        frames: [
          "samus1-06-00"
          "samus1-07-00"
          "samus1-08-00"
        ]
        fps: 20
        modify:
          scale: { x: -1 }
    modify:
      anchor: { x: 0.5, y: 1 }

  createSamus: ->
    config = @samusData()
    e = {}
    e.ui = {}
    e.ui.spriteDeck = sd
    e.ui.animator = Animator.create(sd, config)

    e.components = {}

    e.components.character =
      type: 'character'
      action: 'standing' # standing | running | jumping | falling
      direction: 'right' # right | left
      aim: 'straight' # up | straight
      
    e.components.motion =
      type: 'action'
      x: 0
      y: 0

    e.components.position =
      type: 'position'
      x: 50
      y: 208

    e.components.controls =
      type: 'controls'
      left: false
      right: false
      up: false
      down: false
      jump: false
      shoot: false

    e.components.animation =
      type: 'animation'
      state: 'stand-right'
      time: 0

    e



module.exports = SkreePreview

