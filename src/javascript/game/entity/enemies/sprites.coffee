
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

      "stunned-wait":
        frames: [
          "skree-stunned-01"
          "skree-stunned-02"
          "skree-stunned-03"
        ]
        fps: 7.5
      "stunned-attack":
        frames: [
          "skree-stunned-01"
          "skree-stunned-02"
          "skree-stunned-03"
        ]
        fps: 30
    props:
      anchor: { x: 0.5, y: 0 }

module.exports = sprites
