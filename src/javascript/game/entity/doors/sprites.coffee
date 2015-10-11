
sprites =
  door_frame:
    spriteSheet: "images/doors.json"
    states:
      "default":
        frame: "door-frame"
  blue_gel_left:
    spriteSheet: "images/doors.json"
    states:
      "closed":
        frame: "door-gel-01"
      "opening":
        frames: [
          "door-gel-02"
          "blank"
        ]
        fps: 5
        loop: false
      "closing":
        frames: [
          "door-gel-02"
          "door-gel-01"
        ]
        fps: 5
        loop: false
    props:
      anchor: { x: 1, y: 0 }
  blue_gel_right:
    spriteSheet: "images/doors.json"
    states:
      "closed":
        frame: "door-gel-01"
        props:
          scale: { x: -1 }
      "opening":
        frames: [
          "door-gel-02"
          "blank"
        ]
        fps: 5
        loop: false
        props:
          scale: { x: -1 }
      "closing":
        frames: [
          "door-gel-02"
          "door-gel-01"
        ]
        fps: 5
        loop: false
        props:
          scale: { x: -1 }
    # props:
    #   anchor: { x: 0.5, y: 0 }

module.exports = sprites
