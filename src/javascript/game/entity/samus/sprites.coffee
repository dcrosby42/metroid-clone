sprites =
  bullet:
    spriteSheet: "images/samus.json"
    states:
      'normal':
        frame: 'bullet'
        props:
          anchor:
            x: 0.5
            y: 0.5
      'splode':
        frames: [
          'bullet-splode'
          'blank'
        ]
        fps: 60
        props:
          anchor:
            x: 0.5
            y: 0.5

  missile:
    spriteSheet: "images/samus.json"
    states:
      'right':
        frame: 'missile'
      'left':
        frame: 'missile'
        props:
          scale: { x: -1 }
      'up':
        frame: 'missile'
        props:
          rotation: -(Math.PI / 2)
    props:
      anchor:
        x: 0.5
        y: 0.5

  missile_shrapnel:
    spriteSheet: "images/samus.json"
    states:
      'left':
        frame: 'missile-shrap-01'
      'right':
        frame: 'missile-shrap-01'
        props:
          scale: { x: -1 }
      'up-left':
        frame: 'missile-shrap-02'
      'down-left':
        frame: 'missile-shrap-02'
        props:
          scale: { y: -1 }
      'up-right':
        frame: 'missile-shrap-02'
        props:
          scale: { x: -1 }
      'down-right':
        frame: 'missile-shrap-02'
        props:
          scale: { x: -1, y: -1 }
    props:
      anchor:
        x: 0.5
        y: 0.5
      #   frames: [
      #     'missile-splode'
      #     'blank'
      #   ]
      #   fps: 60
      #   props:
      #     anchor:
      #       x: 0.5
      #       y: 0.5
  samus:
    spriteSheet: "images/samus.json"
    states:
      "stand-right":
        frame: "samus1-04-00"
      "stand-right-shoot":
        frame: "samus1-stand-shoot"
      "stand-right-aim-up":
        frame: "samus1-aim-up"
      "run-right":
        frames: [
          "samus1-06-00"
          "samus1-07-00"
          "samus1-08-00"
        ]
        fps: 20
      "run-right-aim-up":
        frames: [
          "samus1-aim-up-run1"
          "samus1-aim-up-run2"
          "samus1-aim-up-run3"
        ]
        fps: 20
      "stand-left":
        frame: "samus1-04-00"
        props:
          scale: { x: -1 }
      "stand-left-shoot":
        frame: "samus1-stand-shoot"
        props:
          scale: { x: -1 }
      "stand-left-aim-up":
        frame: "samus1-aim-up"
        props:
          scale: { x: -1 }
      "run-left":
        frames: [
          "samus1-06-00"
          "samus1-07-00"
          "samus1-08-00"
        ]
        fps: 20
        props:
          scale: { x: -1 }
      "run-left-aim-up":
        frames: [
          "samus1-aim-up-run1"
          "samus1-aim-up-run2"
          "samus1-aim-up-run3"
        ]
        fps: 20
        props:
          scale: { x: -1 }

      "jump-right":
        frame: "samus1-jump-right"

      "jump-right-aim-up":
        frame: "samus1-jump-right-aim-up"

      "jump-left":
        frame: "samus1-jump-right"
        props:
          scale: { x: -1 }

      "jump-left-aim-up":
        frame: "samus1-jump-right-aim-up"
        props:
          scale: { x: -1 }

      "roll-right":
        frames: [
          "morph-ball-a"
          "morph-ball-b"
          "morph-ball-c"
          "morph-ball-d"
        ]
        fps: 30
      "roll-left":
        frames: [
          "morph-ball-d"
          "morph-ball-c"
          "morph-ball-b"
          "morph-ball-a"
        ]
        fps: 30

    props:
      anchor: { x: 0.5, y: 0.95 }

module.exports = sprites
