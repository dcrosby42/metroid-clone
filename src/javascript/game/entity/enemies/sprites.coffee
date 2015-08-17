
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

  basic_zoomer:
    spriteSheet: "images/zoomer.json"
    states:
      "crawl-up":
        frames: [
          "zoomer-up-01"
          "zoomer-up-02"
        ]
        fps: 15
      "crawl-left":
        frames: [
          "zoomer-left-01"
          "zoomer-left-02"
        ]
        fps: 15
      "crawl-right":
        frames: [
          "zoomer-right-01"
          "zoomer-right-02"
        ]
        fps: 15
      "crawl-down":
        frames: [
          "zoomer-down-01"
          "zoomer-down-02"
        ]
        fps: 15
      "stunned-crawl-up":
        frames: [
          "stunned-zoomer-up-01"
          "stunned-zoomer-up-02"
        ]
        fps: 15
      "stunned-crawl-left":
        frames: [
          "stunned-zoomer-left-01"
          "stunned-zoomer-left-02"
        ]
        fps: 15
      "stunned-crawl-right":
        frames: [
          "stunned-zoomer-right-01"
          "stunned-zoomer-right-02"
        ]
        fps: 15
      "stunned-crawl-down":
        frames: [
          "stunned-zoomer-down-01"
          "stunned-zoomer-down-02"
        ]
        fps: 15
    props:
      anchor: { x: 0.5, y: 0.5 }

module.exports = sprites
