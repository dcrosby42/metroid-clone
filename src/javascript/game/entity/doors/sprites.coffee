
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
        frame: "door-gel-02"
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
        frame: "door-gel-02"
        props:
          scale: { x: -1 }
    # props:
    #   anchor: { x: 0.5, y: 0 }

module.exports = sprites
