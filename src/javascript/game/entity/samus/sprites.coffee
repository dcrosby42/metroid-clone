sprites =
  samus:
    spriteSheet: "images/samus.json"
    states:
      "stand-right":
        frame: "samus1-04-00"
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

      "jump-left":
        frame: "samus1-jump-right"
        props:
          scale: { x: -1 }

    props:
      anchor: { x: 0.5, y: 1 }

module.exports = sprites
