
sprites =
  door_frame:
    spriteSheet: "images/doors.json"
    states:
      "main":
        frame: "door-frame"
  door_gel:
    spriteSheet: "images/doors.json"
    states:
      "closed-left":
        frame: "door-gel-01"
      "opening-left":
        frame: "door-gel-02"
      "closed-right":
        frame: "door-gel-01"
        props:
          scale: { x: -1 }
      "opening-right":
        frame: "door-gel-02"
        props:
          scale: { x: -1 }
    props:
      anchor: { x: 0.5, y: 0 }

module.exports = sprites
