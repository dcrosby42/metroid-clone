
sprites =
  basic_skree:
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

module.exports = sprites
