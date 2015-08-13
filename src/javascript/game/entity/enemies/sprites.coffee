
sprites =
  basic_skree:
    spriteSheet: "images/skree.json"
    states:
      "spinSlow":
        frames: [
          "skree-green-01"
          "skree-green-02"
          "skree-green-03"
        ]
        fps: 7.5
      "spinFast":
        frames: [
          "skree-green-01"
          "skree-green-02"
          "skree-green-03"
        ]
        fps: 30

      "stunned-spinSlow":
        frames: [
          "skree-stunned-01"
          "skree-stunned-02"
          "skree-stunned-03"
        ]
        fps: 7.5
      "stunned-spinFast":
        frames: [
          "skree-stunned-01"
          "skree-stunned-02"
          "skree-stunned-03"
        ]
        fps: 30
    props:
      anchor: { x: 0.5, y: 0 }

  skree_shrapnel:
    spriteSheet: "images/skree.json"
    states:
      normal:
        frame: "skree-shrapnel"
        props:
          anchor:
            x: 0.5
            y: 0.5



module.exports = sprites
